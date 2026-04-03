import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
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
      return CachedNetworkImage(
        imageUrl: photoUrl!,
        imageBuilder: (context, imageProvider) => CircleAvatar(
          radius: radius,
          backgroundImage: imageProvider,
          backgroundColor: AppColors.backgroundGrey,
        ),
        placeholder: (context, url) => CircleAvatar(
          radius: radius,
          backgroundColor: AppColors.backgroundGrey,
          child: const SizedBox(
            width: 20,
            height: 20,
            child: CircularProgressIndicator(strokeWidth: 2),
          ),
        ),
        errorWidget: (context, url, error) => _buildInitials(),
      );
    }

    return _buildInitials();
  }

  Widget _buildInitials() {
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
