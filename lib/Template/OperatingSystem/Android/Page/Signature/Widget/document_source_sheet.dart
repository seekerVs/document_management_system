import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import '../../../../../Commons/Styles/style.dart';
import '../../../../../Utils/Constant/colors.dart';
import '../../../../../Utils/Constant/images.dart';

class DocumentSourceSheet extends StatelessWidget {
  final VoidCallback onScan;
  final VoidCallback onDrive;
  final VoidCallback onPhotos;
  final VoidCallback onFiles;

  const DocumentSourceSheet({
    super.key,
    required this.onScan,
    required this.onDrive,
    required this.onPhotos,
    required this.onFiles,
  });

  // Show sheet with callbacks — works from any controller context
  static void show({
    required VoidCallback onScan,
    required VoidCallback onDrive,
    required VoidCallback onPhotos,
    required VoidCallback onFiles,
  }) {
    Get.bottomSheet(
      DocumentSourceSheet(
        onScan: onScan,
        onDrive: onDrive,
        onPhotos: onPhotos,
        onFiles: onFiles,
      ),
      isScrollControlled: true,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(24, 12, 24, 32),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Center(
            child: Container(
              width: 40,
              height: 4,
              decoration: AppStyle.bottomSheetHandle,
            ),
          ),
          const SizedBox(height: 20),
          Text(
            'Select a Document',
            style: Theme.of(context).textTheme.titleMedium,
          ),
          const SizedBox(height: 16),
          _SourceTile(
            icon: Icons.document_scanner_outlined,
            label: 'Scan',
            onTap: () {
              Get.back();
              onScan();
            },
          ),
          _SourceTile(
            svgAsset: AppImages.iconGoogleDrive,
            label: 'Drive',
            subtitle: 'Coming soon',
            onTap: () {
              Get.back();
              onDrive();
            },
            disabled: true,
          ),
          _SourceTile(
            icon: Icons.photo_outlined,
            label: 'Photos',
            subtitle: 'Coming soon',
            onTap: () {
              Get.back();
              onPhotos();
            },
            disabled: true,
          ),
          _SourceTile(
            icon: Icons.folder_outlined,
            label: 'Files',
            onTap: () {
              Get.back();
              onFiles();
            },
          ),
        ],
      ),
    );
  }
}

class _SourceTile extends StatelessWidget {
  final IconData? icon;
  final String? svgAsset;
  final String label;
  final String? subtitle;
  final VoidCallback onTap;
  final bool disabled;

  const _SourceTile({
    this.icon,
    this.svgAsset,
    required this.label,
    this.subtitle,
    required this.onTap,
    this.disabled = false,
  }) : assert(icon != null || svgAsset != null);

  @override
  Widget build(BuildContext context) {
    final color = disabled ? AppColors.textDisabled : AppColors.textPrimary;
    return ListTile(
      contentPadding: EdgeInsets.zero,
      enabled: !disabled,
      leading: SizedBox(
        width: 40,
        height: 40,
        child: Opacity(
          opacity: disabled ? 0.4 : 1.0,
          child: svgAsset != null
              ? SvgPicture.asset(svgAsset!, width: 28, height: 28)
              : Icon(icon, color: color, size: 28),
        ),
      ),
      title: Text(
        label,
        style: Theme.of(context).textTheme.titleSmall?.copyWith(color: color),
      ),
      subtitle: subtitle != null
          ? Text(
              subtitle!,
              style: Theme.of(
                context,
              ).textTheme.bodySmall?.copyWith(color: AppColors.textHint),
            )
          : null,
      onTap: disabled ? null : onTap,
    );
  }
}
