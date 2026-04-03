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
import '../../../../../Utils/Services/network_manager.dart';
import '../../../../../Commons/Styles/style.dart';
import '../../Profile/Controller/user_controller.dart';
import '../Model/selected_document.dart';
import '../Model/signature_request_model.dart';
import '../Repository/signature_request_repository.dart';
import '../../../../../Commons/Widgets/document_source_sheet.dart';

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

      selectedDocument.value = SelectedDocument(
        name: name,
        file: file,
        sizeMB: sizeBytes / (1024 * 1024),
      );

      // Pre-fill email subject
      emailSubject.value = 'Complete with DocuSign: $name';
      subjectController.text = emailSubject.value;

      AppLoader.hide();
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
      selectedDocument.value = SelectedDocument(
        name: p.basename(path),
        file: file,
        sizeMB: sizeBytes / (1024 * 1024),
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
              title: Text(
                'Remove',
                style: TextStyle(color: cs.error),
              ),
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
      AlertDialog(
        title: const Text('Rename Document'),
        content: TextField(
          controller: controller,
          decoration: const InputDecoration(
            labelText: 'Document Name',
            border: const OutlineInputBorder(),
          ),
          autofocus: true,
        ),
        actions: [
          TextButton(onPressed: Get.back, child: const Text('Cancel')),
          FilledButton(
            onPressed: () {
              final newName = controller.text.trim();
              if (newName.isNotEmpty) {
                selectedDocument.value = doc.copyWith(name: newName);
              }
              Get.back();
            },
            child: const Text('Save'),
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
      NetworkManager.to.checkBeforeRequest();

      final warning =
          NetworkManager.to.mobileDataWarning(fileSizeMB: doc.sizeMB);
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
      final signerEmails =
          signers.map((s) => s.signerEmail.toLowerCase()).toList();

      await docRef.set({
        'ownerUid': uid,
        'name': doc.name,
        'fileUrl':
            upload.storagePath, // FIXED: Save path, not 1-hour signed URL
        'storagePath': upload.storagePath,
        'fileType': 'pdf',
        'fileSizeMB': upload.fileSizeMB,
        'status': 'pending',
        'folderId': null,
        'authorizedEmails': signerEmails,
        'createdAt': now,
        'updatedAt': now,
      });

      AppLoader.updateMessage('Sending request...');

      // Build model with current document reference
      final request = SignatureRequestModel(
        requestId: '',
        documentId: docRef.id,
        documentName: doc.name,
        documentUrl: upload.storagePath,
        storagePath: upload.storagePath,
        requestedByUid: uid,
        requesterName: _userController.displayName,
        signers: signers.toList(),
        signerEmails: signers.map((s) => s.signerEmail.toLowerCase()).toList(),
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
