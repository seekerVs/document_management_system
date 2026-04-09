import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../../../Utils/Constant/enum.dart';
import '../Model/signature_field_model.dart';
import '../Model/signature_request_model.dart';
import '../Controller/signature_placement_controller.dart';

class SignatureFieldOverlay extends StatelessWidget {
  final SignatureFieldModel field;
  final SignerModel signer;
  final Color color;
  final SignaturePlacementController? controller;
  final double canvasWidth;
  final double canvasHeight;
  final Widget? child;
  final VoidCallback? onTap;
  final bool isSelected;

  const SignatureFieldOverlay({
    super.key,
    required this.field,
    required this.signer,
    required this.color,
    this.controller,
    required this.canvasWidth,
    required this.canvasHeight,
    this.child,
    this.onTap,
    this.isSelected = false,
  });

  @override
  Widget build(BuildContext context) {
    // If we have a controller, we reactive based on its state
    if (controller != null) {
      return Obx(() {
        final pos = controller!.fieldPositions[field.fieldId];
        final isFieldSelected =
            controller!.selectedFieldId.value == field.fieldId;

        // Use normalized coordinates from model, or live pixels from controller if dragging
        final double left = pos != null ? pos.x : field.x * canvasWidth;
        final double top = pos != null ? pos.y : field.y * canvasHeight;

        return _buildField(
          context,
          left,
          top,
          isFieldSelected,
          true, // canDrag
        );
      });
    }

    // Static mode (Signing)
    return _buildField(
      context,
      field.x * canvasWidth,
      field.y * canvasHeight,
      isSelected,
      false, // canDrag
    );
  }

  Widget _buildField(
    BuildContext context,
    double left,
    double top,
    bool isFieldSelected,
    bool canDrag,
  ) {
    final isRect =
        field.type == SignatureFieldType.textbox ||
        field.type == SignatureFieldType.dateSigned;

    final double renderWidth = field.width * canvasWidth;
    final double renderHeight = field.height * canvasHeight;

    final isFilled = child != null || field.value != null;

    return Positioned(
      left: left,
      top: top,
      // We don't specify width/height on Positioned so the child can grow
      child: Listener(
        onPointerDown: (_) {
          if (canDrag) controller?.selectField(field.fieldId);
        },
        child: GestureDetector(
          onTap: onTap ??
              () {
                if (canDrag) controller?.selectField(field.fieldId);
              },
          onPanUpdate: canDrag
              ? (d) {
                  controller?.updateFieldPosition(
                    field.fieldId,
                    d.delta.dx,
                    d.delta.dy,
                    canvasWidth,
                    canvasHeight,
                  );
                }
              : null,
          onPanEnd: canDrag
              ? (_) => controller?.commitFieldPosition(
                    field.fieldId,
                    signer,
                    canvasWidth,
                    canvasHeight,
                  )
              : null,
          child: Container(
            width: child == null ? renderWidth : null,
            height: child == null ? renderHeight : null,
            constraints: child == null
                ? null
                : BoxConstraints(
                    minWidth: renderWidth,
                    minHeight: renderHeight,
                    maxWidth: renderWidth,
                    maxHeight: renderHeight,
                  ),
            decoration: BoxDecoration(
              color: isFilled ? Colors.transparent : color,
              borderRadius: BorderRadius.circular(4),
              border: Border.all(
                color: isFieldSelected ? Colors.white : color,
                width: isFieldSelected ? (isFilled ? 1.0 : 2.0) : 1.0,
                style: (isFieldSelected || !isFilled)
                    ? BorderStyle.solid
                    : BorderStyle.none,
              ),
              boxShadow: isFieldSelected
                  ? [
                      BoxShadow(
                        color: color.withValues(alpha: 0.4),
                        blurRadius: 8,
                        spreadRadius: 2,
                      ),
                    ]
                  : [
                      const BoxShadow(
                        color: Colors.black12,
                        blurRadius: 4,
                        offset: Offset(0, 2),
                      ),
                    ],
            ),
            child: Stack(
              clipBehavior: Clip.none, // Allow expansion
              children: [
                // High contrast outer accent for selection
                if (isFieldSelected)
                  Positioned.fill(
                    child: Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(10), // Slightly larger than parent
                        border: Border.all(color: color, width: 2),
                      ),
                    ),
                  ),
                child ??
                    (isRect
                        ? Align(
                            alignment: Alignment.topLeft,
                            child: Padding(
                              padding: const EdgeInsets.only(left: 2, top: 1),
                              child: Text(
                                field.type == SignatureFieldType.textbox
                                    ? 'Add Text'
                                    : 'Date Signed',
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 8,
                                  fontWeight: FontWeight.w300,
                                  letterSpacing: -0.2,
                                ),
                              ),
                            ),
                          )
                        : Center(
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(
                                  _fieldIcon(field.type),
                                  color: Colors.white,
                                  size: 14,
                                ),
                                const SizedBox(height: 1),
                                Text(
                                  field.type == SignatureFieldType.initials
                                      ? 'Initial'
                                      : 'Sign',
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 7,
                                    fontWeight: FontWeight.w300,
                                  ),
                                ),
                              ],
                            ),
                          )),
              ],
            ),
          ),
        ),
      ),
    );
  }

  IconData _fieldIcon(SignatureFieldType type) {
    switch (type) {
      case SignatureFieldType.signature:
        return Icons.draw_outlined;
      case SignatureFieldType.initials:
        return Icons.draw_outlined;
      case SignatureFieldType.dateSigned:
        return Icons.calendar_today_outlined;
      case SignatureFieldType.textbox:
        return Icons.text_snippet_outlined;
    }
  }
}
