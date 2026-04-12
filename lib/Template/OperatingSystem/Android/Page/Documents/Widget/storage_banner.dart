import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get/get.dart';
import '../../../../../Utils/Constant/images.dart';
import '../Controller/documents_controller.dart';

class StorageBanner extends GetView<DocumentsController> {
  const StorageBanner({super.key});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Obx(
      () => Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: cs.tertiaryContainer,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: [
            // Cloud image asset
            SvgPicture.asset(AppImages.cloudStorage),
            const SizedBox(width: 14),
            // Info column
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    'Cloud Storage',
                    style: Theme.of(context).textTheme.titleSmall?.copyWith(
                      color: cs.onTertiaryContainer,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 6),
                  // Progress bar
                  ClipRRect(
                    borderRadius: BorderRadius.circular(4),
                    child: LinearProgressIndicator(
                      value: controller.storagePercent.clamp(0.0, 1.0),
                      backgroundColor: cs.onTertiaryContainer.withValues(alpha: 0.1),
                      color: cs.primary,
                      minHeight: 8,
                    ),
                  ),
                  const SizedBox(height: 6),
                  // Free + items row
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        _freeLabel,
                        style: Theme.of(context).textTheme.labelSmall?.copyWith(
                          color: cs.onTertiaryContainer.withValues(alpha: 0.5),
                        ),
                      ),
                      Text(
                        '${controller.totalItems} items',
                        style: Theme.of(context).textTheme.labelSmall?.copyWith(
                          color: cs.onTertiaryContainer.withValues(alpha: 0.5),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  String get _freeLabel {
    final free = controller.freeStorageMB;
    final freeGB = controller.freeStorageGB;
    return free >= 1024
        ? '${freeGB.toStringAsFixed(2)} GB free of 2 GB'
        : '${free.toStringAsFixed(1)} MB free of 2 GB';
  }
}
