import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../../../Commons/Widgets/app_button.dart';

class SigningSuccessModal extends StatelessWidget {
  const SigningSuccessModal({super.key});

  static void show() {
    Get.dialog(
      const SigningSuccessModal(),
      barrierDismissible: false,
    );
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.green.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.check_circle,
                color: Colors.green,
                size: 64,
              ),
            ),
            const SizedBox(height: 24),
            Text(
              'Document Signed!',
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 12),
            Text(
              'You have successfully completed the signing process. The document owner has been notified.',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: colorScheme.onSurfaceVariant,
                  ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 32),
            AppButton.primary(
              label: 'Close',
              onPressed: () {
                // Navigate back until first route (Dashboard)
                Get.until((route) => route.isFirst);
              },
            ),
          ],
        ),
      ),
    );
  }
}
