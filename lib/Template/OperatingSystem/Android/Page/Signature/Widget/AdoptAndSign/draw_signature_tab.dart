import 'package:flutter/material.dart';
import 'package:signature/signature.dart';
import 'dashed_rect_painter.dart';

class DrawSignatureTab extends StatelessWidget {
  final SignatureController signatureController;

  const DrawSignatureTab({super.key, required this.signatureController});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(top: 24),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(4),
      ),
      child: CustomPaint(
        painter: DashedRectPainter(
          color: Theme.of(context).colorScheme.outline,
          strokeWidth: 2,
          gap: 5,
        ),
        child: Stack(
          children: [
            Padding(
              padding: const EdgeInsets.all(8),
              child: Text(
                'Draw your signature',
                style: Theme.of(context).textTheme.labelSmall?.copyWith(
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                    ),
              ),
            ),
            ClipRRect(
              borderRadius: BorderRadius.circular(4),
              child: Signature(
                controller: signatureController,
                backgroundColor: Colors.transparent,
              ),
            ),
            Positioned(
              top: 8,
              right: 8,
              child: InkWell(
                onTap: () => signatureController.clear(),
                child: Icon(
                  Icons.refresh_outlined,
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                  size: 24,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
