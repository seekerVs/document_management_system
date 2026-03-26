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
            // ─── Avatar + name + email ───────────────────────────────────
            Center(
              child: Column(
                children: [
                  Obx(
                    () => AppAvatar(
                      name: controller.displayName,
                      photoUrl: controller.photoUrl,
                      radius: 40,
                    ),
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

            // ─── Account section ─────────────────────────────────────────
            const _SectionLabel(label: 'Account'),
            const SizedBox(height: 8),
            Container(
              decoration: AppStyle.card(),
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
                  const Divider(height: 1, indent: 56),
                  // Photo — disabled until Cloudinary is ready
                  const _ProfileTile(
                    icon: Icons.photo_camera_outlined,
                    title: 'Change Profile Photo',
                    subtitle: 'Coming soon',
                    trailing: Icon(
                      Icons.lock_outline,
                      size: 16,
                      color: AppColors.textHint,
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),

            // ─── Preferences section ─────────────────────────────────────
            const _SectionLabel(label: 'Preferences'),
            const SizedBox(height: 8),
            Container(
              decoration: AppStyle.card(),
              child: Obx(
                () => SwitchListTile(
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 4,
                  ),
                  secondary: const Icon(
                    Icons.dark_mode_outlined,
                    color: AppColors.textSecondary,
                  ),
                  title: Text(
                    'Dark Mode',
                    style: Theme.of(context).textTheme.titleSmall,
                  ),
                  value: controller.isDarkMode.value,
                  activeThumbColor: AppColors.primary,
                  onChanged: controller.toggleDarkMode,
                ),
              ),
            ),

            const SizedBox(height: 24),

            // ─── Danger section ──────────────────────────────────────────
            const _SectionLabel(label: 'Account Actions'),
            const SizedBox(height: 8),
            Container(
              decoration: AppStyle.card(),
              child: Column(
                children: [
                  _ProfileTile(
                    icon: Icons.logout,
                    title: 'Sign Out',
                    titleColor: AppColors.textPrimary,
                    iconColor: AppColors.textSecondary,
                    onTap: controller.signOut,
                  ),
                  const Divider(height: 1, indent: 56),
                  _ProfileTile(
                    icon: Icons.delete_forever_outlined,
                    title: 'Delete Account',
                    titleColor: AppColors.error,
                    iconColor: AppColors.error,
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

// ─── Section label ────────────────────────────────────────────────────────────

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
          color: AppColors.textHint,
          letterSpacing: 1,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}

// ─── Profile list tile ────────────────────────────────────────────────────────

class _ProfileTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final String? subtitle;
  final VoidCallback? onTap;
  final Color? titleColor;
  final Color? iconColor;
  final Widget? trailing;

  const _ProfileTile({
    required this.icon,
    required this.title,
    this.subtitle,
    this.onTap,
    this.titleColor,
    this.iconColor,
    this.trailing,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      onTap: onTap,
      leading: Icon(
        icon,
        color: iconColor ?? AppColors.textSecondary,
        size: 22,
      ),
      title: Text(
        title,
        style: Theme.of(
          context,
        ).textTheme.titleSmall?.copyWith(color: titleColor),
      ),
      subtitle: subtitle != null
          ? Text(subtitle!, style: Theme.of(context).textTheme.bodySmall)
          : null,
      trailing:
          trailing ??
          (onTap != null
              ? const Icon(
                  Icons.chevron_right,
                  color: AppColors.textHint,
                  size: 20,
                )
              : null),
    );
  }
}
