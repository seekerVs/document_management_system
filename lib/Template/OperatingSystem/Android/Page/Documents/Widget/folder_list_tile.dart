import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import '../../../../../Commons/Styles/style.dart';
import '../../../../../Utils/Constant/colors.dart';
import '../../../../../Utils/Constant/images.dart';
import '../Controller/documents_controller.dart';
import '../Model/folder_model.dart';

class FolderListTile extends GetView<DocumentsController> {
  final FolderModel folder;
  const FolderListTile({super.key, required this.folder});

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final isMultiSelect = controller.isMultiSelect.value;
      final isSelected = controller.isSelected(folder.folderId);

      return GestureDetector(
        onTap: () => isMultiSelect
            ? controller.toggleSelection(folder.folderId)
            : controller.goToFolder(folder),
        onLongPress: () => controller.selectItem(folder.folderId),
        child: Container(
          margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
          decoration: AppStyle.card().copyWith(
            border: Border.all(
              color: isSelected ? AppColors.primary : AppColors.borderLight,
              width: isSelected ? 2 : 1,
            ),
            color: isSelected
                ? AppColors.primarySurface
                : AppColors.backgroundWhite,
          ),
          child: ListTile(
            contentPadding: const EdgeInsets.only(left: 16),
            leading: SvgPicture.asset(
              AppImages.iconFolder,
              width: 36,
              height: 36,
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
                      color: isSelected
                          ? AppColors.primary
                          : AppColors.textHint,
                      size: 22,
                    ),
                  )
                : IconButton(
                    icon: const Icon(
                      Icons.more_vert,
                      size: 18,
                      color: AppColors.textHint,
                    ),
                    onPressed: () => controller.selectItem(folder.folderId),
                  ),
          ),
        ),
      );
    });
  }
}
