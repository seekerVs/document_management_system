import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../../../Utils/Constant/colors.dart';
import '../../../../../Utils/Formatters/formatter.dart';
import '../../../../../Commons/Styles/style.dart';
import '../../../../../Commons/Widgets/app_avatar.dart';
import '../Controller/profile_controller.dart';

class ProfileView extends GetView<ProfileController> {
  const ProfileView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Profile'),
        leading: IconButton(
          icon: const Icon(Icons.chevron_left),
          onPressed: () => Get.back(),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Column(
                children: [
                  Stack(
                    children: [
                      Obx(
                        () => AppAvatar(
                          name: controller.displayName,
                          photoUrl: controller.photoUrl,
                          radius: 40,
                        ),
                      ),
                      Positioned(
                        right: 0,
                        bottom: 0,
                        child: GestureDetector(
                          onTap: () => controller.showChangePhoto(context),
                          child: Container(
                            padding: const EdgeInsets.all(6),
                            decoration: BoxDecoration(
                              color: Theme.of(context).colorScheme.primary,
                              shape: BoxShape.circle,
                              border: Border.all(
                                color: Theme.of(
                                  context,
                                ).scaffoldBackgroundColor,
                                width: 2,
                              ),
                            ),
                            child: const Icon(
                              Icons.camera_alt,
                              size: 16,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Obx(
                    () => Text(
                      controller.displayName,
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Obx(
                    () => Text(
                      controller.displayEmail,
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Obx(
                    () => Text(
                      'Member since ${AppFormatter.date(controller.user?.createdAt ?? DateTime.now())}',
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 32),

            const _SectionLabel(label: 'Account'),
            const SizedBox(height: 8),
            Container(
              decoration: AppStyle.cardOf(context),
              child: Column(
                children: [
                  _ProfileTile(
                    icon: Icons.person_outline,
                    title: 'Edit Name',
                    onTap: () => controller.showEditName(context),
                  ),
                  const Divider(height: 1, indent: 56),
                  _ProfileTile(
                    icon: Icons.lock_outline,
                    title: 'Change Password',
                    onTap: () => controller.showChangePassword(context),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),

            const _SectionLabel(label: 'Signatures & Initials'),
            const SizedBox(height: 8),
            Row(
              children: [
                Expanded(
                  child: Obx(
                    () => _SignatureCard(
                      title: 'Signature',
                      url: controller.signatureUrl,
                      onAdd: controller.addSignature,
                      onDelete: controller.deleteSignature,
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Obx(
                    () => _SignatureCard(
                      title: 'Initials',
                      url: controller.initialsUrl,
                      onAdd: controller.addInitials,
                      onDelete: controller.deleteInitials,
                    ),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 24),

            const _SectionLabel(label: 'Preferences'),
            const SizedBox(height: 8),
            Container(
              decoration: AppStyle.cardOf(context),
              child: Obx(
                () => SwitchListTile(
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 4,
                  ),
                  secondary: Icon(
                    Icons.dark_mode_outlined,
                    color: Theme.of(
                      context,
                    ).colorScheme.onSurface.withValues(alpha: 0.6),
                  ),
                  title: Text(
                    'Dark Mode',
                    style: Theme.of(context).textTheme.titleSmall,
                  ),
                  value: controller.isDarkMode.value,
                  activeThumbColor: Theme.of(context).colorScheme.primary,
                  onChanged: controller.toggleDarkMode,
                ),
              ),
            ),

            const SizedBox(height: 24),

            const _SectionLabel(label: 'Account Actions'),
            const SizedBox(height: 8),
            Container(
              decoration: AppStyle.cardOf(context),
              child: Column(
                children: [
                  _ProfileTile(
                    icon: Icons.logout,
                    title: 'Sign Out',
                    onTap: controller.signOut,
                  ),
                  const Divider(height: 1, indent: 56),
                  _ProfileTile(
                    icon: Icons.delete_forever_outlined,
                    title: 'Delete Account',
                    titleColor: AppColors.red,
                    iconColor: AppColors.red,
                    onTap: controller.deleteAccount,
                  ),
                ],
              ),
            ),

            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }
}

class _SectionLabel extends StatelessWidget {
  final String label;
  const _SectionLabel({required this.label});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(left: 4, bottom: 2),
      child: Text(
        label.toUpperCase(),
        style: Theme.of(context).textTheme.labelSmall?.copyWith(
          color: Theme.of(
            context,
          ).colorScheme.onSurface.withValues(alpha: 0.45),
          letterSpacing: 1,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}

class _ProfileTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final VoidCallback? onTap;
  final Color? titleColor;
  final Color? iconColor;

  const _ProfileTile({
    required this.icon,
    required this.title,
    this.onTap,
    this.titleColor,
    this.iconColor,
  });

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return ListTile(
      onTap: onTap,
      leading: Icon(
        icon,
        color: iconColor ?? cs.onSurface.withValues(alpha: 0.55),
        size: 22,
      ),
      title: Text(
        title,
        style: Theme.of(
          context,
        ).textTheme.titleSmall?.copyWith(color: titleColor ?? cs.onSurface),
      ),
      trailing: onTap != null
          ? Icon(
              Icons.chevron_right,
              color: cs.onSurface.withValues(alpha: 0.35),
              size: 20,
            )
          : null,
    );
  }
}

class _SignatureCard extends StatelessWidget {
  final String title;
  final String? url;
  final VoidCallback onAdd;
  final VoidCallback onDelete;

  const _SignatureCard({
    required this.title,
    this.url,
    required this.onAdd,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final hasSignature = url != null && url!.isNotEmpty;
    final cs = Theme.of(context).colorScheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: Theme.of(
            context,
          ).textTheme.bodySmall?.copyWith(fontWeight: FontWeight.w600),
        ),
        const SizedBox(height: 8),
        GestureDetector(
          onTap: hasSignature ? null : onAdd,
          child: Container(
            height: 100,
            width: double.infinity,
            decoration: BoxDecoration(
              color: hasSignature
                  ? cs.surface
                  : cs.surface.withValues(alpha: 0.5),
              borderRadius: BorderRadius.circular(12),
              border: hasSignature
                  ? Border.all(color: cs.outline.withValues(alpha: 0.2))
                  : null,
            ),
            child: Stack(
              children: [
                if (!hasSignature)
                  Positioned.fill(
                    child: CustomPaint(
                      painter: _DashedBorderPainter(
                        color: cs.onSurface.withValues(alpha: 0.3),
                        radius: 12,
                      ),
                      child: Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.add, color: cs.primary),
                            const SizedBox(height: 4),
                            Text(
                              'Add $title',
                              style: TextStyle(
                                fontSize: 12,
                                color: cs.primary,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  )
                else
                  Positioned.fill(
                    child: Padding(
                      padding: const EdgeInsets.all(12),
                      child: Image.network(
                        url!,
                        fit: BoxFit.contain,
                        loadingBuilder: (context, child, progress) {
                          if (progress == null) return child;
                          return const Center(
                            child: CircularProgressIndicator(strokeWidth: 2),
                          );
                        },
                        errorBuilder: (context, error, stackTrace) {
                          return const Center(child: Icon(Icons.error_outline));
                        },
                      ),
                    ),
                  ),

                if (hasSignature)
                  Positioned(
                    top: 4,
                    right: 4,
                    child: InkWell(
                      onTap: onDelete,
                      borderRadius: BorderRadius.circular(20),
                      child: Container(
                        padding: const EdgeInsets.all(4),
                        decoration: BoxDecoration(
                          color: AppColors.red.withValues(alpha: 0.1),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.delete_outline,
                          size: 16,
                          color: AppColors.red,
                        ),
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class _DashedBorderPainter extends CustomPainter {
  final Color color;
  final double radius;

  _DashedBorderPainter({required this.color, required this.radius});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = 1.5
      ..style = PaintingStyle.stroke;

    final path = Path()
      ..addRRect(
        RRect.fromRectAndRadius(
          Rect.fromLTWH(0, 0, size.width, size.height),
          Radius.circular(radius),
        ),
      );

    // Dash pattern
    const double dashWidth = 6;
    const double dashSpace = 4;

    final dashedPath = Path();
    for (var pathMetric in path.computeMetrics()) {
      double distance = 0.0;
      while (distance < pathMetric.length) {
        dashedPath.addPath(
          pathMetric.extractPath(distance, distance + dashWidth),
          Offset.zero,
        );
        distance += dashWidth + dashSpace;
      }
    }

    canvas.drawPath(dashedPath, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
