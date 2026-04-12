import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:uuid/uuid.dart';
import '../../../../../OperatingSystem/Android/Page/Documents/Model/document_model.dart';
import '../../../../../OperatingSystem/Android/Page/Documents/Model/folder_model.dart';
import '../Repository/document_repository.dart';
import '../Repository/folder_repository.dart';
import '../../../../../Commons/Widgets/document_details_sheet.dart';
import '../Widget/folder_picker_sheet.dart';
import '../../../../../Utils/Exceptions/exceptions.dart';
import '../../../../../Utils/Firebase/firebase_utils.dart';
import '../../../../../Utils/Formatters/formatter.dart';
import '../../../../../Utils/Helpers/helpers.dart';
import '../../../../../Utils/Popups/dialog.dart';
import '../../../../../Utils/Popups/full_screen_loader.dart';
import '../../../../../Utils/Services/supabase_service.dart';
import '../../Profile/Controller/user_controller.dart';

mixin DocumentsMultiselectMixin on GetxController {
  DocumentRepository get docRepo;
  FolderRepository get folderRepo;
  UserController get userController;
  RxList<DocumentModel> get documents;
  RxList<FolderModel> get folders;
  RxList<String> get selectedIds;
  RxBool get isMultiSelect;
  RxList<DocumentModel> get folderDocs;
  RxList<DocumentModel> get searchResults;

  Future<void> loadAll();

  // State
  int get selectedCount => selectedIds.length;
  bool get isSingleSelection => selectedIds.length == 1;

  List<DocumentModel> get selectedDocuments {
    final pool = folderDocs.isNotEmpty
        ? folderDocs
        : (searchResults.isNotEmpty ? searchResults : documents);
    return pool.where((d) => selectedIds.contains(d.documentId)).toList();
  }

  List<FolderModel> get selectedFolders =>
      folders.where((f) => selectedIds.contains(f.folderId)).toList();

  double get selectedTotalSizeMB =>
      selectedDocuments.fold(0, (total, d) => total + d.fileSizeMB);

  void enterMultiSelect() => isMultiSelect.value = true;

  void exitMultiSelect() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      isMultiSelect.value = false;
      selectedIds.clear();
    });
  }

  void selectItem(String id) {
    enterMultiSelect();
    if (!selectedIds.contains(id)) selectedIds.add(id);
  }

  void toggleSelection(String id) {
    if (selectedIds.contains(id)) {
      selectedIds.remove(id);
      if (selectedIds.isEmpty) exitMultiSelect();
    } else {
      selectedIds.add(id);
    }
  }

  bool isSelected(String id) => selectedIds.contains(id);

  // Delete
  void deleteSelected() {
    final docs = selectedDocuments;
    final folderList = selectedFolders;
    final docCount = docs.length;
    final folderCount = folderList.length;

    final parts = <String>[];
    if (folderCount > 0) {
      parts.add('$folderCount folder${folderCount > 1 ? 's' : ''}');
    }
    if (docCount > 0) parts.add('$docCount document${docCount > 1 ? 's' : ''}');
    final title = 'Delete ${parts.join(' and ')}?';

    final foldersWithContent = folderList
        .where((f) => f.itemCount > 0)
        .toList();
    final message = foldersWithContent.isNotEmpty
        ? 'This will permanently delete the selected items and all documents inside the selected folders. This cannot be undone.'
        : 'This will permanently delete the selected items. This cannot be undone.';

    AppDialogs.showConfirm(
      title: title,
      message: message,
      confirmLabel: 'Delete',
      isDangerous: true,
      onConfirm: () async {
        AppLoader.show(message: 'Deleting...');
        try {
          for (final doc in docs) {
            await docRepo.deleteDocument(doc.documentId);
            await SupabaseService.deleteFile(doc.fileUrl);
            await userController.decrementStorage(doc.fileSizeMB);
          }
          for (final folder in folderList) {
            final folderDocsList = await docRepo.getFolderDocuments(
              folder.folderId,
            );
            for (final doc in folderDocsList) {
              await docRepo.deleteDocument(doc.documentId);
              await SupabaseService.deleteFile(doc.fileUrl);
              await userController.decrementStorage(doc.fileSizeMB);
            }
            await folderRepo.deleteFolder(folder.folderId);
          }
          await loadAll();
          exitMultiSelect();
          final total = docCount + folderCount;
          AppDialogs.showSnackSuccess(
            '$total item${total > 1 ? 's' : ''} deleted.',
          );
        } on AppException catch (e) {
          AppDialogs.showSnackError(e.message);
        } finally {
          AppLoader.hide();
        }
      },
    );
  }

  // Rename
  void renameSelected() {
    if (!isSingleSelection) return;
    final id = selectedIds.first;
    final pool = folderDocs.isNotEmpty ? folderDocs : documents;
    final doc = pool.firstWhereOrNull((d) => d.documentId == id);
    final folder = folders.firstWhereOrNull((f) => f.folderId == id);
    if (doc != null) showRenameDocumentDialog(doc);
    if (folder != null) showRenameFolderDialog(folder);
  }

  // Forward to document/folder mixins — implemented via mixin composition
  void showRenameDocumentDialog(DocumentModel doc);
  void showRenameFolderDialog(FolderModel folder);

  // Copy
  void showCopyPicker() {
    FolderPickerSheet.show(onPick: (folderId, _) => _executeCopy(folderId));
  }

  Future<void> _executeCopy(String? destFolderId) async {
    final docs = selectedDocuments;
    final folderList = selectedFolders;

    double totalSizeMB = docs.fold(0.0, (total, d) => total + d.fileSizeMB);
    for (final folder in folderList) {
      final folderDocsList = await docRepo.getFolderDocuments(folder.folderId);
      totalSizeMB += folderDocsList.fold(
        0.0,
        (total, d) => total + d.fileSizeMB,
      );
    }

    if (userController.user.value != null) {
      final free = userController.user.value!.freeStorageMB;
      if (totalSizeMB > free) {
        AppDialogs.showSnackError(
          'Not enough storage. Need ${AppFormatter.fileSizeFromMB(totalSizeMB)}, '
          'only ${AppFormatter.fileSizeFromMB(free)} available.',
        );
        return;
      }
    }

    final failed = <String>[];
    int copied = 0;
    final total = docs.length + folderList.length;
    AppLoader.show(message: 'Copying 0 of $total...');

    try {
      for (final doc in docs) {
        try {
          await _copyDocument(doc, destFolderId);
          copied++;
          AppLoader.updateMessage('Copying $copied of $total...');
          if (destFolderId != null) {
            await folderRepo.updateItemCount(destFolderId, 1);
          }
        } catch (_) {
          failed.add(doc.name);
        }
      }

      for (final folder in folderList) {
        try {
          await _copyFolder(
            folder,
            destFolderId,
            onProgress: (msg) => AppLoader.updateMessage(msg),
          );
          copied++;
          AppLoader.updateMessage('Copying $copied of $total...');
        } catch (_) {
          failed.add(folder.name);
        }
      }

      await loadAll();
      exitMultiSelect();

      if (failed.isEmpty) {
        AppDialogs.showSnackSuccess(
          '$copied item${copied > 1 ? 's' : ''} copied successfully.',
        );
      } else {
        AppDialogs.showSnackError(
          '$copied copied. Failed: ${failed.join(', ')}',
        );
      }
    } finally {
      AppLoader.hide();
    }
  }

  Future<void> _copyDocument(
    DocumentModel doc,
    String? destFolderId, {
    String? nameOverride,
  }) async {
    final destDocs = destFolderId != null
        ? await docRepo.getFolderDocuments(destFolderId)
        : await docRepo.getRootDocuments();
    final existingNames = destDocs.map((d) => d.name).toSet();
    final resolvedName =
        nameOverride ?? AppHelpers.resolveUniqueName(doc.name, existingNames);

    final signedUrl = await SupabaseService.getSignedUrl(doc.fileUrl);
    final response = await http.get(Uri.parse(signedUrl));
    if (response.statusCode != 200) throw Exception('Download failed');

    final newId = const Uuid().v4();
    final newPath = 'documents/${doc.ownerUid}/$newId.pdf';
    final uploadResult = await SupabaseService.uploadBytes(
      bytes: response.bodyBytes,
      storagePath: newPath,
      fileName: resolvedName,
    );

    final now = DateTime.now();
    final newDoc = DocumentModel(
      documentId: newId,
      ownerUid: doc.ownerUid,
      folderId: destFolderId,
      name: resolvedName,
      fileUrl: uploadResult.storagePath,
      storagePath: newPath,
      fileType: doc.fileType,
      fileSizeMB: doc.fileSizeMB,
      createdAt: now,
      updatedAt: now,
    );
    await docRepo.addDocument(newDoc);
    await userController.incrementStorage(doc.fileSizeMB);
  }

  Future<void> _copyFolder(
    FolderModel folder,
    String? destFolderId, {
    required void Function(String) onProgress,
  }) async {
    final existingFolderNames = folders.map((f) => f.name).toSet();
    final resolvedName = AppHelpers.resolveUniqueName(
      folder.name,
      existingFolderNames,
    );

    final newFolderId = const Uuid().v4();
    final now = DateTime.now();
    final newFolder = FolderModel(
      folderId: newFolderId,
      ownerUid: folder.ownerUid,
      name: resolvedName,
      createdAt: now,
      updatedAt: now,
    );
    await folderRepo.createFolder(newFolder);

    final folderDocsList = await docRepo.getFolderDocuments(folder.folderId);
    for (var i = 0; i < folderDocsList.length; i++) {
      onProgress(
        'Copying folder contents (${i + 1}/${folderDocsList.length})...',
      );
      await _copyDocument(folderDocsList[i], newFolderId);
    }
    if (folderDocsList.isNotEmpty) {
      await folderRepo.updateItemCount(newFolderId, folderDocsList.length);
    }
  }

  // Move

  void showMovePicker() {
    final hasFolders = selectedFolders.isNotEmpty;
    final docs = selectedDocuments;
    final currentFolderId = docs.isNotEmpty ? docs.first.folderId : null;
    final excludeRoot = currentFolderId == null && docs.isNotEmpty;

    FolderPickerSheet.show(
      title: 'Move to',
      excludeFolderId: currentFolderId,
      excludeRoot: excludeRoot,
      onPick: (destFolderId, _) =>
          _executeMove(destFolderId, warnFolders: hasFolders),
    );
  }

  Future<void> _executeMove(
    String? destFolderId, {
    bool warnFolders = false,
  }) async {
    final docs = selectedDocuments;

    if (warnFolders) {
      AppDialogs.showSnackError(
        'Folders cannot be moved. Moving documents only.',
      );
    }
    if (docs.isEmpty) return;

    AppLoader.show(message: 'Moving...');
    final failed = <String>[];

    try {
      for (final doc in docs) {
        try {
          final destDocs = destFolderId != null
              ? await docRepo.getFolderDocuments(destFolderId)
              : await docRepo.getRootDocuments();
          final existingNames = destDocs.map((d) => d.name).toSet();
          final resolvedName = AppHelpers.resolveUniqueName(
            doc.name,
            existingNames,
          );

          await FirebaseUtils.documentDoc(doc.documentId).update({
            'folderId': destFolderId,
            if (resolvedName != doc.name) 'name': resolvedName,
            'updatedAt': Timestamp.now(),
          });

          if (doc.folderId != null) {
            await folderRepo.updateItemCount(doc.folderId!, -1);
          }
          if (destFolderId != null) {
            await folderRepo.updateItemCount(destFolderId, 1);
          }
        } catch (_) {
          failed.add(doc.name);
        }
      }

      await loadAll();
      exitMultiSelect();

      final moved = docs.length - failed.length;
      if (failed.isEmpty) {
        AppDialogs.showSnackSuccess(
          '$moved document${moved > 1 ? 's' : ''} moved.',
        );
      } else {
        AppDialogs.showSnackError('$moved moved. Failed: ${failed.join(', ')}');
      }
    } finally {
      AppLoader.hide();
    }
  }

  // Share

  Future<void> shareSelected() async {
    final docs = selectedDocuments;
    final folderList = selectedFolders;

    if (docs.isEmpty && folderList.isNotEmpty) {
      AppDialogs.showSnackError(
        'Folders cannot be shared. Select individual files to share.',
      );
      return;
    }
    if (docs.isNotEmpty && folderList.isNotEmpty) {
      AppDialogs.showSnackError(
        'Folders skipped. Sharing ${docs.length} document${docs.length > 1 ? 's' : ''} only.',
      );
    }
    if (docs.isEmpty) {
      AppDialogs.showSnackError('No documents selected to share.');
      return;
    }

    AppLoader.show(message: 'Preparing files...');
    try {
      final dir = await getTemporaryDirectory();
      final files = <XFile>[];
      for (final doc in docs) {
        final signedUrl = await SupabaseService.getSignedUrl(doc.fileUrl);
        final response = await http.get(Uri.parse(signedUrl));
        if (response.statusCode != 200) continue;
        final file = File('${dir.path}/${doc.documentId}.pdf');
        await file.writeAsBytes(response.bodyBytes);
        files.add(XFile(file.path, name: doc.name));
      }
      AppLoader.hide();
      if (files.isEmpty) {
        AppDialogs.showSnackError('Failed to prepare files for sharing.');
        return;
      }
      await SharePlus.instance.share(
        ShareParams(
          files: files,
          subject: files.length == 1
              ? files.first.name
              : '${files.length} documents from Scrivener',
        ),
      );
    } catch (_) {
      AppLoader.hide();
      AppDialogs.showSnackError('Failed to share. Please try again.');
    }
  }

  // Details

  void showSelectedDetails() {
    if (isSingleSelection) {
      final id = selectedIds.first;
      final pool = folderDocs.isNotEmpty ? folderDocs : documents;
      final doc = pool.firstWhereOrNull((d) => d.documentId == id);
      final folder = folders.firstWhereOrNull((f) => f.folderId == id);
      if (doc != null) {
        Get.bottomSheet(
          DocumentDetailsSheet(doc: doc),
          isScrollControlled: true,
        );
      } else if (folder != null) {
        Get.bottomSheet(
          FolderDetailsSheet(folder: folder),
          isScrollControlled: true,
        );
      }
    } else {
      Get.bottomSheet(
        MultiSelectionDetailsSheet(
          count: selectedCount,
          totalSizeMB: selectedTotalSizeMB,
        ),
        isScrollControlled: true,
      );
    }
  }
}
