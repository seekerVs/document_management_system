import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../../../Commons/Styles/style.dart';
import '../Controller/documents_controller.dart';
import '../Model/folder_model.dart';
import '../../../../../../Template/Utils/Formatters/formatter.dart';

class FolderGridCard extends GetView<DocumentsController> {
  final FolderModel folder;
  final VoidCallback? onTapOverride;
  const FolderGridCard({super.key, required this.folder, this.onTapOverride});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        if (controller.isMultiSelect.value) {
          controller.toggleSelection(folder.folderId);
        } else if (onTapOverride != null) {
          onTapOverride!();
        } else {
          controller.goToFolder(folder);
        }
      },
      onLongPress: () => controller.selectItem(folder.folderId),
      child: Obx(() {
        final cs = Theme.of(context).colorScheme;
        final isMultiSelect = controller.isMultiSelect.value;
        final isSelected = controller.isSelected(folder.folderId);
        return Container(
          decoration: AppStyle.cardOf(context).copyWith(
            border: Border.all(
              color: isSelected ? cs.primary : cs.outline,
              width: isSelected ? 2 : 1,
            ),
            color: isSelected ? cs.primaryContainer : cs.surfaceContainer,
          ),
          padding: const EdgeInsets.fromLTRB(12, 4, 4, 12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Align(
                alignment: Alignment.topRight,
                child: isMultiSelect
                    ? Padding(
                        padding: const EdgeInsets.all(8),
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
              Expanded(
                child: Center(
                  child: Icon(
                    Icons.folder_rounded,
                    size: 56,
                    color: cs.primary,
                  ),
                ),
              ),
              Text(
                folder.name,
                style: Theme.of(context).textTheme.titleSmall,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 2),
              Text(
                '${AppFormatter.dateShort(folder.updatedAt)}  ·  ${folder.itemCount} Items',
                style: Theme.of(context).textTheme.labelSmall,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        );
      }),
    );
  }
}
