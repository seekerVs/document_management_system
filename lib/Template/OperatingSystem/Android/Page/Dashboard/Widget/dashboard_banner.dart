import 'package:document_management_system/Template/Utils/Constant/images.dart';
import 'package:flutter/material.dart';
import '../../../../../Utils/Constant/colors.dart';

class DashboardBanner extends StatelessWidget {
  const DashboardBanner({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(20, 0, 0, 0),
      decoration: BoxDecoration(
        color: AppColors.primary,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'New to Scrivener?',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    color: AppColors.textOnPrimary,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  'Create, sign, and notarize\ndocuments all in one simple app.',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: AppColors.textOnPrimary.withOpacity(0.9),
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  'Learn more →',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: AppColors.textOnPrimary,
                    fontWeight: FontWeight.w700,
                    decoration: TextDecoration.underline,
                    decorationColor: AppColors.textOnPrimary,
                  ),
                ),
              ],
            ),
          ),
          Container(
            width: 128.2,
            height: 150,
            decoration: BoxDecoration(borderRadius: BorderRadius.circular(12)),
            child: Image.asset(AppImages.phoneBanner),
          ),
        ],
      ),
    );
  }
}
