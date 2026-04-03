import 'package:flutter/material.dart';
import '../../Utils/Constant/colors.dart';

class AppErrorBox extends StatelessWidget {
  final String message;
  final _BoxType _type;

  const AppErrorBox({super.key, required this.message})
    : _type = _BoxType.error;
  const AppErrorBox.success({super.key, required this.message})
    : _type = _BoxType.success;
  const AppErrorBox.info({super.key, required this.message})
    : _type = _BoxType.info;

  @override
  Widget build(BuildContext context) {
    if (message.isEmpty) return const SizedBox.shrink();

    final Color bg;
    final Color textColor;
    final IconData icon;

    switch (_type) {
      case _BoxType.error:
        bg = AppColors.redLight;
        textColor = AppColors.red;
        icon = Icons.error_outline;
      case _BoxType.success:
        bg = AppColors.greenLight;
        textColor = AppColors.green;
        icon = Icons.check_circle_outline;
      case _BoxType.info:
        bg = AppColors.background;
        textColor = AppColors.textSecondary;
        icon = Icons.info_outline;
    }

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: textColor, size: 16),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              message,
              style: TextStyle(color: textColor, fontSize: 13, height: 1.4),
            ),
          ),
        ],
      ),
    );
  }
}

enum _BoxType { error, success, info }
