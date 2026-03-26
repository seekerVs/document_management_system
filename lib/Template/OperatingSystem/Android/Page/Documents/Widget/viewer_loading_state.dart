import 'package:flutter/material.dart';

import '../../../../../Utils/Constant/colors.dart';

class ViewerLoadingState extends StatelessWidget {
  final bool isDark;
  const ViewerLoadingState({super.key, this.isDark = false});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const CircularProgressIndicator(color: AppColors.primary),
          const SizedBox(height: 16),
          Text(
            'Loading document...',
            style: TextStyle(
              color: isDark ? Colors.white54 : AppColors.textSecondary,
              fontSize: 13,
            ),
          ),
        ],
      ),
    );
  }
}
