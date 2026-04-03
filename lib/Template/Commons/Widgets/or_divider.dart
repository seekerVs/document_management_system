import 'package:flutter/material.dart';
import '../../Utils/Constant/colors.dart';

class OrDivider extends StatelessWidget {
  final String label;
  const OrDivider({super.key, this.label = 'Or'});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        const Expanded(
          child: Divider(color: AppColors.grey, thickness: 1),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Text(
            label,
            style: Theme.of(
              context,
            ).textTheme.bodyMedium?.copyWith(color: AppColors.textHint),
          ),
        ),
        const Expanded(
          child: Divider(color: AppColors.grey, thickness: 1),
        ),
      ],
    );
  }
}
