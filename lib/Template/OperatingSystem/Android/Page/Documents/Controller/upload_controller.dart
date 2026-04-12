import 'dart:io';
import 'package:file_picker/file_picker.dart';
import 'package:flutter_doc_scanner/flutter_doc_scanner.dart';
import 'package:get/get.dart';
import 'package:uuid/uuid.dart';
import '../../../../../Commons/Widgets/document_source_sheet.dart';
import '../../../../../Utils/Exceptions/exceptions.dart';
import '../../../../../Utils/Helpers/helpers.dart';
import '../../../../../Utils/Popups/dialog.dart';
import '../../../../../Utils/Popups/full_screen_loader.dart';
import '../../../../../Utils/Services/network_manager.dart';
import '../../../../../Utils/Services/supabase_service.dart';
import '../../Profile/Controller/user_controller.dart';
import '../Model/document_model.dart';
import '../Model/prepare_upload_model.dart';
import '../Repository/document_repository.dart';
import '../Repository/folder_repository.dart';
import '../../Dashboard/Controller/dashboard_controller.dart';
import '../Widget/prepare_upload_dialog.dart';
import 'documents_controller.dart';

class UploadController extends GetxController {
  final DocumentRepository _docRepo = DocumentRepository();
  final FolderRepository _folderRepo = FolderRepository();
  final UserController _userController = Get.find<UserController>();

  void showUploadSourceSheet({String? folderId}) {
    DocumentSourceSheet.show(
      onScan: () => scanAndUpload(folderId: folderId),
      onDrive: () => AppDialogs.showSnackError('Coming soon'),
      onPhotos: () => AppDialogs.showSnackError('Coming soon'),
      onFiles: () => pickAndUpload(folderId: folderId),
    );
  }

  Future<void> scanAndUpload({String? folderId}) async {
    NetworkManager.to.checkBeforeRequest();

    if (_userController.user.value?.isStorageFull ?? false) {
      AppDialogs.showError(
        title: 'Storage Full',
        message:
            'You have used all 2 GB of storage. Delete some documents to free up space.',
      );
      return;
    }

    try {
      final result = await FlutterDocScanner().getScannedDocumentAsPdf();
      if (result == null) return;

      // URI Cleanup
      String? cleanPath;
      final dynamic res = result;
      if (res is Map) {
        cleanPath = res['pdfUri']?.toString();
      } else {
        try {
          cleanPath = res.pdfUri?.toString();
        } catch (_) {}
      }

      if (cleanPath == null || cleanPath.isEmpty) return;
      if (cleanPath.startsWith('file://')) {
        cleanPath = cleanPath.replaceFirst('file://', '');
      }

      final file = File(cleanPath);
      if (!await file.exists()) return;

      final originalName =
          'Scan ${DateTime.now().toString().substring(0, 16).replaceAll(':', '').replaceAll(' ', '_')}.pdf';

      final fileSizeBytes = await file.length();
      final fileSizeMB = fileSizeBytes / (1024 * 1024);

      if (AppHelpers.exceedsMaxFileSize(fileSizeBytes)) {
        AppDialogs.showError(
          message: 'File size exceeds 20 MB. Please choose a smaller file.',
        );
        return;
      }

      // Step 2: Prepare
      final prepResult = await PrepareUploadDialog.show(
        file: file,
        originalName: originalName,
        fileSizeMB: fileSizeMB,
        initialFolderId: folderId,
      );

      if (prepResult == null) return;

      // Step 3: Execute
      await _executeUpload(file, prepResult, fileSizeMB);
    } catch (e) {
      AppUploadLoader.hide();
      AppDialogs.showSnackError('Upload failed: ${e.toString()}');
    }
  }

  Future<void> pickAndUpload({String? folderId}) async {
    NetworkManager.to.checkBeforeRequest();

    if (_userController.user.value?.isStorageFull ?? false) {
      AppDialogs.showError(
        title: 'Storage Full',
        message:
            'You have used all 2 GB of storage. Delete some documents to free up space.',
      );
      return;
    }

    final result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['pdf'],
    );

    if (result == null || result.files.isEmpty) return;
    final picked = result.files.first;
    if (picked.path == null) return;

    final file = File(picked.path!);
    final fileSizeBytes = await file.length();
    final fileSizeMB = fileSizeBytes / (1024 * 1024);

    if (AppHelpers.exceedsMaxFileSize(fileSizeBytes)) {
      AppDialogs.showError(
        message: 'File size exceeds 20 MB. Please choose a smaller file.',
      );
      return;
    }

    // Step 2: Prepare
    final prepResult = await PrepareUploadDialog.show(
      file: file,
      originalName: picked.name,
      fileSizeMB: fileSizeMB,
      initialFolderId: folderId,
    );

    if (prepResult == null) return;

    // Step 3: Execute
    await _executeUpload(file, prepResult, fileSizeMB);
  }

  Future<void> _executeUpload(
    File file,
    PrepareUploadResult result,
    double fileSizeMB,
  ) async {
    // Final storage check before starting upload
    final currentFree = _userController.user.value?.freeStorageMB ?? 0;
    if (fileSizeMB > currentFree) {
      AppDialogs.showError(
        title: 'Not Enough Storage',
        message:
            'This file (${fileSizeMB.toStringAsFixed(1)} MB) exceeds your available storage (${currentFree.toStringAsFixed(1)} MB).',
      );
      return;
    }

    final warning = NetworkManager.to.mobileDataWarning(fileSizeMB: fileSizeMB);
    if (warning != null) {
      bool proceed = false;
      await AppDialogs.showConfirm(
        title: 'Mobile Data Warning',
        message: warning,
        confirmLabel: 'Upload Anyway',
        onConfirm: () => proceed = true,
      );
      if (!proceed) return;
    }

    // Auto-resolve name if it already exists
    final String initialName = result.fileName + result.extension;
    final List<String> existingNames = [];
    if (result.folderId == null) {
      final foldersRes = await _folderRepo.getFolders();
      final docsRes = await _docRepo.getRootDocuments();
      existingNames.addAll(foldersRes.map((f) => f.name));
      existingNames.addAll(docsRes.map((d) => d.name));
    } else {
      final docsRes = await _docRepo.getFolderDocuments(result.folderId!);
      existingNames.addAll(docsRes.map((d) => d.name));
    }

    final finalFileName = AppHelpers.resolveUniqueName(initialName, existingNames);
    AppUploadLoader.show(fileName: finalFileName);

    try {
      final uid = _docRepo.currentUid;

      final uploadResult = await SupabaseService.uploadFile(
        filePath: file.path,
        uid: uid,
        fileName: finalFileName,
      );

      final fileType = AppHelpers.detectFileType(finalFileName);

      final doc = DocumentModel(
        documentId: const Uuid().v4(),
        ownerUid: uid,
        folderId: result.folderId,
        name: finalFileName,
        fileUrl: uploadResult.storagePath,
        fileType: fileType,
        fileSizeMB: uploadResult.fileSizeMB,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      await _docRepo.addDocument(doc);

      if (result.folderId != null) {
        await _folderRepo.updateItemCount(result.folderId!, 1);
      }

      await _userController.incrementStorage(uploadResult.fileSizeMB);

      AppUploadLoader.hide();

      if (Get.isRegistered<DocumentsController>()) {
        await Get.find<DocumentsController>().loadAll();
      }
      if (Get.isRegistered<DashboardController>()) {
        await Get.find<DashboardController>().loadDashboard();
      }
      AppDialogs.showSnackSuccess('$finalFileName uploaded successfully.');
    } on NetworkException catch (e) {
      AppDialogs.showSnackError(e.message);
    } catch (e) {
      AppDialogs.showSnackError('Upload failed: ${e.toString()}');
    } finally {
      AppUploadLoader.hide();
    }
  }
}
