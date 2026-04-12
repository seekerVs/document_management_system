import 'package:get/get.dart';
import 'package:uuid/uuid.dart';
import '../../../../../Utils/Constant/enum.dart';
import '../../../../../Utils/Routes/main_routes.dart';
import '../Model/signature_field_model.dart';
import '../Model/signature_request_model.dart';
import 'signature_request_controller.dart';


import '../Widget/signature_field_guide_dialog.dart';

class SignaturePlacementController extends GetxController {
  final SignatureRequestController _requestController =
      Get.find<SignatureRequestController>();

  @override
  void onReady() {
    super.onReady();
    SignatureFieldGuideDialog.showIfNeeded();
  }

  String get currentUserEmail => _requestController.currentUserEmail;

  final RxInt activeSignerIndex = 0.obs;
  final RxnString selectedFieldId = RxnString();

  List<SignerModel> get activeSigners => _requestController.signers;

  SignerModel? get activeSigner {
    final signers = activeSigners;
    if (signers.isEmpty) return null;
    final index = activeSignerIndex.value.clamp(0, signers.length - 1);
    return signers[index];
  }

  List<({SignerModel signer, SignatureFieldModel field, int signerIndex})>
      get allFields {
    final result =
        <({SignerModel signer, SignatureFieldModel field, int signerIndex})>[];
    for (var i = 0; i < activeSigners.length; i++) {
      for (final field in activeSigners[i].fields) {
        result.add((signer: activeSigners[i], field: field, signerIndex: i));
      }
    }
    return result;
  }

  void switchSigner(int index) => activeSignerIndex.value = index;

  void addField(
    SignatureFieldType type,
    double pageWidth,
    double pageHeight,
    int pageIndex,
  ) {
    final signer = activeSigner;
    if (signer == null) return;

    final isRect = type == SignatureFieldType.textbox ||
        type == SignatureFieldType.dateSigned;
    final fieldW = isRect ? 50.0 : 32.0;
    final fieldH = isRect ? 22.0 : 32.0;

    final field = SignatureFieldModel(
      fieldId: const Uuid().v4(),
      type: type,
      page: pageIndex,
      x: ((pageWidth / 2) - (fieldW / 2)) / pageWidth,
      y: ((pageHeight / 2) - (fieldH / 2)) / pageHeight,
      width: fieldW / pageWidth,
      height: fieldH / pageHeight,
    );
    _updateSignerFields(signer, [...signer.fields, field]);
  }

  // Selection methods
  void selectField(String id) => selectedFieldId.value = id;
  void deselectField() => selectedFieldId.value = null;

  // Toggle selected field requirement status
  void toggleSelectedFieldRequired() {
    final id = selectedFieldId.value;
    if (id == null) return;
    for (final entry in allFields) {
      if (entry.field.fieldId == id) {
        final updated = entry.signer.fields
            .map(
              (f) =>
                  f.fieldId == id ? f.copyWith(isRequired: !f.isRequired) : f,
            )
            .toList();
        _updateSignerFields(entry.signer, updated);
        return;
      }
    }
  }

  // Edit selected field
  void changeSelectedFieldType(SignatureFieldType newType) {
    final id = selectedFieldId.value;
    if (id == null) return;
    for (final entry in allFields) {
      if (entry.field.fieldId == id) {
        final updated = entry.signer.fields
            .map((f) => f.fieldId == id ? f.copyWith(type: newType) : f)
            .toList();
        _updateSignerFields(entry.signer, updated);
        return;
      }
    }
  }

  // Reassign selected field to another signer
  void reassignField(String fieldId, int newSignerIndex) {
    if (newSignerIndex < 0 || newSignerIndex >= activeSigners.length) return;

    final targetSigner = activeSigners[newSignerIndex];
    SignatureFieldModel? targetField;
    SignerModel? originalSigner;

    for (final entry in allFields) {
      if (entry.field.fieldId == fieldId) {
        targetField = entry.field;
        originalSigner = entry.signer;
        break;
      }
    }

    if (targetField == null || originalSigner == null) return;
    if (originalSigner.signerEmail == targetSigner.signerEmail) return;

    final removedList =
        originalSigner.fields.where((f) => f.fieldId != fieldId).toList();
    _updateSignerFields(originalSigner, removedList);

    final addedList = [...targetSigner.fields, targetField];
    _updateSignerFields(targetSigner, addedList);

    update();
  }

  // Delete selected field
  void deleteSelectedField() {
    final id = selectedFieldId.value;
    if (id == null) return;
    for (final entry in allFields) {
      if (entry.field.fieldId == id) {
        final updated =
            entry.signer.fields.where((f) => f.fieldId != id).toList();
        _updateSignerFields(entry.signer, updated);
        deselectField();
        return;
      }
    }
  }

  // Delete field
  void deleteField(String fieldId, SignerModel signer) {
    final updated = signer.fields.where((f) => f.fieldId != fieldId).toList();
    _updateSignerFields(signer, updated);
  }

  // Move field to a different page (Drag & Drop)
  void moveFieldToPage(
    String fieldId,
    int newPageIndex,
    double normalizedX,
    double normalizedY,
  ) {
    SignatureFieldModel? targetField;
    SignerModel? owner;

    // 1. Find the field and its current owner
    for (final entry in allFields) {
      if (entry.field.fieldId == fieldId) {
        targetField = entry.field;
        owner = entry.signer;
        break;
      }
    }

    if (targetField == null || owner == null) return;

    // 2. Update model properties
    final updatedField = targetField.copyWith(
      page: newPageIndex,
      x: normalizedX,
      y: normalizedY,
    );

    // 3. Update the signer's field list
    final updatedList = owner.fields.map((f) {
      return f.fieldId == fieldId ? updatedField : f;
    }).toList();

    _updateSignerFields(owner, updatedList);

    // 4. Select the field on its new home
    selectField(fieldId);
    update();
  }

  // Proceed to review step
  void goToReview() => Get.toNamed(MainRoutes.requestReview);

  // Write updated fields back to parent controller
  void _updateSignerFields(
    SignerModel signer,
    List<SignatureFieldModel> fields,
  ) {
    final index = _requestController.signers.indexWhere(
      (s) => s.signerEmail == signer.signerEmail,
    );
    if (index == -1) return;
    _requestController.signers[index] = signer.copyWith(fields: fields);
  }
}
