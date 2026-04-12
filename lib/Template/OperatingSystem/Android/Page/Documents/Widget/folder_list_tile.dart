import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../../../Commons/Styles/style.dart';
import '../Controller/documents_controller.dart';
import '../Model/folder_model.dart';

class FolderListTile extends GetView<DocumentsController> {
  final FolderModel folder;
  const FolderListTile({super.key, required this.folder});

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final cs = Theme.of(context).colorScheme;
      final isMultiSelect = controller.isMultiSelect.value;
      final isSelected = controller.isSelected(folder.folderId);

      return GestureDetector(
        onTap: () => isMultiSelect
            ? controller.toggleSelection(folder.folderId)
            : controller.goToFolder(folder),
        onLongPress: () => controller.selectItem(folder.folderId),
        child: Container(
          margin: const EdgeInsets.symmetric(vertical: 4),
          decoration: AppStyle.cardOf(context).copyWith(
            border: Border.all(
              color: isSelected ? cs.primary : cs.outline,
              width: isSelected ? 2 : 1,
            ),
            color: isSelected ? cs.primaryContainer : cs.surfaceContainer,
          ),
          child: ListTile(
            contentPadding: const EdgeInsets.only(left: 16),
            leading: Icon(
              Icons.folder_rounded,
              size: 40,
              color: cs.primary,
            ),
            title: Text(
              folder.name,
              style: Theme.of(context).textTheme.titleSmall,
            ),
            subtitle: Text(
              '${folder.itemCount} Items',
              style: Theme.of(context).textTheme.bodySmall,
            ),
            trailing: isMultiSelect
                ? Padding(
                    padding: const EdgeInsets.only(right: 12),
                    child: Icon(
                      isSelected
                          ? Icons.check_circle
                          : Icons.radio_button_unchecked,
                      color: isSelected ? cs.primary : cs.onSurfaceVariant,
                      size: 22,
                    ),
                  )
                : IconButton(
                    icon: Icon(
                      Icons.more_vert,
                      size: 18,
                      color: cs.onSurfaceVariant,
                    ),
                    onPressed: () => controller.selectItem(folder.folderId),
                  ),
          ),
        ),
      );
    });
  }
}
