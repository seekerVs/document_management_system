import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../../../Commons/Widgets/app_button.dart';
import '../../../../../Utils/Services/storage_service.dart';
import 'field_move_animation.dart';

class SignatureFieldGuideDialog extends StatefulWidget {
  const SignatureFieldGuideDialog({super.key});

  static Future<void> showIfNeeded() async {
    if (StorageService.shouldShowFieldGuide()) {
      await Get.dialog(
        const SignatureFieldGuideDialog(),
        barrierDismissible: false,
      );
    }
  }

  @override
  State<SignatureFieldGuideDialog> createState() =>
      _SignatureFieldGuideDialogState();
}

class _SignatureFieldGuideDialogState extends State<SignatureFieldGuideDialog> {
  bool _dontShowAgain = false;
  
  @override
  void initState() {
    super.initState();
    _dontShowAgain = !StorageService.shouldShowFieldGuide();
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: const EdgeInsets.symmetric(horizontal: 24),
      child: Container(
        decoration: BoxDecoration(
          color: cs.surface,
          borderRadius: BorderRadius.circular(24),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.2),
              blurRadius: 20,
              offset: const Offset(0, 10),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Header
            Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                children: [
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: cs.primary.withValues(alpha: 0.1),
                      shape: BoxShape.circle,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Moving Fields',
                    style: textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                      letterSpacing: -0.5,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Learn how to position your signature fields exactly where you want them.',
                    textAlign: TextAlign.center,
                    style: textTheme.bodyMedium?.copyWith(
                      color: cs.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            ),

            // Animation Section
            const FieldMoveAnimation(),

            // Instructions
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 24, 24, 12),
              child: Column(
                children: [
                  _buildTip(
                    Icons.mouse,
                    'Long press',
                    'a field to pick it up.',
                    cs,
                    textTheme,
                  ),
                  const SizedBox(height: 12),
                  _buildTip(
                    Icons.swap_vert,
                    'Drag across edges',
                    'to move fields between pages.',
                    cs,
                    textTheme,
                  ),
                ],
              ),
            ),

            // Footer
            Padding(
              padding: const EdgeInsets.fromLTRB(12, 0, 24, 24),
              child: Column(
                children: [
                  Row(
                    children: [
                      Checkbox(
                        value: _dontShowAgain,
                        onChanged: (val) {
                          setState(() {
                            _dontShowAgain = val ?? false;
                          });
                        },
                        activeColor: cs.primary,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(4),
                        ),
                      ),
                      GestureDetector(
                        onTap: () {
                          setState(() {
                            _dontShowAgain = !_dontShowAgain;
                          });
                        },
                        child: Text(
                          "Don't show this again",
                          style: textTheme.bodySmall?.copyWith(
                            color: cs.onSurfaceVariant,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  AppButton.primary(
                    label: 'Got it',
                    onPressed: () async {
                      await StorageService.setFieldGuidePreference(!_dontShowAgain);
                      Get.back();
                    },
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTip(
    IconData icon,
    String boldText,
    String normalText,
    ColorScheme cs,
    TextTheme textTheme,
  ) {
    return Row(
      children: [
        Icon(icon, size: 18, color: cs.primary),
        const SizedBox(width: 12),
        Expanded(
          child: RichText(
            text: TextSpan(
              style: textTheme.bodyMedium,
              children: [
                TextSpan(
                  text: '$boldText ',
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                TextSpan(
                  text: normalText,
                  style: TextStyle(color: cs.onSurfaceVariant),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
