import 'package:flutter/material.dart';
import '../../Utils/Constant/colors.dart';
import '../../Utils/Constant/enum.dart';
import '../../Utils/Formatters/formatter.dart';

class AppBadge extends StatelessWidget {
  final String label;
  final Color color;
  final Color surface;

  const AppBadge({
    super.key,
    required this.label,
    required this.color,
    required this.surface,
  });

  factory AppBadge.documentStatus({required DocumentStatus status}) {
    final colors = AppFormatter.documentStatusColors(status);
    return AppBadge(
      label: AppFormatter.documentStatus(status),
      color: colors.color as Color,
      surface: colors.surface as Color,
    );
  }

  factory AppBadge.signerStatus({required SignerStatus status}) {
    final Color color;
    final Color surface;
    switch (status) {
      case SignerStatus.pending:
        color = AppColors.signaturePending;
        surface = AppColors.signaturePendingSurface;
      case SignerStatus.signed:
        color = AppColors.signatureCompleted;
        surface = AppColors.signatureCompletedSurface;
      case SignerStatus.declined:
        color = AppColors.signatureDeclined;
        surface = AppColors.signatureDeclinedSurface;
    }
    return AppBadge(
      label: AppFormatter.signerStatus(status),
      color: color,
      surface: surface,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: surface,
        borderRadius: BorderRadius.circular(40),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: color,
          fontSize: 11,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}
