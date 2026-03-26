import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import '../../../../../Commons/Styles/style.dart';
import '../../../../../Utils/Constant/colors.dart';
import '../../../../../Utils/Constant/images.dart';
import '../Controller/documents_controller.dart';
import '../Model/folder_model.dart';
import '../../../../../../Template/Utils/Formatters/formatter.dart';

class FolderGridCard extends GetView<DocumentsController> {
  final FolderModel folder;
  const FolderGridCard({super.key, required this.folder});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => controller.isMultiSelect.value
          ? controller.toggleSelection(folder.folderId)
          : controller.goToFolder(folder),
      onLongPress: () => controller.selectItem(folder.folderId),
      child: Obx(() {
        final isMultiSelect = controller.isMultiSelect.value;
        final isSelected = controller.isSelected(folder.folderId);
        return Container(
          decoration: AppStyle.card().copyWith(
            border: Border.all(
              color: isSelected ? AppColors.primary : AppColors.borderLight,
              width: isSelected ? 2 : 1,
            ),
            color: isSelected
                ? AppColors.primarySurface
                : AppColors.backgroundWhite,
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
              Expanded(
                child: Center(
                  child: SvgPicture.asset(
                    AppImages.iconFolder,
                    width: 56,
                    height: 56,
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
