import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_doc_scanner/flutter_doc_scanner.dart';
import 'package:get/get.dart';
import 'package:path/path.dart' as p;
import '../../../../../Utils/Constant/enum.dart';
import '../../../../../Utils/Exceptions/exceptions.dart';
import '../../../../../Utils/Firebase/firebase_utils.dart';
import '../../../../../Utils/Popups/dialog.dart';
import '../../../../../Utils/Popups/full_screen_loader.dart';
import '../../../../../Utils/Routes/main_routes.dart';
import '../../../../../Utils/Services/supabase_service.dart';
import '../../Profile/Controller/user_controller.dart';
import '../Model/selected_document.dart';
import '../Model/signature_request_model.dart';
import '../Repository/signature_request_repository.dart';
import '../Widget/document_source_sheet.dart';

class SignatureRequestController extends GetxController {
  final UserController _userController = Get.find<UserController>();
  final SignatureRequestRepository _repo = SignatureRequestRepository();

  String get currentUserName => _userController.displayName;

  // Step 1 — document
  final Rx<SelectedDocument?> selectedDocument = Rx(null);

  // Step 2 — recipients
  final RxList<SignerModel> signers = <SignerModel>[].obs;
  final Rx<SignerRole> selectedRole = SignerRole.needsToSign.obs;
  final RxBool signingOrderEnabled = false.obs;
  final TextEditingController nameController = TextEditingController();
  final TextEditingController emailController = TextEditingController();

  // Step 4 — submission
  final RxString emailSubject = ''.obs;
  final RxString emailMessage = ''.obs;

  final TextEditingController subjectController = TextEditingController();
  final TextEditingController messageController = TextEditingController();

  final RxBool isSending = false.obs;

  // ─── Step 1 — Document selection ─────────────────────────────────────────

  // Open document source bottom sheet
  void showDocumentSourceSheet() {
    DocumentSourceSheet.show(
      onScan: scanDocument,
      onDrive: pickFromDrive,
      onPhotos: pickFromPhotos,
      onFiles: pickFromFiles,
    );
  }

  // Navigate to select document screen only if not already there
  void _goToSelectDocument() {
    if (Get.currentRoute != MainRoutes.selectDocument) {
      Get.toNamed(MainRoutes.selectDocument);
    }
  }

  // Launch camera scanner
  Future<void> scanDocument() async {
    try {
      final result = await FlutterDocScanner().getScannedDocumentAsPdf();
      if (result == null) return;
      final file = File(result.pdfUri);
      final name =
          'Scan ${DateTime.now().toString().substring(0, 16).replaceAll(':', '')}.pdf';
      final sizeBytes = await file.length();
      selectedDocument.value = SelectedDocument(
        name: name,
        file: file,
        sizeMB: sizeBytes / (1024 * 1024),
      );
      _goToSelectDocument();
    } catch (_) {
      AppDialogs.showSnackError('Could not complete scan.');
    }
  }

  // Pick PDF from file system
  Future<void> pickFromFiles() async {
    try {
      final result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['pdf'],
      );
      if (result == null || result.files.single.path == null) return;
      final path = result.files.single.path!;
      final file = File(path);
      final sizeBytes = await file.length();
      selectedDocument.value = SelectedDocument(
        name: p.basename(path),
        file: file,
        sizeMB: sizeBytes / (1024 * 1024),
      );
      
      // Initialize email subject with default
      emailSubject.value = 'Complete with DocuSign: ${selectedDocument.value?.name}';
      subjectController.text = emailSubject.value;
      
      _goToSelectDocument();
    } catch (_) {
      AppDialogs.showSnackError('Could not pick file.');
    }
  }

  // Google Drive — future integration
  Future<void> pickFromDrive() async =>
      AppDialogs.showSnackError('Google Drive integration coming soon.');

  // Photos — future integration
  Future<void> pickFromPhotos() async =>
      AppDialogs.showSnackError('Photos import coming soon.');

  // Confirm remove selected document
  void showSelectedDocumentOptions(SelectedDocument doc) {
    AppDialogs.showConfirm(
      title: 'Remove document?',
      message: 'This will clear the selected document.',
      confirmLabel: 'Remove',
      onConfirm: () => selectedDocument.value = null,
    );
  }

  // Proceed to recipients list
  void goToAddRecipients() => Get.toNamed(MainRoutes.recipientsList);

  // ─── Step 2 — Recipients ──────────────────────────────────────────────────

  // Pre-fill fields with current user info
  void assignToMe() {
    nameController.text = _userController.displayName;
    emailController.text = _userController.displayEmail;
  }

  // Validate and save recipient then go to list
  void saveRecipient() {
    final name = nameController.text.trim();
    final email = emailController.text.trim();

    if (name.isEmpty || email.isEmpty) {
      AppDialogs.showSnackError('Please fill in all fields.');
      return;
    }
    if (!GetUtils.isEmail(email)) {
      AppDialogs.showSnackError('Please enter a valid email.');
      return;
    }
    if (signers.any((s) => s.signerEmail == email)) {
      AppDialogs.showSnackError('This recipient has already been added.');
      return;
    }

    signers.add(
      SignerModel(
        signerName: name,
        signerEmail: email,
        role: selectedRole.value,
        order: signers.length,
      ),
    );

    _clearRecipientForm();
    Get.toNamed(MainRoutes.recipientsList);
  }

  // Navigate to add recipient form
  void goToAddRecipient() {
    _clearRecipientForm();
    Get.toNamed(MainRoutes.addRecipient);
  }

  // Toggle signing order and reassign order values
  void toggleSigningOrder(bool value) {
    signingOrderEnabled.value = value;
    if (value) _reassignOrder();
  }

  // Reorder signers via drag
  void reorderSigners(int oldIndex, int newIndex) {
    if (newIndex > oldIndex) newIndex -= 1;
    final item = signers.removeAt(oldIndex);
    signers.insert(newIndex, item);
    _reassignOrder();
  }

  // Show signer ⋮ options
  void showSignerOptions(SignerModel signer) {
    AppDialogs.showConfirm(
      title: 'Remove recipient?',
      message: '${signer.signerName} will be removed from this request.',
      confirmLabel: 'Remove',
      onConfirm: () {
        signers.removeWhere((s) => s.signerEmail == signer.signerEmail);
        _reassignOrder();
      },
    );
  }

  // Proceed to field placement
  void goToPlaceFields() => Get.toNamed(MainRoutes.signaturePlacement);

  // Proceed to review screen
  void goToReview() => Get.toNamed(MainRoutes.requestReview);

  // Upload document, create Firestore doc, then submit request
  Future<void> submitRequest() async {
    final doc = selectedDocument.value;
    if (doc == null) return;

    isSending.value = true;
    AppLoader.show(message: 'Uploading document...');

    try {
      final uid = FirebaseUtils.currentUid!;

      // Upload file to Supabase via Express
      final upload = await SupabaseService.uploadFile(
        filePath: doc.file.path,
        uid: uid,
        fileName: doc.name,
      );

      // Fetch signed URL so signers can view the PDF
      final signedUrl = await SupabaseService.getSignedUrl(upload.storagePath);

      AppLoader.updateMessage('Creating document...');

      // Create Firestore document record
      final docRef = FirebaseUtils.documentsRef.doc();
      final now = Timestamp.fromDate(DateTime.now());
      await docRef.set({
        'ownerUid': uid,
        'name': doc.name,
        'fileUrl': signedUrl,
        'storagePath': upload.storagePath,
        'fileType': 'pdf',
        'fileSizeMB': upload.fileSizeMB,
        'status': 'pending',
        'folderId': null,
        'createdAt': now,
        'updatedAt': now,
      });

      AppLoader.updateMessage('Sending request...');

      // Build model with real documentId and signed URL
      final request = SignatureRequestModel(
        requestId: '',
        documentId: docRef.id,
        documentName: doc.name,
        documentUrl: signedUrl,
        storagePath: upload.storagePath,
        requestedByUid: uid,
        signers: signers.toList(),
        signingOrderEnabled: signingOrderEnabled.value,
        createdAt: DateTime.now(),
      );

      await _repo.createRequest(request, _userController.displayName);

      AppLoader.hide();
      _clearAll();

      AppDialogs.showSnackSuccess('Signature request sent.');
      Get.until((route) => route.isFirst);
    } on AppException catch (e) {
      AppLoader.hide();
      AppDialogs.showSnackError(e.message);
    } catch (_) {
      AppLoader.hide();
      AppDialogs.showSnackError('Failed to send request. Please try again.');
    } finally {
      isSending.value = false;
    }
  }

  // Cancel and clear all request state
  void cancelRequest() {
    AppDialogs.showConfirm(
      title: 'Cancel request?',
      message: 'All progress will be lost.',
      confirmLabel: 'Cancel request',
      onConfirm: () {
        _clearAll();
        Get.until((route) => route.isFirst);
      },
    );
  }

  // ─── Helpers ──────────────────────────────────────────────────────────────

  // Reassign order values after reorder or removal
  void _reassignOrder() {
    for (var i = 0; i < signers.length; i++) {
      signers[i] = signers[i].copyWith(order: i);
    }
  }

  // Clear recipient form and reset role
  void _clearRecipientForm() {
    nameController.clear();
    emailController.clear();
    selectedRole.value = SignerRole.needsToSign;
  }

  // Clear all request state
  void _clearAll() {
    selectedDocument.value = null;
    signers.clear();
    signingOrderEnabled.value = false;
    emailSubject.value = '';
    emailMessage.value = '';
    subjectController.clear();
    messageController.clear();
    _clearRecipientForm();
  }
}
