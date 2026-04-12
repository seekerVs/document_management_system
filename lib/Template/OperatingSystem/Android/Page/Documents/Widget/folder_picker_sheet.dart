import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../../../../Template/Utils/Constant/texts.dart';
import '../../../../../Commons/Styles/style.dart';
import '../Model/folder_model.dart';
import '../Repository/folder_repository.dart';

class FolderPickerSheet extends StatelessWidget {
  final List<FolderModel>? folders;
  final void Function(String? folderId, String folderName) onPick;
  final String title;
  final String? excludeFolderId;
  final bool excludeRoot;

  const FolderPickerSheet({
    super.key,
    this.folders,
    required this.onPick,
    this.title = 'Copy to',
    this.excludeFolderId,
    this.excludeRoot = false,
  });

  static Future<void> show({
    List<FolderModel>? folders,
    required void Function(String? folderId, String folderName) onPick,
    String title = 'Copy to',
    String? excludeFolderId,
    bool excludeRoot = false,
  }) {
    return Get.bottomSheet(
      FolderPickerSheet(
        folders: folders,
        onPick: onPick,
        title: title,
        excludeFolderId: excludeFolderId,
        excludeRoot: excludeRoot,
      ),
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      enterBottomSheetDuration: const Duration(milliseconds: 300),
    );
  }

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
              name: AppText.myDocuments,
              subtitle: 'Root folder',
              disabled: excludeRoot,
              onTap: excludeRoot
                  ? null
                  : () {
                      Get.back();
                      onPick(null, AppText.myDocuments);
                    },
            ),
            
            // Sub-folders with independent loading if needed
            if (folders != null)
              _buildList(context, folders!)
            else
              FutureBuilder<List<FolderModel>>(
                future: FolderRepository().getFolders(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Padding(
                      padding: EdgeInsets.symmetric(vertical: 24),
                      child: Center(child: CircularProgressIndicator(strokeWidth: 2)),
                    );
                  }
                  if (snapshot.hasError || !snapshot.hasData) {
                    return const SizedBox.shrink();
                  }
                  return _buildList(context, snapshot.data!);
                },
              ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

  Widget _buildList(BuildContext context, List<FolderModel> foldersList) {
    final filtered = foldersList.where((f) => f.folderId != excludeFolderId).toList();
    if (filtered.isEmpty) return const SizedBox.shrink();

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        const Divider(height: 16),
        ConstrainedBox(
          constraints: BoxConstraints(
            maxHeight: MediaQuery.of(context).size.height * 0.4,
          ),
          child: ListView.builder(
            shrinkWrap: true,
            physics: const BouncingScrollPhysics(),
            itemBuilder: (_, i) {
              final folder = filtered[i];
              return _PickerTile(
                icon: Icons.folder_outlined,
                name: folder.name,
                subtitle: '${folder.itemCount} items',
                onTap: () {
                  Get.back();
                  onPick(folder.folderId, folder.name);
                },
              );
            },
            itemCount: filtered.length,
          ),
        ),
      ],
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
          color: disabled ? cs.onSurfaceVariant.withValues(alpha: 0.5) : cs.primary,
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
              color: disabled ? cs.onSurfaceVariant.withValues(alpha: 0.7) : null,
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
