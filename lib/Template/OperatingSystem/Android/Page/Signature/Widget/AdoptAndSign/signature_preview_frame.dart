import 'package:flutter/material.dart';
import '../../../../../../Utils/Constant/enum.dart';

class SignaturePreviewFrame extends StatelessWidget {
  final String name;
  final String initials;
  final String font;
  final SignatureFieldType fieldType;
  final GlobalKey? captureKey;

  const SignaturePreviewFrame({
    super.key,
    required this.name,
    required this.initials,
    required this.font,
    required this.fieldType,
    this.captureKey,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          flex: 3,
          child: Align(
            alignment: Alignment.centerLeft,
            child: _buildSignatureOnly(context),
          ),
        ),
        const SizedBox(width: 16),
        Expanded(flex: 2, child: Align(child: _buildInitialsOnly(context))),
      ],
    );
  }

  Widget _buildSignatureOnly(BuildContext context) {
    final displayName = name.isEmpty ? 'Signature' : name;
    final colorScheme = Theme.of(context).colorScheme;

    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 8,
            decoration: BoxDecoration(
              border: Border(
                left: BorderSide(color: colorScheme.primary),
                top: BorderSide(color: colorScheme.primary),
                bottom: BorderSide(color: colorScheme.primary),
              ),
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(3),
                bottomLeft: Radius.circular(3),
              ),
            ),
          ),
          const SizedBox(width: 8),
          Flexible(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  'Signed by:',
                  style: Theme.of(context).textTheme.labelSmall?.copyWith(
                    color: colorScheme.onSurface,
                    fontWeight: FontWeight.bold,
                    fontSize: 10,
                  ),
                ),
                fieldType == SignatureFieldType.signature && captureKey != null
                    ? RepaintBoundary(
                        key: captureKey,
                        child: Text(
                          displayName,
                          style: TextStyle(
                            fontFamily: font,
                            fontSize: 24,
                            color: colorScheme.onSurface,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      )
                    : Text(
                        displayName,
                        style: TextStyle(
                          fontFamily: font,
                          fontSize: 24,
                          color: colorScheme.onSurface,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                Text(
                  'Digital ID Verified',
                  style: Theme.of(context).textTheme.labelSmall?.copyWith(
                    color: colorScheme.onSurfaceVariant,
                    fontSize: 8,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInitialsOnly(BuildContext context) {
    final displayInitials = initials.isEmpty ? 'Initial' : initials;
    final colorScheme = Theme.of(context).colorScheme;

    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 6,
            decoration: BoxDecoration(
              border: Border(
                left: BorderSide(color: colorScheme.primary),
                top: BorderSide(color: colorScheme.primary),
                bottom: BorderSide(color: colorScheme.primary),
              ),
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(2),
                bottomLeft: Radius.circular(2),
              ),
            ),
          ),
          const SizedBox(width: 8),
          Flexible(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  'Initials',
                  style: Theme.of(context).textTheme.labelSmall?.copyWith(
                    color: colorScheme.onSurface,
                    fontWeight: FontWeight.bold,
                    fontSize: 10,
                  ),
                ),
                fieldType == SignatureFieldType.initials && captureKey != null
                    ? RepaintBoundary(
                        key: captureKey,
                        child: Text(
                          displayInitials,
                          style: TextStyle(
                            fontFamily: font,
                            fontSize: 24,
                            color: colorScheme.onSurface,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      )
                    : Text(
                        displayInitials,
                        style: TextStyle(
                          fontFamily: font,
                          fontSize: 24,
                          color: colorScheme.onSurface,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
