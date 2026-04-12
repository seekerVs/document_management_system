import 'package:flutter/material.dart';
import 'package:get/get.dart';
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
      child: Row(
        children: [
          PopupMenuButton<String>(
            key: _menuKey,
            position: PopupMenuPosition.under,
            onSelected: (value) {
              if (value == 'upload') _uploadController.showUploadSourceSheet();
              if (value == 'folder') controller.showCreateFolderDialog();
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
              onPressed: () => _menuKey.currentState?.showButtonMenu(),
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
          const Spacer(),
          Obx(
            () => IconButton(
              icon: Icon(
                controller.isGridView.value
                    ? Icons.grid_view_rounded
                    : Icons.format_list_bulleted,
                color: cs.onSurfaceVariant,
              ),
              onPressed: controller.toggleViewMode,
            ),
          ),
          const SortMenu(),
        ],
      ),
    );
  }
}
