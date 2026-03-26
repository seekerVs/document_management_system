import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../../../Utils/Themes/component_themes.dart';
import '../Controller/documents_controller.dart';
import '../Controller/upload_controller.dart';
import 'sort_menu.dart';
import '../../../../../../Template/Utils/Constant/colors.dart';

class DocumentsToolbar extends GetView<DocumentsController> {
  const DocumentsToolbar({super.key});

  UploadController get _upload => Get.find<UploadController>();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 4),
      child: Row(
        children: [
          MenuAnchor(
            style: AppComponentThemes.appMenuStyle,
            menuChildren: [
              MenuItemButton(
                leadingIcon: const Icon(Icons.upload_file_outlined),
                onPressed: _upload.pickAndUpload,
                child: const Text('Upload file'),
              ),
              MenuItemButton(
                leadingIcon: const Icon(Icons.create_new_folder_outlined),
                onPressed: controller.showCreateFolderDialog,
                child: const Text('New folder'),
              ),
            ],
            builder: (_, menuController, _) => ElevatedButton.icon(
              onPressed: () => menuController.isOpen
                  ? menuController.close()
                  : menuController.open(),
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
                color: AppColors.textSecondary,
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
