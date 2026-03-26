import 'package:get/get.dart';
import '../Model/document_model.dart';
import '../Repository/document_repository.dart';
import '../../../../../../Template/Utils/Exceptions/exceptions.dart';
import '../../../../../../Template/Utils/Popups/dialog.dart';
import '../../../../../../Template/Utils/Routes/main_routes.dart';
import '../../../../../../Template/Utils/Services/supabase_service.dart';
import '../../Profile/Controller/user_controller.dart';
import '../../../../../Commons/Widgets/document_details_sheet.dart';

mixin DocumentsDocumentMixin on GetxController {
  DocumentRepository get docRepo;
  UserController get userController;
  RxList<DocumentModel> get documents;

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
    try {
      await docRepo.renameDocument(doc.documentId, name);
      final i = documents.indexWhere((d) => d.documentId == doc.documentId);
      if (i != -1) documents[i] = doc.copyWith(name: name);
    } on AppException catch (e) {
      AppDialogs.showSnackError(e.message);
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
