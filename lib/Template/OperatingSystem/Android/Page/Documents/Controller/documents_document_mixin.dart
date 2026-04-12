import 'package:get/get.dart';
import '../../../../../Utils/Helpers/helpers.dart';
import '../Model/document_model.dart';
import '../Model/folder_model.dart';
import '../Repository/document_repository.dart';
import '../../../../../../Template/Utils/Exceptions/exceptions.dart';
import '../../../../../../Template/Utils/Popups/dialog.dart';
import '../../../../../../Template/Utils/Routes/main_routes.dart';
import '../../../../../../Template/Utils/Services/supabase_service.dart';
import '../../Profile/Controller/user_controller.dart';
import '../../../../../Commons/Widgets/document_details_sheet.dart';
import '../../../../../../Template/Utils/Popups/full_screen_loader.dart';

mixin DocumentsDocumentMixin on GetxController {
  DocumentRepository get docRepo;
  UserController get userController;
  RxList<DocumentModel> get documents;
  RxList<FolderModel> get folders;
  RxList<DocumentModel> get searchResults;
  RxList<DocumentModel> get folderDocs;

  // Rename
  void showRenameDocumentDialog(DocumentModel doc) {
    final dotIndex = doc.name.lastIndexOf('.');
    final nameWithoutExt = dotIndex != -1
        ? doc.name.substring(0, dotIndex)
        : doc.name;
    final ext = dotIndex != -1 ? doc.name.substring(dotIndex) : '';

    AppDialogs.showInput(
      title: 'Rename Document',
      hint: 'Document name',
      initialValue: nameWithoutExt,
      confirmLabel: 'Rename',
      onConfirm: (name) => _renameDocument(doc, '${name.trim()}$ext'),
    );
  }

  Future<void> _renameDocument(DocumentModel doc, String name) async {
    final trimmedName = name.trim();
    if (trimmedName.isEmpty) return;
    if (trimmedName.toLowerCase() == doc.name.toLowerCase()) return;

    final existingNames = [
      ...documents.map((d) => d.name),
      ...folders.map((f) => f.name),
    ];

    if (AppHelpers.nameExists(trimmedName, existingNames)) {
      AppDialogs.showSnackError('An item with this name already exists.');
      return;
    }

    try {
      AppLoader.show(message: 'Renaming Document...');
      await docRepo.renameDocument(doc.documentId, trimmedName);
      final updatedDoc = doc.copyWith(name: trimmedName);

      _updateInList(documents, updatedDoc);
      _updateInList(searchResults, updatedDoc);
      _updateInList(folderDocs, updatedDoc);

      AppDialogs.showSnackSuccess('Document renamed.');
    } on AppException catch (e) {
      AppDialogs.showSnackError(e.message);
    } finally {
      AppLoader.hide();
    }
  }

  void _updateInList(RxList<DocumentModel> list, DocumentModel updated) {
    final i = list.indexWhere((d) => d.documentId == updated.documentId);
    if (i != -1) {
      list[i] = updated;
      list.refresh();
    }
  }

  // Delete

  void confirmDeleteDocument(DocumentModel doc) {
    AppDialogs.showDeleteConfirm(
      itemName: doc.name,
      onConfirm: () => _deleteDocument(doc),
    );
  }

  Future<void> _deleteDocument(DocumentModel doc) async {
    try {
      await docRepo.deleteDocument(doc.documentId);
      await SupabaseService.deleteFile(doc.fileUrl);
      documents.removeWhere((d) => d.documentId == doc.documentId);
      await userController.decrementStorage(doc.fileSizeMB);
      AppDialogs.showSnackSuccess('Document deleted.');
    } on AppException catch (e) {
      AppDialogs.showSnackError(e.message);
    }
  }

  // Open / Details

  void openDocument(DocumentModel doc) =>
      Get.toNamed(MainRoutes.documentViewer, arguments: doc);

  void showDocumentDetails(DocumentModel doc) {
    Get.bottomSheet(DocumentDetailsSheet(doc: doc), isScrollControlled: true);
  }
}
