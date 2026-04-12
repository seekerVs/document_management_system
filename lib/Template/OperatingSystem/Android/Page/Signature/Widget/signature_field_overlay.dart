import 'package:flutter/material.dart';
import '../../../../../Utils/Constant/enum.dart';
import '../Model/signature_field_model.dart';
import '../Model/signature_request_model.dart';

class SignatureFieldOverlay extends StatelessWidget {
  final SignatureFieldModel field;
  final SignerModel signer;
  final Color color;
  final double canvasWidth;
  final double canvasHeight;
  final Widget? child;
  final VoidCallback? onTap;
  final VoidCallback? onDragStarted;
  final bool isSelected;
  final bool canDrag;

  const SignatureFieldOverlay({
    super.key,
    required this.field,
    required this.signer,
    required this.color,
    required this.canvasWidth,
    required this.canvasHeight,
    this.child,
    this.onTap,
    this.onDragStarted,
    this.isSelected = false,
    this.canDrag = false,
  });

  @override
  Widget build(BuildContext context) {
    // Use normalized coordinates from model directly
    final double left = field.x * canvasWidth;
    final double top = field.y * canvasHeight;

    return _buildField(context, left, top, isSelected, canDrag);
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

    // Max rendered field sizes in pixels — prevents fields from ballooning on large screens
    // Matching web signing logic
    // Max rendered field sizes in pixels — prevents fields from ballooning on large screens
    // Matching web signing logic
    const double maxSigW = 120.0;
    const double maxFieldW = 50.0;
    const double maxFieldH = 50.0;
    const double maxRectW = 100.0;
    const double maxRectH = 28.0;

    // Compute rendered size: normalized value * page dimension, clamped to a max
    final isSignature = field.type == SignatureFieldType.signature;
    final double maxWidth = isSignature
        ? maxSigW
        : (isRect ? maxRectW : maxFieldW);

    final double renderWidth = (field.width * canvasWidth).clamp(
      20.0,
      maxWidth,
    );
    final double renderHeight = (field.height * canvasHeight).clamp(
      20.0,
      isRect ? maxRectH : maxFieldH,
    );

    // Scale factor for internal UI elements (icons, text) relative to a 600px reference page
    final double placeholderScale = (canvasWidth / 600.0).clamp(0.5, 1.2);

    final isFilled = child != null || field.value != null;

    return Positioned(
      left: left,
      top: top,
      child: canDrag
          ? LongPressDraggable<String>(
              data: field.fieldId,
              dragAnchorStrategy: pointerDragAnchorStrategy,
              feedback: Material(
                color: Colors.transparent,
                child: Opacity(
                  opacity: 0.8,
                  child: _buildFieldContent(
                    context,
                    renderWidth,
                    renderHeight,
                    isFieldSelected,
                    placeholderScale,
                    isFilled,
                  ),
                ),
              ),
              childWhenDragging: Opacity(
                opacity: 0.3,
                child: _buildFieldContent(
                  context,
                  renderWidth,
                  renderHeight,
                  isFieldSelected,
                  placeholderScale,
                  isFilled,
                ),
              ),
              onDragStarted: onDragStarted,
              child: GestureDetector(
                onTap: onTap,
                child: _buildFieldContent(
                  context,
                  renderWidth,
                  renderHeight,
                  isFieldSelected,
                  placeholderScale,
                  isFilled,
                ),
              ),
            )
          : GestureDetector(
              onTap: onTap,
              child: _buildFieldContent(
                context,
                renderWidth,
                renderHeight,
                isSelected,
                placeholderScale,
                isFilled,
              ),
            ),
    );
  }

  Widget _buildFieldContent(
    BuildContext context,
    double renderWidth,
    double renderHeight,
    bool isFieldSelected,
    double placeholderScale,
    bool isFilled,
  ) {
    final isRect =
        field.type == SignatureFieldType.textbox ||
        field.type == SignatureFieldType.dateSigned;

    return Container(
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
          color: (isFieldSelected && !isFilled)
              ? Colors.white
              : (isFieldSelected
                    ? Theme.of(context).colorScheme.primary
                    : color),
          width: 2.0,
          style: (isFieldSelected || !isFilled)
              ? BorderStyle.solid
              : BorderStyle.none,
        ),
        boxShadow: isFieldSelected
            ? [
                BoxShadow(
                  color: color.withValues(alpha: isFilled ? 0.4 : 0.15),
                  blurRadius: 8,
                  spreadRadius: 2,
                ),
              ]
            : (isFilled
                  ? []
                  : [
                      BoxShadow(
                        color: Theme.of(
                          context,
                        ).colorScheme.shadow.withValues(alpha: 0.1),
                        blurRadius: 4,
                        offset: const Offset(0, 2),
                      ),
                    ]),
      ),
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          if (isFieldSelected && isFilled)
            Positioned.fill(
              child: Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: color, width: 2),
                ),
              ),
            ),
          child ??
              (isRect
                  ? Align(
                      alignment: Alignment.topLeft,
                      child: Padding(
                        padding: EdgeInsets.only(
                          left: 2 * placeholderScale,
                          top: 1 * placeholderScale,
                        ),
                        child: Text(
                          field.type == SignatureFieldType.textbox
                              ? 'Add Text'
                              : 'Date Signed',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: (8 * placeholderScale).clamp(7.0, 10.0),
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
                            size: (14 * placeholderScale).clamp(12.0, 20.0),
                          ),
                          SizedBox(height: 1 * placeholderScale),
                          Text(
                            field.type == SignatureFieldType.initials
                                ? 'Initial'
                                : 'Sign',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: (7 * placeholderScale).clamp(6.0, 10.0),
                              fontWeight: FontWeight.w300,
                            ),
                          ),
                        ],
                      ),
                    )),
        ],
      ),
    );
  }
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
