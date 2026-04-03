import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../Controller/documents_controller.dart';
import '../../../../../Commons/Styles/style.dart';

class FolderPickerSheet extends GetView<DocumentsController> {
  final void Function(String? folderId) onPick;
  final String title;
  final String? excludeFolderId;
  final bool excludeRoot;

  const FolderPickerSheet({
    super.key,
    required this.onPick,
    this.title = 'Copy to',
    this.excludeFolderId,
    this.excludeRoot = false,
  });

  static Future<void> show({
    required void Function(String? folderId) onPick,
    String title = 'Copy to',
    String? excludeFolderId,
    bool excludeRoot = false,
  }) => Get.bottomSheet(
    FolderPickerSheet(
      onPick: onPick,
      title: title,
      excludeFolderId: excludeFolderId,
      excludeRoot: excludeRoot,
    ),
    isScrollControlled: true,
  );

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: AppStyle.bottomSheetDecoration(context),
      padding: const EdgeInsets.fromLTRB(24, 12, 24, 0),
      child: SafeArea(
        top: false,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 40,
                height: 4,
                decoration: AppStyle.bottomSheetHandleOf(context),
              ),
            ),
            const SizedBox(height: 16),
            Text(title, style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 12),
            // Root option
            _PickerTile(
              icon: Icons.home_outlined,
              name: 'My Documents',
              subtitle: 'Root folder',
              disabled: excludeRoot,
              onTap: excludeRoot
                  ? null
                  : () {
                      Get.back();
                      onPick(null);
                    },
            ),
            if (controller.folders.isNotEmpty) ...[
              const Divider(height: 16),
              ConstrainedBox(
                constraints: BoxConstraints(
                  maxHeight: MediaQuery.of(context).size.height * 0.4,
                ),
                child: ListView.builder(
                  shrinkWrap: true,
                  itemBuilder: (_, i) {
                    final folder = controller.folders
                        .where((f) => f.folderId != excludeFolderId)
                        .toList()[i];
                    return _PickerTile(
                      icon: Icons.folder_outlined,
                      name: folder.name,
                      subtitle: '${folder.itemCount} items',
                      onTap: () {
                        Get.back();
                        onPick(folder.folderId);
                      },
                    );
                  },
                  itemCount: controller.folders
                      .where((f) => f.folderId != excludeFolderId)
                      .length,
                ),
              ),
            ],
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }


}

class _PickerTile extends StatelessWidget {
  final IconData icon;
  final String name;
  final String subtitle;
  final VoidCallback? onTap;
  final bool disabled;

  const _PickerTile({
    required this.icon,
    required this.name,
    required this.subtitle,
    required this.onTap,
    this.disabled = false,
  });

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return ListTile(
      contentPadding: EdgeInsets.zero,
      enabled: !disabled,
      leading: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          color: disabled ? cs.surfaceContainer : cs.primaryContainer,
          borderRadius: BorderRadius.circular(10),
        ),
        child: Icon(
          icon,
          color: disabled ? cs.onSurfaceVariant.withOpacity(0.5) : cs.primary,
          size: 20,
        ),
      ),
      title: Text(
        name,
        style: Theme.of(context).textTheme.titleSmall?.copyWith(
              color: disabled ? cs.onSurfaceVariant : null,
            ),
      ),
      subtitle: Text(
        disabled ? 'Current location' : subtitle,
        style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: disabled ? cs.onSurfaceVariant.withOpacity(0.7) : null,
            ),
      ),
      trailing: disabled
          ? null
          : Icon(
              Icons.chevron_right,
              color: cs.onSurfaceVariant,
              size: 20,
            ),
      onTap: onTap,
    );
  }
}
