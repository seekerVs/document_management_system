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
import '../Widget/field_input_sheet.dart';
import '../Widget/signature_style_picker.dart';

class InAppSigningController extends GetxController {
  final InAppSigningRepository _repo = InAppSigningRepository();

  late SignatureRequestModel request;
  late SignerModel signer;

  // Text/date field values — fieldId -> value string
  final RxMap<String, String> fieldValues = <String, String>{}.obs;
  // Signature image bytes — fieldId -> PNG bytes
  final RxMap<String, Uint8List> signatureImages = <String, Uint8List>{}.obs;

  // Initialize with request and signer context
  void init(SignatureRequestModel req, SignerModel s) {
    request = req;
    signer = s;
    fieldValues.clear();
    signatureImages.clear();
  }

  List<SignatureFieldModel> get fields => signer.fields;

  // Check if a field has been filled
  bool isFieldFilled(String fieldId) =>
      fieldValues.containsKey(fieldId) || signatureImages.containsKey(fieldId);

  // All fields filled
  bool get allFieldsFilled => fields.every((f) => isFieldFilled(f.fieldId));

  // Color for filled vs unfilled field overlay
  Color fieldColor(String fieldId) =>
      isFieldFilled(fieldId) ? AppColors.success : AppColors.primary;

  // Route field tap to correct input
  void onFieldTap(SignatureFieldModel field) {
    switch (field.type) {
      case SignatureFieldType.signature:
      case SignatureFieldType.initials:
        SignatureStylePicker.show(
          name: signer.signerName,
          onConfirm: (bytes) => signatureImages[field.fieldId] = bytes,
        );
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
      AppDialogs.showSnackSuccess('Document signed successfully.');
      Get.until((route) => route.isFirst);
    } on AppException catch (e) {
      AppLoader.hide();
      AppDialogs.showSnackError(e.message);
    } catch (_) {
      AppLoader.hide();
      AppDialogs.showSnackError('Failed to submit. Please try again.');
    }
  }

  // Confirm decline then update Firestore
  void declineSigning() {
    AppDialogs.showConfirm(
      title: 'Decline to sign?',
      message: 'The document owner will be notified that you declined to sign.',
      confirmLabel: 'Decline',
      isDangerous: true,
      onConfirm: _submitDecline,
    );
  }

  // Submit decline to repository
  Future<void> _submitDecline() async {
    AppLoader.show(message: 'Submitting...');
    try {
      await _repo.submitDecline(
        requestId: request.requestId,
        signerEmail: signer.signerEmail,
        signerName: signer.signerName,
      );
      AppLoader.hide();
      AppDialogs.showSnackSuccess('You have declined to sign.');
      Get.until((route) => route.isFirst);
    } on AppException catch (e) {
      AppLoader.hide();
      AppDialogs.showSnackError(e.message);
    } catch (_) {
      AppLoader.hide();
      AppDialogs.showSnackError('Failed to submit. Please try again.');
    }
  }
}
