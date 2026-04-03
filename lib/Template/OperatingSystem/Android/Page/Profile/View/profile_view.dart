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
                                color: Theme.of(context).scaffoldBackgroundColor,
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
                    ).colorScheme.onSurface.withOpacity(0.6),
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
          color: Theme.of(context).colorScheme.onSurface.withOpacity(0.45),
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
    final cs = Theme.of(context).colorScheme;
    return ListTile(
      onTap: onTap,
      leading: Icon(
        icon,
        color: iconColor ?? cs.onSurface.withOpacity(0.55),
        size: 22,
      ),
      title: Text(
        title,
        style: Theme.of(
          context,
        ).textTheme.titleSmall?.copyWith(color: titleColor ?? cs.onSurface),
      ),
      subtitle: subtitle != null
          ? Text(subtitle!, style: Theme.of(context).textTheme.bodySmall)
          : null,
      trailing:
          trailing ??
          (onTap != null
              ? Icon(
                  Icons.chevron_right,
                  color: cs.onSurface.withOpacity(0.35),
                  size: 20,
                )
              : null),
    );
  }
}
