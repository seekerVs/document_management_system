import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_doc_scanner/flutter_doc_scanner.dart';
import 'package:get/get.dart';
import '../../../../../Utils/Constant/enum.dart';
import '../../../../../Utils/Exceptions/exceptions.dart';
import '../../../../../Utils/Firebase/firebase_utils.dart';
import '../../../../../Utils/Popups/dialog.dart';
import '../../../../../Utils/Popups/full_screen_loader.dart';
import '../../../../../Utils/Routes/main_routes.dart';
import '../../../../../Utils/Services/supabase_service.dart';
import '../../../../../Utils/Services/network_manager.dart';
import '../../../../../Commons/Styles/style.dart';
import '../../Profile/Controller/user_controller.dart';
import '../Model/selected_document.dart';
import '../Model/signature_request_model.dart';
import '../Repository/signature_request_repository.dart';
import '../../Profile/Repository/user_repository.dart';
import '../../../../../Commons/Widgets/document_source_sheet.dart';
import '../../../../../Commons/Widgets/app_text_field.dart';
import '../../Documents/Repository/folder_repository.dart';
import '../../Documents/Model/document_model.dart';
import '../Widget/library_picker_sheet.dart';
import 'in_app_signing_controller.dart';

class SignatureRequestController extends GetxController {
  final UserController _userController = Get.find<UserController>();
  final SignatureRequestRepository _repo = SignatureRequestRepository();

  String get currentUserName => _userController.displayName;
  String get currentUserEmail => _userController.displayEmail;

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
  final RxBool isScanning = false.obs;

  // ─── State Helpers ───────────────────────────────────────────────────────

  bool get hasProgress => selectedDocument.value != null || signers.isNotEmpty;

  bool get isRecipientFormDirty =>
      nameController.text.trim().isNotEmpty ||
      emailController.text.trim().isNotEmpty;

  // Called when user tries to go back to dashboard/exit the flow
  void onBackRequest({bool forceDialog = false}) {
    if (forceDialog || hasProgress) {
      cancelRequest();
    } else {
      Get.back();
    }
  }

  // Called when user tries to go back from Add Recipient
  void onAddRecipientBack() {
    if (isRecipientFormDirty) {
      AppDialogs.showConfirm(
        title: 'Discard recipient?',
        message: 'The details you entered will be lost.',
        confirmLabel: 'Discard',
        onConfirm: () {
          _clearRecipientForm();
          Get.back();
        },
      );
    } else {
      Get.back();
    }
  }

  // ─── Step 1 — Document selection ─────────────────────────────────────────

  // Open document source bottom sheet
  void showDocumentSourceSheet() {
    DocumentSourceSheet.show(
      onScan: scanDocument,
      onDrive: pickFromDrive,
      onPhotos: pickFromPhotos,
      onFiles: pickFromFiles,
      onLibrary: pickFromLibrary,
    );
  }

  // Navigate to select document screen only if not already there
  void _goToSelectDocument() {
    if (Get.currentRoute != MainRoutes.selectDocument) {
      Get.toNamed(MainRoutes.selectDocument);
    }
  }

  // Browse and pick from existing library docs
  void pickFromLibrary() {
    LibraryPickerSheet.show(
      onPick: (DocumentModel model) {
        selectedDocument.value = SelectedDocument(
          name: model.name,
          file: File(''), // Not needed for library docs
          sizeMB: model.fileSizeMB,
          documentId: model.documentId,
          storagePath: model.fileUrl,
        );

        emailSubject.value = 'Complete with DocuSign: ${model.name}';
        subjectController.text = emailSubject.value;

        _goToSelectDocument();
      },
    );
  }

  // Launch camera scanner
  Future<void> scanDocument() async {
    if (isScanning.value) return;

    try {
      NetworkManager.to.checkBeforeRequest();
      isScanning.value = true;
      debugPrint('SignatureRequestController: Starting document scan...');

      // We don't show loader yet as the scanner has its own UI
      final result = await FlutterDocScanner().getScannedDocumentAsPdf();
      debugPrint('SignatureRequestController: Scan result received: $result');

      if (result == null) {
        debugPrint(
          'SignatureRequestController: Scan cancelled or null result.',
        );
        isScanning.value = false;
        return;
      }

      // Show loader while we process the file and prepare the next screen
      AppLoader.show(message: 'Processing your scan...');

      // ─── URI Cleanup ────────────────────────────────────────────────────────
      // Handle both Object with pdfUri and Map with pdfUri (plugin version variance)
      String? cleanPath;
      try {
        final dynamic res = result;
        if (res is Map) {
          cleanPath = res['pdfUri']?.toString();
        } else {
          cleanPath = res.pdfUri?.toString();
        }
      } catch (e) {
        debugPrint('SignatureRequestController: Error extracting path: $e');
      }

      if (cleanPath == null || cleanPath.isEmpty) {
        throw Exception('Could not extract file path from scan result.');
      }

      if (cleanPath.startsWith('file://')) {
        cleanPath = cleanPath.replaceFirst('file://', '');
      }

      final file = File(cleanPath);

      // Verify file exists and is readable
      if (!await file.exists()) {
        throw Exception('Scanned file not found at: $cleanPath');
      }

      final name =
          'Scan ${DateTime.now().toString().substring(0, 16).replaceAll(':', '').replaceAll(' ', '_')}.pdf';
      final sizeBytes = await file.length();
      final sizeMB = sizeBytes / (1024 * 1024);

      AppLoader.hide();

      selectedDocument.value = SelectedDocument(
        name: name,
        file: file,
        sizeMB: sizeMB,
      );

      // Pre-fill email subject
      emailSubject.value =
          'Complete with DocuSign: ${selectedDocument.value?.name}';
      subjectController.text = emailSubject.value;

      _goToSelectDocument();
    } on NetworkException catch (e) {
      AppLoader.hide();
      AppDialogs.showSnackError(e.message);
    } catch (e) {
      AppLoader.hide();
      debugPrint('SignatureRequestController: Scan Error: $e');
      AppDialogs.showSnackError(
        'Could not complete scan: ${e.toString().replaceAll('Exception:', '')}',
      );
    } finally {
      AppLoader.hide();
      isScanning.value = false;
    }
  }

  // Pick PDF from file system
  Future<void> pickFromFiles() async {
    try {
      NetworkManager.to.checkBeforeRequest();
      final result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['pdf'],
      );
      if (result == null || result.files.single.path == null) return;
      final path = result.files.single.path!;
      final file = File(path);
      final sizeBytes = await file.length();
      final sizeMB = sizeBytes / (1024 * 1024);

      selectedDocument.value = SelectedDocument(
        name: result.files.single.name,
        file: file,
        sizeMB: sizeMB,
      );

      // Initialize email subject with default
      emailSubject.value =
          'Complete with DocuSign: ${selectedDocument.value?.name}';
      subjectController.text = emailSubject.value;

      _goToSelectDocument();
    } on NetworkException catch (e) {
      AppDialogs.showSnackError(e.message);
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
    final cs = Get.theme.colorScheme;
    Get.bottomSheet(
      Container(
        padding: const EdgeInsets.fromLTRB(24, 12, 24, 32),
        decoration: AppStyle.bottomSheetDecoration(Get.context!),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Center(
              child: Container(
                width: 40,
                height: 4,
                decoration: AppStyle.bottomSheetHandleOf(Get.context!),
              ),
            ),
            const SizedBox(height: 16),
            ListTile(
              contentPadding: EdgeInsets.zero,
              leading: Icon(Icons.edit_outlined, color: cs.onSurface),
              title: Text('Rename', style: TextStyle(color: cs.onSurface)),
              onTap: () {
                Get.back();
                _showRenameDialog(doc);
              },
            ),
            ListTile(
              contentPadding: EdgeInsets.zero,
              leading: Icon(Icons.delete_outline, color: cs.error),
              title: Text('Remove', style: TextStyle(color: cs.error)),
              onTap: () {
                Get.back();
                _showRemoveConfirmDialog();
              },
            ),
          ],
        ),
      ),
      isScrollControlled: true,
    );
  }

  void _showRenameDialog(SelectedDocument doc) {
    final controller = TextEditingController(text: doc.name);
    Get.dialog(
      AppDialogBase(
        title: 'Rename Document',
        content: AppTextField(
          controller: controller,
          hint: 'Enter document name',
          label: 'Document Name',
          autofocus: true,
        ),
        actions: [
          AppDialogAction(
            label: 'Cancel',
            onPressed: () => Get.back(),
            isPrimary: false,
          ),
          AppDialogAction(
            label: 'Save',
            onPressed: () {
              final newName = controller.text.trim();
              if (newName.isNotEmpty) {
                selectedDocument.value = doc.copyWith(name: newName);
              }
              Get.back();
            },
          ),
        ],
      ),
    );
  }

  void _showRemoveConfirmDialog() {
    AppDialogs.showConfirm(
      title: 'Remove document?',
      message: 'This will clear the selected document.',
      confirmLabel: 'Remove',
      onConfirm: () => selectedDocument.value = null,
    );
  }

  // Proceed to recipients list (or add recipient if none)
  void goToAddRecipients() {
    if (signers.isEmpty) {
      goToAddRecipient();
    } else {
      Get.toNamed(MainRoutes.recipientsList);
    }
  }

  // ─── Step 2 — Recipients ──────────────────────────────────────────────────

  // Pre-fill fields with current user info
  void assignToMe() {
    nameController.text = _userController.displayName;
    emailController.text = _userController.displayEmail;
    // Note: photoUrl will be handled by saveRecipient lookup or directly here
  }

  // Validate and save recipient then go to list
  Future<void> saveRecipient() async {
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

    String? photoUrl;
    String? signerUid;

    // Try to find if user exists to get their photo and UID
    try {
      final user = await UserRepository().getByEmail(email);
      if (user != null) {
        photoUrl = user.photoUrl;
        signerUid = user.uid;
      }
    } catch (e) {
      debugPrint('Error looking up recipient by email: $e');
    }

    signers.add(
      SignerModel(
        signerName: name,
        signerEmail: email,
        signerUid: signerUid,
        photoUrl: photoUrl,
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
      NetworkManager.to.checkBeforeRequest();

      final warning = NetworkManager.to.mobileDataWarning(
        fileSizeMB: doc.sizeMB,
      );
      if (warning != null) {
        bool proceed = false;
        await AppDialogs.showConfirm(
          title: 'Mobile Data Warning',
          message: warning,
          confirmLabel: 'Upload Anyway',
          onConfirm: () => proceed = true,
        );
        if (!proceed) {
          isSending.value = false;
          AppLoader.hide();
          return;
        }
      }

      final uid = FirebaseUtils.currentUid!;
      String finalStoragePath;
      String? finalDocId;

      if (doc.documentId != null && doc.storagePath != null) {
        // Case A: Library document — already uploaded
        finalStoragePath = doc.storagePath!;
        finalDocId = doc.documentId;
        AppLoader.updateMessage('Preparing document...');
      } else {
        AppLoader.updateMessage('Uploading document...');
        final upload = await SupabaseService.uploadFile(
          filePath: doc.file.path,
          uid: uid,
          fileName: doc.name,
        );
        finalStoragePath = upload.storagePath;

        AppLoader.updateMessage('Resolving destination...');
        final templatesFolderId =
            await FolderRepository().getOrCreateFolderByName('Templates');

        AppLoader.updateMessage('Creating document...');
        final docRef = FirebaseUtils.documentsRef.doc();
        final now = Timestamp.fromDate(DateTime.now());
        finalDocId = docRef.id;

        await docRef.set({
          'ownerUid': uid,
          'name': doc.name,
          'fileUrl': finalStoragePath,
          'storagePath': finalStoragePath,
          'fileType': 'pdf',
          'fileSizeMB': doc.sizeMB,
          'status': 'pending',
          'folderId': templatesFolderId,
          'authorizedEmails':
              signers.map((s) => s.signerEmail.toLowerCase()).toList(),
          'createdAt': now,
          'updatedAt': now,
        });
      }

      AppLoader.updateMessage('Sending request...');

      // Build model with current document reference
      final request = SignatureRequestModel(
        requestId: '',
        documentId: finalDocId!,
        documentName: doc.name,
        documentUrl: finalStoragePath,
        storagePath: finalStoragePath,
        requestedByUid: uid,
        requesterName: _userController.displayName,
        signers: signers.toList(),
        signerEmails: signers.map((s) => s.signerEmail.toLowerCase()).toList(),
        signingOrderEnabled: signingOrderEnabled.value,
        createdAt: DateTime.now(),
      );

      final requestId = await _repo.createRequest(
        request,
        _userController.displayName,
        requesterEmail: _userController.displayEmail,
        message: messageController.text.trim().isEmpty
            ? null
            : messageController.text.trim(),
      );

      // Check if current user is a signer to trigger in-app signing redirect
      final currentUserEmail = _userController.displayEmail.toLowerCase();
      final senderAsSigner = signers.firstWhereOrNull(
        (s) => s.signerEmail.toLowerCase() == currentUserEmail,
      );

      AppLoader.hide();

      if (senderAsSigner != null) {
        // Fetch the full request from Firestore to get IDs and any backend-generated tokens
        final doc = await FirebaseUtils.signatureRequestDoc(requestId).get();
        if (doc.exists) {
          final fullRequest = SignatureRequestModel.fromFirestore(doc);
          final signerModel = fullRequest.signers.firstWhere(
            (s) => s.signerEmail.toLowerCase() == currentUserEmail,
          );

          final signingController = Get.find<InAppSigningController>();
          signingController.init(fullRequest, signerModel);

          _clearAll();
          Get.offNamed(MainRoutes.inAppSigning);
          return;
        }
      }

      _clearAll();
      AppDialogs.showSnackSuccess('Signature request sent.');
      Get.until((route) => route.isFirst);
    } on AppException catch (e) {
      AppLoader.hide();
      AppDialogs.showSnackError(e.message);
    } catch (e) {
      AppLoader.hide();
      debugPrint('SignatureRequestController.submitRequest error: $e');
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
