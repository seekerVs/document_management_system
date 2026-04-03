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
  final SignaturePlacementController controller;
  final double canvasWidth;
  final double canvasHeight;

  const SignatureFieldOverlay({
    super.key,
    required this.field,
    required this.signer,
    required this.color,
    required this.controller,
    required this.canvasWidth,
    required this.canvasHeight,
  });

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final pos = controller.fieldPositions[field.fieldId];
      final isSelected = controller.selectedFieldId.value == field.fieldId;
      final isRect = field.type == SignatureFieldType.textbox || field.type == SignatureFieldType.dateSigned;

      // Use normalized coordinates from model, or live pixels from controller if dragging
      final double left = pos != null ? pos.x : field.x * canvasWidth;
      final double top = pos != null ? pos.y : field.y * canvasHeight;
      final double renderWidth = field.width * canvasWidth;
      final double renderHeight = field.height * canvasHeight;

      return Positioned(
        left: left,
        top: top,
        child: Listener(
          onPointerDown: (_) {
            // Claim victory over the scroll view immediately
            controller.selectField(field.fieldId);
          },
          child: GestureDetector(
            onTap: () => controller.selectField(field.fieldId),
            onPanUpdate: (d) {
              controller.updateFieldPosition(
                field.fieldId,
                d.delta.dx,
                d.delta.dy,
                canvasWidth,
                canvasHeight,
              );
            },
            onPanEnd: (_) =>
                controller.commitFieldPosition(field.fieldId, signer, canvasWidth, canvasHeight),
            child: Container(
              width: renderWidth,
              height: renderHeight,
              decoration: BoxDecoration(
                color: field.isRequired ? color : color.withOpacity(0.5),
                borderRadius: BorderRadius.circular(4),
                border: Border.all(
                  color: isSelected ? Colors.white : color,
                  width: isSelected ? 2.0 : 1.0,
                  style: (field.isRequired || isSelected)
                      ? BorderStyle.solid
                      : BorderStyle.none,
                ),
                boxShadow: isSelected
                    ? [
                        BoxShadow(
                          color: color.withOpacity(0.4),
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
                children: [
                  // High contrast outer accent for selection
                  if (isSelected)
                    Positioned.fill(
                      child: Container(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: color),
                        ),
                      ),
                    ),
                  if (isRect)
                    Align(
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
                  else
                    Center(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            _fieldIcon(field.type),
                            color: Colors.white,
                            size: 14,
                          ),
                          const SizedBox(height: 1),
                          const Text(
                            'Sign',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 7,
                              fontWeight: FontWeight.w300,
                            ),
                          ),
                        ],
                      ),
                    ),
                ],
              ),
            ),
          ),
        ),
      );
    });
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
