import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get/get.dart';
import '../../../../../Utils/Constant/colors.dart';
import '../../../../../Utils/Constant/images.dart';
import '../Controller/documents_controller.dart';

class StorageBanner extends GetView<DocumentsController> {
  const StorageBanner({super.key});

  @override
  Widget build(BuildContext context) {
    return Obx(
      () => Container(
        margin: const EdgeInsets.fromLTRB(16, 12, 16, 0),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: AppColors.storageBannerBg,
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
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 6),
                  // Progress bar
                  ClipRRect(
                    borderRadius: BorderRadius.circular(4),
                    child: LinearProgressIndicator(
                      value: controller.storagePercent.clamp(0.0, 1.0),
                      backgroundColor: Colors.white.withOpacity(0.6),
                      color: AppColors.primary,
                      minHeight: 6,
                    ),
                  ),
                  const SizedBox(height: 6),
                  // Free + items row
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        _freeLabel,
                        style: Theme.of(context).textTheme.labelSmall,
                      ),
                      Text(
                        '${controller.totalItems} items',
                        style: Theme.of(context).textTheme.labelSmall,
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
    return free >= 1024
        ? '${controller.freeStorageGB.toStringAsFixed(1)} GB free of 2 GB'
        : '${free.toStringAsFixed(0)} MB free of 2 GB';
  }
}
