import 'package:flutter/material.dart';
import '../../Utils/Constant/colors.dart';
import '../../Utils/Formatters/formatter.dart';

class AppAvatar extends StatelessWidget {
  final String name;
  final String? photoUrl;
  final double radius;
  final Color? backgroundColor;

  const AppAvatar({
    super.key,
    required this.name,
    this.photoUrl,
    this.radius = 20,
    this.backgroundColor,
  });

  @override
  Widget build(BuildContext context) {
    if (photoUrl != null && photoUrl!.isNotEmpty) {
      return CircleAvatar(
        radius: radius,
        backgroundImage: NetworkImage(photoUrl!),
        backgroundColor: AppColors.backgroundGrey,
      );
    }

    return CircleAvatar(
      radius: radius,
      backgroundColor: backgroundColor ?? AppColors.primary,
      child: Text(
        AppFormatter.initials(name),
        style: TextStyle(
          color: AppColors.textOnPrimary,
          fontSize: radius * 0.7,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}
