import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../../../../Template/Utils/Constant/enum.dart';
import '../Controller/documents_controller.dart';
import '../Controller/upload_controller.dart';
import 'sort_menu.dart';

class DocumentsToolbar extends GetView<DocumentsController> {
  DocumentsToolbar({super.key});

  UploadController get _uploadController => Get.find<UploadController>();
  final GlobalKey<PopupMenuButtonState<String>> _menuKey = GlobalKey();

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Padding(
      padding: const EdgeInsets.only(top: 12, bottom: 4),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Obx(
                () => controller.isPickerMode.value
                    ? const SizedBox.shrink()
                    : PopupMenuButton<String>(
                        key: _menuKey,
                        position: PopupMenuPosition.under,
                        onSelected: (value) {
                          if (value == 'upload') {
                            _uploadController.showUploadSourceSheet();
                          }
                          if (value == 'folder') {
                            controller.showCreateFolderDialog();
                          }
                        },
                        itemBuilder: (_) => [
                          PopupMenuItem(
                            value: 'upload',
                            child: Row(
                              children: [
                                Icon(
                                  Icons.upload_file_outlined,
                                  size: 20,
                                  color: cs.onSurface,
                                ),
                                const SizedBox(width: 12),
                                Text(
                                  'Upload file',
                                  style: Theme.of(context).textTheme.bodyMedium,
                                ),
                              ],
                            ),
                          ),
                          PopupMenuItem(
                            value: 'folder',
                            child: Row(
                              children: [
                                Icon(
                                  Icons.create_new_folder_outlined,
                                  size: 20,
                                  color: cs.onSurface,
                                ),
                                const SizedBox(width: 12),
                                Text(
                                  'New folder',
                                  style: Theme.of(context).textTheme.bodyMedium,
                                ),
                              ],
                            ),
                          ),
                        ],
                        child: ElevatedButton.icon(
                          onPressed: () =>
                              _menuKey.currentState?.showButtonMenu(),
                          icon: const Icon(Icons.add, size: 18),
                          label: const Text('New'),
                          style: ElevatedButton.styleFrom(
                            minimumSize: Size.zero,
                            padding: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 10,
                            ),
                          ),
                        ),
                      ),
              ),
              const Spacer(),
              Obx(() {
                return IconButton(
                  icon: Icon(
                    controller.isGridView.value
                        ? Icons.format_list_bulleted
                        : Icons.grid_view_rounded,
                    color: cs.onSurfaceVariant,
                  ),
                  onPressed: controller.toggleViewMode,
                );
              }),
              const SortMenu(),
            ],
          ),
          const SizedBox(height: 8),
          Obx(() {
            final selected = controller.itemTypeFilter.value;
            return Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                _TypeFilterTab(
                  label: 'All',
                  isSelected: selected == DocumentTypeFilter.all,
                  onTap: () =>
                      controller.applyItemTypeFilter(DocumentTypeFilter.all),
                ),
                _TypeFilterTab(
                  label: 'Folders',
                  isSelected: selected == DocumentTypeFilter.folders,
                  onTap: () => controller.applyItemTypeFilter(
                    DocumentTypeFilter.folders,
                  ),
                ),
                _TypeFilterTab(
                  label: 'PDF',
                  isSelected: selected == DocumentTypeFilter.pdfs,
                  onTap: () =>
                      controller.applyItemTypeFilter(DocumentTypeFilter.pdfs),
                ),
              ],
            );
          }),
        ],
      ),
    );
  }
}

class _TypeFilterTab extends StatelessWidget {
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  const _TypeFilterTab({
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final selectedBg = cs.primary;
    final selectedText = cs.onPrimary;
    final idleBg = cs.surfaceContainerHigh;
    final idleText = cs.onSurfaceVariant;
    const tabRadius = 12.0;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(tabRadius),
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          curve: Curves.easeOut,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
          decoration: BoxDecoration(
            color: isSelected ? selectedBg : idleBg,
            borderRadius: BorderRadius.circular(tabRadius),
          ),
          child: Text(
            label,
            style: Theme.of(context).textTheme.titleSmall?.copyWith(
              color: isSelected ? selectedText : idleText,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ),
    );
  }
}
