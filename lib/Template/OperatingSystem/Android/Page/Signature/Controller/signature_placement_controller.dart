import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:uuid/uuid.dart';
import '../../../../../Utils/Constant/colors.dart';
import '../../../../../Utils/Constant/enum.dart';
import '../../../../../Utils/Routes/main_routes.dart';
import '../Model/signature_field_model.dart';
import '../Model/signature_request_model.dart';
import 'signature_request_controller.dart';

// Signer color palette — one color per signer index
const List<Color> _signerColors = [
  AppColors.blue,
  AppColors.green,
  AppColors.orange,
  AppColors.red,
];

class SignaturePlacementController extends GetxController {
  final SignatureRequestController _requestController =
      Get.find<SignatureRequestController>();
  String get currentUserEmail => _requestController.currentUserEmail;

  final RxInt activeSignerIndex = 0.obs;
  // Live drag positions tracked separately from model for performance
  final RxMap<String, ({double x, double y})> fieldPositions =
      <String, ({double x, double y})>{}.obs;
  final RxnString selectedFieldId = RxnString();

  List<SignerModel> get activeSigners => _requestController.signers;

  SignerModel? get activeSigner {
    final signers = activeSigners;
    if (signers.isEmpty) return null;
    // Clamp index in case it's stale from a previous session
    final index = activeSignerIndex.value.clamp(0, signers.length - 1);
    return signers[index];
  }

  // All fields across all signers flattened for rendering
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

  // Return color for a given signer index
  Color signerColor(int index) => _signerColors[index % _signerColors.length];

  // Switch active signer context
  void switchSigner(int index) => activeSignerIndex.value = index;

  // Add field at center of the active page
  void addField(
    SignatureFieldType type,
    double pageWidth,
    double pageHeight,
    int pageIndex,
  ) {
    final signer = activeSigner;
    if (signer == null) return;

    // Default dimensions: Textbox and Date are rectangles, others are small squares
    final isRect =
        type == SignatureFieldType.textbox ||
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
    // Note: No need to set fieldPositions here; the UI automatically calculates
    // the initial position from the model's normalized coordinates.
    _updateSignerFields(signer, [...signer.fields, field]);
  }

  // Update live position on drag
  void updateFieldPosition(
    String fieldId,
    double dx,
    double dy,
    double pageWidth,
    double pageHeight,
  ) {
    final field = allFields
        .firstWhereOrNull((e) => e.field.fieldId == fieldId)
        ?.field;
    if (field == null) return;

    final current = fieldPositions[fieldId];
    // Fallback: If no live position exists, start from model position
    final startX = current?.x ?? field.x * pageWidth;
    final startY = current?.y ?? field.y * pageHeight;

    final newX = (startX + dx).clamp(
      0.0,
      pageWidth - (field.width * pageWidth),
    );
    final newY = (startY + dy).clamp(
      0.0,
      pageHeight - (field.height * pageHeight),
    );
    fieldPositions[fieldId] = (x: newX, y: newY);
  }

  // Commit position to model after drag ends
  void commitFieldPosition(
    String fieldId,
    SignerModel signer,
    double pageWidth,
    double pageHeight,
  ) {
    final pos = fieldPositions[fieldId];
    if (pos == null) return;

    // Find correctly typed dimensions
    final field = signer.fields.firstWhereOrNull((f) => f.fieldId == fieldId);
    if (field == null) return;

    final updated = signer.fields.map((f) {
      if (f.fieldId != fieldId) return f;
      return f.copyWith(x: pos.x / pageWidth, y: pos.y / pageHeight);
    }).toList();

    _updateSignerFields(signer, updated);

    // CRITICAL: Remove the temporary pixel position after committing to the model.
    // This allows the UI to return to using the model's normalized (and now updated) coordinates.
    fieldPositions.remove(fieldId);
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
        // Adjust dimensions based on new type — note: normalized width handles this later

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

    // 1. Find the field and its current owner
    for (final entry in allFields) {
      if (entry.field.fieldId == fieldId) {
        targetField = entry.field;
        originalSigner = entry.signer;
        break;
      }
    }

    if (targetField == null || originalSigner == null) return;
    if (originalSigner.signerEmail == targetSigner.signerEmail) return;

    // 2. Remove from original signer
    final removedList = originalSigner.fields
        .where((f) => f.fieldId != fieldId)
        .toList();
    _updateSignerFields(originalSigner, removedList);

    // 3. Add to new signer
    final addedList = [...targetSigner.fields, targetField];
    _updateSignerFields(targetSigner, addedList);

    // Refresh UI
    update();
  }

  // Delete selected field
  void deleteSelectedField() {
    final id = selectedFieldId.value;
    if (id == null) return;
    for (final entry in allFields) {
      if (entry.field.fieldId == id) {
        fieldPositions.remove(id);
        final updated = entry.signer.fields
            .where((f) => f.fieldId != id)
            .toList();
        _updateSignerFields(entry.signer, updated);
        deselectField();
        return;
      }
    }
  }

  // Legacy delete
  void deleteField(String fieldId, SignerModel signer) {
    fieldPositions.remove(fieldId);
    final updated = signer.fields.where((f) => f.fieldId != fieldId).toList();
    _updateSignerFields(signer, updated);
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
