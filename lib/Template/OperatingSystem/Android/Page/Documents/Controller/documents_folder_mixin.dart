import 'package:get/get.dart';
import 'package:uuid/uuid.dart';
import '../Model/folder_model.dart';
import '../Repository/folder_repository.dart';
import '../Repository/document_repository.dart';
import '../../../../../../Template/Utils/Exceptions/exceptions.dart';
import '../../../../../../Template/Utils/Popups/dialog.dart';
import '../../../../../../Template/Utils/Routes/main_routes.dart';
import '../../../../../../Template/Utils/Services/supabase_service.dart';
import '../../Profile/Controller/user_controller.dart';

mixin DocumentsFolderMixin on GetxController {
  FolderRepository get folderRepo;
  DocumentRepository get docRepo;
  UserController get userController;
  RxList<FolderModel> get folders;

  Future<void> loadAll();

  // Create
  void showCreateFolderDialog() {
    AppDialogs.showInput(
      title: 'New Folder',
      hint: 'Folder name',
      confirmLabel: 'Create',
      onConfirm: (name) => _createFolder(name),
    );
  }

  Future<void> _createFolder(String name) async {
    try {
      final folder = FolderModel(
        folderId: const Uuid().v4(),
        ownerUid: docRepo.currentUid,
        name: name,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );
      await folderRepo.createFolder(folder);
      folders.insert(0, folder);
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
    try {
      await folderRepo.renameFolder(folder.folderId, name);
      final i = folders.indexWhere((f) => f.folderId == folder.folderId);
      if (i != -1) folders[i] = folder.copyWith(name: name);
    } on AppException catch (e) {
      AppDialogs.showSnackError(e.message);
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
      final folderDocs = await docRepo.getFolderDocuments(folder.folderId);
      for (final doc in folderDocs) {
        await docRepo.deleteDocument(doc.documentId);
        await SupabaseService.deleteFile(doc.fileUrl);
        await userController.decrementStorage(doc.fileSizeMB);
      }
      await folderRepo.deleteFolder(folder.folderId);
      folders.removeWhere((f) => f.folderId == folder.folderId);
      AppDialogs.showSnackSuccess('Folder deleted.');
    } on AppException catch (e) {
      AppDialogs.showSnackError(e.message);
    }
  }

  // Navigate
  void goToFolder(FolderModel folder) =>
      Get.toNamed(MainRoutes.folderContents, arguments: folder);
}
