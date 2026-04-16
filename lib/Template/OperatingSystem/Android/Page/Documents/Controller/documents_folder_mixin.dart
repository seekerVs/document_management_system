import 'package:get/get.dart';
import 'package:uuid/uuid.dart';
import '../Model/breadcrumb_segment.dart';
import '../../../../../Utils/Helpers/helpers.dart';
import '../Model/document_model.dart';
import '../Model/folder_model.dart';
import '../Repository/folder_repository.dart';
import '../Repository/document_repository.dart';
import '../../../../../../Template/Utils/Exceptions/exceptions.dart';
import '../../../../../../Template/Utils/Popups/dialog.dart';
import '../../../../../../Template/Utils/Routes/main_routes.dart';
import '../../../../../../Template/Utils/Services/supabase_service.dart';
import '../../../../../../Template/Utils/Popups/full_screen_loader.dart';
import '../../Profile/Controller/user_controller.dart';

mixin DocumentsFolderMixin on GetxController {
  FolderRepository get folderRepo;
  DocumentRepository get docRepo;
  UserController get userController;
  RxList<FolderModel> get folders;
  RxList<DocumentModel> get documents;

  RxList<DocumentModel> get folderDocs;
  RxList<FolderModel> get folderSubs;

  Future<void> loadAll();

  // Create
  void showCreateFolderDialog({String? parentId}) {
    AppDialogs.showInput(
      title: 'New Folder',
      hint: 'Folder name',
      confirmLabel: 'Create',
      onConfirm: (name) => _createFolder(name, parentId: parentId),
    );
  }

  Future<void> _createFolder(String name, {String? parentId}) async {
    try {
      final existingNames = [
        ...folders.map((f) => f.name),
        ...documents.map((d) => d.name),
      ];
      final resolvedName = AppHelpers.resolveUniqueName(name, existingNames);

      final folder = FolderModel(
        folderId: const Uuid().v4(),
        ownerUid: docRepo.currentUid,
        name: resolvedName,
        parentId: parentId,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );
      await folderRepo.createFolder(folder);
      if (parentId != null) {
        await folderRepo.updateItemCount(parentId, 1);
        folderSubs.insert(0, folder);
      } else {
        folders.insert(0, folder);
      }

      AppDialogs.showSnackSuccess('Folder created.');
    } on AppException catch (e) {
      AppDialogs.showSnackError(e.message);
    }
  }

  // Rename
  void showRenameFolderDialog(FolderModel folder) {
    AppDialogs.showInput(
      title: 'Rename Folder',
      hint: 'Folder name',
      initialValue: folder.name,
      confirmLabel: 'Rename',
      onConfirm: (name) => _renameFolder(folder, name),
    );
  }

  Future<void> _renameFolder(FolderModel folder, String name) async {
    final trimmedName = name.trim();
    if (trimmedName.isEmpty) return;
    if (trimmedName.toLowerCase() == folder.name.toLowerCase()) return;

    final existingNames = [
      ...folders.map((f) => f.name),
      ...documents.map((d) => d.name),
    ];

    if (AppHelpers.nameExists(trimmedName, existingNames)) {
      AppDialogs.showSnackError('An item with this name already exists.');
      return;
    }

    try {
      AppLoader.show(message: 'Renaming Folder...');
      await folderRepo.renameFolder(folder.folderId, trimmedName);

      final updatedFolder = folder.copyWith(name: trimmedName);

      // Update in root list if it exists there
      final i = folders.indexWhere((f) => f.folderId == folder.folderId);
      if (i != -1) {
        folders[i] = updatedFolder;
        folders.refresh();
      }

      // Update in subfolders list if it exists there
      final j = folderSubs.indexWhere((f) => f.folderId == folder.folderId);
      if (j != -1) {
        folderSubs[j] = updatedFolder;
        folderSubs.refresh();
      }

      AppDialogs.showSnackSuccess('Folder renamed.');
    } on AppException catch (e) {
      AppDialogs.showSnackError(e.message);
    } finally {
      AppLoader.hide();
    }
  }

  // Delete
  void confirmDeleteFolder(FolderModel folder) {
    AppDialogs.showDeleteConfirm(
      itemName: folder.name,
      onConfirm: () => _deleteFolder(folder),
    );
  }

  Future<void> _deleteFolder(FolderModel folder) async {
    try {
      AppLoader.show(message: 'Deleting folder and contents...');
      await _deleteFolderRecursive(folder.folderId);

      if (folder.parentId != null) {
        await folderRepo.updateItemCount(folder.parentId!, -1);
      }

      folders.removeWhere((f) => f.folderId == folder.folderId);
      folderSubs.removeWhere((f) => f.folderId == folder.folderId);

      AppDialogs.showSnackSuccess('Folder and its contents deleted.');
    } on AppException catch (e) {
      AppDialogs.showSnackError(e.message);
    } finally {
      AppLoader.hide();
    }
  }

  Future<void> _deleteFolderRecursive(String folderId) async {
    // 1. Delete documents in this folder
    final docs = await docRepo.getFolderDocuments(folderId);
    for (final doc in docs) {
      await docRepo.deleteDocument(doc.documentId);
      await SupabaseService.deleteFile(doc.fileUrl);
      await userController.decrementStorage(doc.fileSizeMB);
    }

    // 2. Find and delete subfolders recursively
    final subFolders = await folderRepo.getSubFolders(folderId);
    for (final sub in subFolders) {
      await _deleteFolderRecursive(sub.folderId);
    }

    // 3. Delete the folder itself
    await folderRepo.deleteFolder(folderId);
  }

  // Navigate
  void goToFolder(FolderModel folder, {List<BreadcrumbSegment>? trail}) {
    final newTrail = [
      ...?trail,
      if (trail == null) BreadcrumbSegment(name: 'My Documents'),
      BreadcrumbSegment(name: folder.name, folderId: folder.folderId),
    ];

    Get.toNamed(
      MainRoutes.folderContents,
      preventDuplicates: false,
      arguments: {'folder': folder, 'trail': newTrail},
    );
  }
}
