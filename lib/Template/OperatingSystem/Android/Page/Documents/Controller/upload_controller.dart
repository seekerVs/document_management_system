import 'dart:io';
import 'package:file_picker/file_picker.dart';
import 'package:flutter_doc_scanner/flutter_doc_scanner.dart';
import 'package:get/get.dart';
import '../../../../../Commons/Widgets/document_source_sheet.dart';
import 'package:uuid/uuid.dart';

import '../../../../../../Template/Utils/Exceptions/exceptions.dart';
import '../../../../../../Template/Utils/Helpers/helpers.dart';
import '../../../../../../Template/Utils/Popups/dialog.dart';
import '../../../../../../Template/Utils/Popups/full_screen_loader.dart';
import '../../../../../../Template/Utils/Services/network_manager.dart';
import '../../../../../../Template/Utils/Services/supabase_service.dart';
import '../../Profile/Controller/user_controller.dart';
import '../Model/document_model.dart';
import '../Repository/document_repository.dart';
import '../Repository/folder_repository.dart';
import '../../Dashboard/Controller/dashboard_controller.dart';
import 'documents_controller.dart';

class UploadController extends GetxController {
  final DocumentRepository _docRepo = DocumentRepository();
  final FolderRepository _folderRepo = FolderRepository();
  final UserController _userController = Get.find<UserController>();

  Future<void> pickAndUpload() async => _pickAndUploadToFolder(null);

  Future<void> pickAndUploadToFolder(String folderId) async =>
      _pickAndUploadToFolder(folderId);

  void showUploadSourceSheet({String? folderId}) {
    DocumentSourceSheet.show(
      onScan: () => scanAndUpload(folderId: folderId),
      onDrive: () => AppDialogs.showSnackError('Coming soon'),
      onPhotos: () => AppDialogs.showSnackError('Coming soon'),
      onFiles: () => _pickAndUploadToFolder(folderId),
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

      final name =
          'Scan ${DateTime.now().toString().substring(0, 16).replaceAll(':', '').replaceAll(' ', '_')}.pdf';
      final fileSizeBytes = await file.length();
      final fileSizeMB = fileSizeBytes / (1024 * 1024);

      if (AppHelpers.exceedsMaxFileSize(fileSizeBytes)) {
        AppDialogs.showError(
          message: 'File size exceeds 20 MB. Please choose a smaller file.',
        );
        return;
      }

      final warning = NetworkManager.to.mobileDataWarning(
        fileSizeMB: fileSizeMB,
      );
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

      final freeStorage = _userController.user.value?.freeStorageMB ?? 0;
      if (fileSizeMB > freeStorage) {
        AppDialogs.showError(
          title: 'Not Enough Storage',
          message:
              'This file (${fileSizeMB.toStringAsFixed(1)} MB) exceeds your available storage (${freeStorage.toStringAsFixed(1)} MB).',
        );
        return;
      }

      AppUploadLoader.show(fileName: name);

      final uid = _docRepo.currentUid;
      final uploadResult = await SupabaseService.uploadFile(
        filePath: file.path,
        uid: uid,
        fileName: name,
      );

      final doc = DocumentModel(
        documentId: const Uuid().v4(),
        ownerUid: uid,
        folderId: folderId,
        name: name,
        fileUrl: uploadResult.storagePath,
        fileSizeMB: uploadResult.fileSizeMB,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      await _docRepo.addDocument(doc);

      if (folderId != null) {
        await _folderRepo.updateItemCount(folderId, 1);
      }

      await _userController.incrementStorage(uploadResult.fileSizeMB);

      AppUploadLoader.hide();
      if (Get.isRegistered<DocumentsController>()) {
        await Get.find<DocumentsController>().loadAll();
      }
      if (Get.isRegistered<DashboardController>()) {
        await Get.find<DashboardController>().loadDashboard();
      }
      AppDialogs.showSnackSuccess('$name uploaded successfully.');
    } catch (e) {
      AppUploadLoader.hide();
      AppDialogs.showSnackError('Upload failed: ${e.toString()}');
    } finally {
      AppUploadLoader.hide();
    }
  }

  Future<void> _pickAndUploadToFolder(String? folderId) async {
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

    final fileSizeBytes = await File(picked.path!).length();
    final fileSizeMB = fileSizeBytes / (1024 * 1024);

    if (AppHelpers.exceedsMaxFileSize(fileSizeBytes)) {
      AppDialogs.showError(
        message: 'File size exceeds 20 MB. Please choose a smaller file.',
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

    final freeStorage = _userController.user.value?.freeStorageMB ?? 0;
    if (fileSizeMB > freeStorage) {
      AppDialogs.showError(
        title: 'Not Enough Storage',
        message:
            'This file (${fileSizeMB.toStringAsFixed(1)} MB) exceeds your available storage (${freeStorage.toStringAsFixed(1)} MB).',
      );
      return;
    }

    AppUploadLoader.show(fileName: picked.name);

    try {
      final uid = _docRepo.currentUid;

      final uploadResult = await SupabaseService.uploadFile(
        filePath: picked.path!,
        uid: uid,
        fileName: picked.name,
      );

      final fileType = AppHelpers.detectFileType(picked.name);

      final doc = DocumentModel(
        documentId: const Uuid().v4(),
        ownerUid: uid,
        folderId: folderId,
        name: picked.name,
        fileUrl: uploadResult.storagePath, // store path, not URL
        fileType: fileType,
        fileSizeMB: uploadResult.fileSizeMB,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      await _docRepo.addDocument(doc);

      if (folderId != null) {
        await _folderRepo.updateItemCount(folderId, 1);
      }

      await _userController.incrementStorage(uploadResult.fileSizeMB);

      AppUploadLoader.hide();

      if (Get.isRegistered<DocumentsController>()) {
        await Get.find<DocumentsController>().loadAll();
      }
      if (Get.isRegistered<DashboardController>()) {
        await Get.find<DashboardController>().loadDashboard();
      }
      AppDialogs.showSnackSuccess('${picked.name} uploaded successfully.');
    } on NetworkException catch (e) {
      AppDialogs.showSnackError(e.message);
    } catch (e) {
      AppDialogs.showSnackError('Upload failed: ${e.toString()}');
    } finally {
      // Ensure loader is always hidden even if error occurs before explicit hide
      AppUploadLoader.hide();
    }
  }
}
