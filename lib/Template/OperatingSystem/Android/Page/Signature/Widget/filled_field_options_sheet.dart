import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../../../Commons/Styles/style.dart';

class FilledFieldOptionsSheet extends StatelessWidget {
  final VoidCallback onChange;
  final VoidCallback onRemove;

  const FilledFieldOptionsSheet({
    super.key,
    required this.onChange,
    required this.onRemove,
  });

  static Future<void> show({
    required VoidCallback onChange,
    required VoidCallback onRemove,
  }) {
    return Get.bottomSheet(
      FilledFieldOptionsSheet(onChange: onChange, onRemove: onRemove),
      isScrollControlled: true,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(24, 12, 24, 32),
      decoration: AppStyle.bottomSheetDecoration(context),
      child: SafeArea(
        top: false,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Handle
            Center(
              child: Container(
                width: 40,
                height: 4,
                decoration: AppStyle.bottomSheetHandleOf(context),
              ),
            ),
            const SizedBox(height: 20),
            Text(
              'Field Options',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 16),

            // Change Button
            _OptionTile(
              icon: Icons.edit_outlined,
              label: 'Change',
              onTap: () {
                Get.back();
                onChange();
              },
            ),

            // Remove Button
            _OptionTile(
              icon: Icons.delete_outline,
              label: 'Remove',
              labelColor: Theme.of(context).colorScheme.error,
              onTap: () {
                Get.back();
                onRemove();
              },
            ),

            const SizedBox(height: 8),

            _OptionTile(
              icon: Icons.close,
              label: 'Cancel',
              onTap: () => Get.back(),
            ),
          ],
        ),
      ),
    );
  }
}

class _OptionTile extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;
  final Color? labelColor;

  const _OptionTile({
    required this.icon,
    required this.label,
    required this.onTap,
    this.labelColor,
  });

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final color = labelColor ?? cs.onSurface;

    return ListTile(
      contentPadding: EdgeInsets.zero,
      leading: SizedBox(
        width: 40,
        height: 40,
        child: Icon(icon, color: color, size: 28),
      ),
      title: Text(
        label,
        style: Theme.of(context).textTheme.titleSmall?.copyWith(color: color),
      ),
      onTap: onTap,
    );
  }
}
