import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../../../Utils/Constant/colors.dart';
import '../../../../../Utils/Constant/enum.dart';
import '../../../../../Utils/Exceptions/exceptions.dart';
import '../../../../../Utils/Firebase/firebase_utils.dart';
import '../../../../../Utils/Formatters/formatter.dart';
import '../../../../../Utils/Popups/dialog.dart';
import '../../../../../Utils/Popups/full_screen_loader.dart';
import '../../../../../Utils/Services/supabase_service.dart';
import '../Model/signature_field_model.dart';
import '../Model/signature_request_model.dart';
import '../Repository/in_app_signing_repository.dart';
import '../Widget/modern_signing_modal.dart';
import '../Widget/field_input_sheet.dart';
import '../Widget/filled_field_options_sheet.dart';
import 'package:image_picker/image_picker.dart';
import '../../Profile/Controller/user_controller.dart';
import 'package:http/http.dart' as http;

class InAppSigningController extends GetxController {
  final InAppSigningRepository _repo = InAppSigningRepository();

  // Static cache to allow resumption of signing sessions
  static final Map<String, Map<String, String>> _cachedFieldValues = {};
  static final Map<String, Map<String, Uint8List>> _cachedSignatureImages = {};
  static const int _templateDetectionMaxAttempts = 30;

  late SignatureRequestModel request;
  late SignerModel signer;

  // Text/date field values — fieldId -> value string
  final RxMap<String, String> fieldValues = <String, String>{}.obs;
  // Signature image bytes — fieldId -> PNG bytes
  final RxMap<String, Uint8List> signatureImages = <String, Uint8List>{}.obs;

  // New state for splash screen
  final RxBool showSplash = true.obs;
  final RxBool hasStartedManual = false.obs;
  final RxString footerLabel = 'Finish'.obs;

  final RxnString selectedFieldId = RxnString();

  bool _templateDetectionCompleted = false;
  Worker? _signatureTemplateWorker;
  Worker? _initialsTemplateWorker;

  // Initialize with request and signer context
  void init(SignatureRequestModel req, SignerModel s) {
    bool isAlreadyOpen = false;
    try {
      isAlreadyOpen = request.requestId == req.requestId;
    } catch (_) {
      isAlreadyOpen = false;
    }

    request = req;
    signer = s;
    showSplash.value = true;
    hasStartedManual.value = false;
    footerLabel.value = 'Finish';
    _templateDetectionCompleted = false;

    if (isAlreadyOpen) {
      // Keep current in-memory maps
    } else if (_cachedFieldValues.containsKey(req.requestId)) {
      // Restore from static cache
      fieldValues.assignAll(_cachedFieldValues[req.requestId]!);
      signatureImages.assignAll(_cachedSignatureImages[req.requestId]!);
      savedProfileSignature.value =
          null; // Reset profile template selection for new load
    } else {
      // Fresh start
      fieldValues.clear();
      signatureImages.clear();
      savedProfileSignature.value = null;

      // Auto-fill all "Date Signed" fields for the current signer
      for (final field in signer.fields) {
        if (field.type == SignatureFieldType.dateSigned) {
          fieldValues[field.fieldId] = AppFormatter.dateShort(DateTime.now());
        }
      }
    }

    _bindTemplateUrlListeners();
    _scheduleTemplateDetection();
  }

  @override
  void onClose() {
    _signatureTemplateWorker?.dispose();
    _initialsTemplateWorker?.dispose();
    super.onClose();
  }

  void onExit() {
    AppDialogs.showConfirm(
      title: 'Sign Later?',
      message:
          'Your progress will be saved. You can resume signing this document later from your tasks list.',
      confirmLabel: 'Sign Later',
      cancelLabel: 'Cancel',
      onConfirm: () {
        // Save to cache before leaving
        _cachedFieldValues[request.requestId] = Map.from(fieldValues);
        _cachedSignatureImages[request.requestId] = Map.from(signatureImages);

        Get.offAllNamed('/dashboard');
        AppDialogs.showSnackSuccess('Signing postponed. You can resume later.');
      },
    );
  }

  void beginSigning() {
    hasStartedManual.value = true;
    showSplash.value = false;
    _attemptTemplateDetection();
  }

  // Saved profile signature (drawn via onboarding draw pad)
  final Rx<Uint8List?> savedProfileSignature = Rx(null);

  void setSavedProfileSignature(Uint8List bytes) {
    savedProfileSignature.value = bytes;
  }

  Future<void> startSigningProcess() async {
    footerLabel.value = 'Continue Signing';

    if (!allFieldsFilled) {
      final firstUnfilled = fields.firstWhereOrNull(
        (f) => !isFieldFilled(f.fieldId),
      );
      if (firstUnfilled != null) {
        onFieldTap(firstUnfilled);
      }
    }
  }

  void _scheduleTemplateDetection() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _attemptTemplateDetection();
    });
  }

  Future<void> _attemptTemplateDetection({int attempt = 0}) async {
    if (_templateDetectionCompleted) return;

    if (showSplash.value || !hasStartedManual.value) {
      return;
    }

    if (!Get.isRegistered<UserController>()) {
      if (attempt >= _templateDetectionMaxAttempts) return;
      await Future.delayed(const Duration(milliseconds: 200));
      return _attemptTemplateDetection(attempt: attempt + 1);
    }

    if (_signatureTemplateWorker == null || _initialsTemplateWorker == null) {
      _bindTemplateUrlListeners();
    }

    final userCtrl = Get.find<UserController>();
    final signatureUrl = userCtrl.resolvedSignatureUrl.value;
    final initialsUrl = userCtrl.resolvedInitialsUrl.value;

    if (signatureUrl.isEmpty && initialsUrl.isEmpty) {
      if (attempt >= _templateDetectionMaxAttempts) {
        return;
      }

      await Future.delayed(const Duration(milliseconds: 200));
      return _attemptTemplateDetection(attempt: attempt + 1);
    }

    _templateDetectionCompleted = true;
    await checkAndApplyTemplates();
  }

  void _bindTemplateUrlListeners() {
    if (!Get.isRegistered<UserController>()) {
      return;
    }

    final userCtrl = Get.find<UserController>();

    _signatureTemplateWorker?.dispose();
    _initialsTemplateWorker?.dispose();

    _signatureTemplateWorker = ever<String>(
      userCtrl.resolvedSignatureUrl,
      (_) => _attemptTemplateDetection(),
    );
    _initialsTemplateWorker = ever<String>(
      userCtrl.resolvedInitialsUrl,
      (_) => _attemptTemplateDetection(),
    );
  }

  Future<void> checkAndApplyTemplates() async {
    if (!Get.isRegistered<UserController>()) {
      return;
    }

    final userCtrl = Get.find<UserController>();
    final signatureUrl = userCtrl.resolvedSignatureUrl.value;
    final initialsUrl = userCtrl.resolvedInitialsUrl.value;

    final hasSignatureTemplate = signatureUrl.isNotEmpty;
    final hasInitialsTemplate = initialsUrl.isNotEmpty;

    if (!hasSignatureTemplate && !hasInitialsTemplate) {
      return;
    }

    // Check if the document actually needs what we have, and only for fields not yet filled
    final needsSignature = fields.any(
      (f) => f.type == SignatureFieldType.signature && !isFieldFilled(f.fieldId),
    );
    final needsInitials = fields.any(
      (f) => f.type == SignatureFieldType.initials && !isFieldFilled(f.fieldId),
    );

    final hasFilledSignatureOrInitial = fields.any((f) =>
        (f.type == SignatureFieldType.signature || f.type == SignatureFieldType.initials) &&
        isFieldFilled(f.fieldId));

    // EDGE CASE: If they already have a signature or initial filled (e.g. from resuming a postponed session,
    // or adding one manually before network resolved the URL), DO NOT interrupt them with the prompt.
    if (hasFilledSignatureOrInitial) {
      return;
    }

    if ((hasSignatureTemplate && needsSignature) ||
        (hasInitialsTemplate && needsInitials)) {
      AppDialogs.showConfirm(
        title: 'Templates Detected',
        message:
            'We found saved templates in your profile. Would you like to apply them to the document fields?',
        confirmLabel: 'Yes',
        cancelLabel: 'No',
        onConfirm: () {
          _applyTemplatesFromProfile(signatureUrl, initialsUrl);
        },
      );
    }
  }

  Future<void> _applyTemplatesFromProfile(String sigUrl, String initUrl) async {
    AppLoader.show(message: 'Applying templates...');
    try {
      if (sigUrl.isNotEmpty) {
        final response = await http.get(Uri.parse(sigUrl));
        if (response.statusCode == 200) {
          final bytes = response.bodyBytes;
          for (final field in fields) {
            if (field.type == SignatureFieldType.signature) {
              signatureImages[field.fieldId] = bytes;
            }
          }
        }
      }

      if (initUrl.isNotEmpty) {
        final response = await http.get(Uri.parse(initUrl));
        if (response.statusCode == 200) {
          final bytes = response.bodyBytes;
          for (final field in fields) {
            if (field.type == SignatureFieldType.initials) {
              signatureImages[field.fieldId] = bytes;
            }
          }
        }
      }
      AppLoader.hide();
      footerLabel.value = 'Continue Signing';

      if (!allFieldsFilled) {
        final firstUnfilled = fields.firstWhereOrNull(
          (f) => !isFieldFilled(f.fieldId),
        );
        if (firstUnfilled != null) {
          onFieldTap(firstUnfilled);
        }
      }
    } catch (e) {
      AppLoader.hide();
      AppDialogs.showSnackError('Failed to apply templates: $e');
    }
  }

  Future<void> _applySingleTemplateToField(
    SignatureFieldModel field,
    String url,
  ) async {
    AppLoader.show(message: 'Applying template...');
    try {
      final response = await http.get(Uri.parse(url));
      if (response.statusCode == 200) {
        signatureImages[field.fieldId] = response.bodyBytes;
      }
      AppLoader.hide();
      footerLabel.value = 'Continue Signing';

      if (!allFieldsFilled) {
        final firstUnfilled = fields.firstWhereOrNull(
          (f) => !isFieldFilled(f.fieldId),
        );
        if (firstUnfilled != null) {
          onFieldTap(firstUnfilled);
        }
      }
    } catch (e) {
      AppLoader.hide();
      AppDialogs.showSnackError('Failed to apply template: $e');
    }
  }

  List<SignatureFieldModel> get fields => signer.fields;

  bool get anyRequiredFieldsEmpty =>
      fields.any((f) => f.isRequired && !isFieldFilled(f.fieldId));

  bool get anyOptionalFieldsEmpty =>
      fields.any((f) => !f.isRequired && !isFieldFilled(f.fieldId));

  void handleFinishAction() {
    if (anyRequiredFieldsEmpty) {
      AppDialogs.showConfirm(
        title: 'Required Fields',
        message:
            'Please fill in all required fields before you can finish signing.',
        confirmLabel: 'Next',
        cancelLabel: 'Cancel',
        onConfirm: () {
          startSigningProcess(); // This already jumps to next unfilled
        },
      );
      return;
    }

    if (anyOptionalFieldsEmpty) {
      AppDialogs.showConfirm(
        title: 'Optional Fields',
        message:
            'You have empty optional fields. Would you like to finish anyway?',
        confirmLabel: 'Finish',
        cancelLabel: 'Cancel',
        onConfirm: () {
          confirmSigning();
        },
      );
      return;
    }

    confirmSigning();
  }

  // Check if a field has been filled
  bool isFieldFilled(String fieldId) {
    fieldValues.length; // Touch RxMaps for GetX reactivity
    signatureImages.length;
    return fieldValues.containsKey(fieldId) ||
        signatureImages.containsKey(fieldId);
  }

  // All fields filled (that are required)
  bool get allFieldsFilled {
    return fields.every((f) => !f.isRequired || isFieldFilled(f.fieldId));
  }

  // Progress percentage
  double get progress {
    if (fields.isEmpty) return 0.0;
    final filled = fields.where((f) => isFieldFilled(f.fieldId)).length;
    return filled / fields.length;
  }

  // Color for filled vs unfilled field overlay
  Color fieldColor(String fieldId) =>
      isFieldFilled(fieldId) ? Colors.transparent : AppColors.blue;

  // Route field tap to correct input
  void onFieldTap(SignatureFieldModel field) {
    switch (field.type) {
      case SignatureFieldType.signature:
      case SignatureFieldType.initials:
        if (!isFieldFilled(field.fieldId)) {
          bool hasTemplate = false;
          String templateToken = '';
          if (Get.isRegistered<UserController>()) {
            final userCtrl = Get.find<UserController>();
            if (field.type == SignatureFieldType.signature) {
              templateToken = userCtrl.resolvedSignatureUrl.value;
            } else if (field.type == SignatureFieldType.initials) {
              templateToken = userCtrl.resolvedInitialsUrl.value;
            }
            hasTemplate = templateToken.isNotEmpty;
          }

          Get.dialog<String>(
            AppDialogBase(
              title: field.type == SignatureFieldType.signature
                  ? 'Add Signature'
                  : 'Add Initials',
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  ListTile(
                    leading: const Icon(Icons.edit_outlined),
                    title: Text(
                      field.type == SignatureFieldType.signature
                          ? 'Draw signature'
                          : 'Draw initials',
                    ),
                    onTap: () => Get.back(result: 'draw'),
                    contentPadding: EdgeInsets.zero,
                  ),
                  ListTile(
                    leading: const Icon(Icons.image_outlined),
                    title: const Text('Take photo'),
                    onTap: () => Get.back(result: 'photo'),
                    contentPadding: EdgeInsets.zero,
                  ),
                  ListTile(
                    leading: Icon(
                      Icons.auto_awesome_mosaic_outlined,
                      color: hasTemplate ? null : Colors.grey,
                    ),
                    title: Text(
                      'Use Template',
                      style: TextStyle(color: hasTemplate ? null : Colors.grey),
                    ),
                    onTap: hasTemplate
                        ? () => Get.back(result: 'template')
                        : null,
                    contentPadding: EdgeInsets.zero,
                  ),
                ],
              ),
              actions: [
                AppDialogAction(
                  label: 'Cancel',
                  onPressed: () => Get.back(),
                  isPrimary: false,
                ),
              ],
            ),
          ).then((value) {
            if (value == 'draw') {
              _openSigningModal(field);
            } else if (value == 'photo') {
              takePhoto(field: field);
            } else if (value == 'template') {
              _applySingleTemplateToField(field, templateToken);
            } else {
              footerLabel.value = 'Finish';
            }
          });
        } else {
          selectedFieldId.value = field.fieldId;
          FilledFieldOptionsSheet.show(
            onChange: () {
              selectedFieldId.value = null;
              _openSigningModal(field);
            },
            onRemove: () {
              selectedFieldId.value = null;
              signatureImages.remove(field.fieldId);
              fieldValues.remove(field.fieldId);
            },
          ).then((_) {
            // Clear if the user just dismisses the sheet (e.g. taps backdrop)
            if (selectedFieldId.value == field.fieldId) {
              selectedFieldId.value = null;
            }
          });
        }
      case SignatureFieldType.dateSigned:
        fieldValues[field.fieldId] = AppFormatter.dateShort(DateTime.now());
      case SignatureFieldType.textbox:
        FieldInputSheet.show(
          field: field,
          signerName: signer.signerName,
          onConfirm: (value) => fieldValues[field.fieldId] = value,
        );
    }
  }

  void _openSigningModal(SignatureFieldModel field) {
    ModernSigningModal.show(
      fieldType: field.type,
      onSave: (bytes) {
        if (bytes != null) {
          signatureImages[field.fieldId] = bytes;
          savedProfileSignature.value = bytes;
        }
      },
    );
  }

  Future<void> takePhoto({SignatureFieldModel? field}) async {
    try {
      final picker = ImagePicker();
      final XFile? image = await picker.pickImage(source: ImageSource.camera);
      if (image != null) {
        final bytes = await image.readAsBytes();
        savedProfileSignature.value = bytes;
        if (field != null) {
          signatureImages[field.fieldId] = bytes;
        }
        AppDialogs.showSnackSuccess('Photo captured successfully.');
      }
    } catch (e) {
      AppDialogs.showSnackError('Failed to take photo: $e');
    }
  }

  // Upload signatures and submit to Firestore
  Future<void> confirmSigning() async {
    if (!allFieldsFilled) {
      AppDialogs.showSnackError('Please fill in all fields before confirming.');
      return;
    }

    AppLoader.show(message: 'Saving your signature...');

    try {
      final uid = FirebaseUtils.currentUid ?? signer.signerEmail;

      // Upload signature images
      final uploadedImages = <String, String>{};
      for (final entry in signatureImages.entries) {
        final path = 'signatures/$uid/${request.requestId}/${entry.key}.png';
        final uploadResult = await SupabaseService.uploadBytes(
          bytes: entry.value,
          storagePath: path,
          fileName: '${entry.key}.png',
        );
        uploadedImages[entry.key] = uploadResult.storagePath;
      }

      // Build updated fields with committed values
      final updatedFields = fields.map((f) {
        if (uploadedImages.containsKey(f.fieldId)) {
          return f.copyWith(value: uploadedImages[f.fieldId]);
        }
        if (fieldValues.containsKey(f.fieldId)) {
          return f.copyWith(value: fieldValues[f.fieldId]);
        }
        return f;
      }).toList();

      AppLoader.updateMessage('Submitting...');

      await _repo.submitSigning(
        requestId: request.requestId,
        signerEmail: signer.signerEmail,
        signerName: signer.signerName,
        updatedFields: updatedFields,
        signatureImageUrl: uploadedImages.values.firstOrNull,
      );

      AppLoader.hide();
      AppDialogs.showSuccess(
        title: 'Document Signed!',
        message:
            'You have successfully completed the signing process. The document owner has been notified.',
        onDismiss: () {
          Get.offAllNamed('/dashboard');
        },
      );

      // Auto-redirect to dashboard after 2 seconds
      Future.delayed(const Duration(seconds: 2), () {
        if (Get.isDialogOpen ?? false) {
          Get.offAllNamed('/dashboard');
        }
      });
      // Auto-redirect to dashboard after a delay or let them click close
      // Given the user request, I'll ensure the flow is smooth.
      // SigningSuccessModal already has a Close button that goes to dashboard.
    } on AppException catch (e) {
      AppLoader.hide();
      AppDialogs.showSnackError(e.message);
    } catch (_) {
      AppLoader.hide();
      AppDialogs.showSnackError('Failed to submit. Please try again.');
    }
  }
}
