import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import '../../../../../Commons/Styles/style.dart';
import '../../../../../Utils/Constant/colors.dart';
import '../../../../../Utils/Constant/images.dart';
import '../Controller/documents_controller.dart';
import '../Model/document_model.dart';
import '../../../../../../Template/Utils/Formatters/formatter.dart';

class DocumentListTile extends GetView<DocumentsController> {
  final DocumentModel doc;
  final VoidCallback? onRenameOverride;
  final VoidCallback? onDeleteOverride;

  const DocumentListTile({
    super.key,
    required this.doc,
    this.onRenameOverride,
    this.onDeleteOverride,
  });

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final isMultiSelect = controller.isMultiSelect.value;
      final isSelected = controller.isSelected(doc.documentId);

      return GestureDetector(
        onTap: () => isMultiSelect
            ? controller.toggleSelection(doc.documentId)
            : controller.openDocument(doc),
        onLongPress: () => controller.selectItem(doc.documentId),
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
            leading: SvgPicture.asset(AppImages.iconPdf, width: 40, height: 40),
            title: Text(
              doc.name,
              style: Theme.of(context).textTheme.titleSmall,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            subtitle: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  AppFormatter.fileSizeFromMB(doc.fileSizeMB),
                  style: Theme.of(context).textTheme.bodySmall,
                ),
                Text(
                  AppFormatter.dateShort(doc.updatedAt),
                  style: Theme.of(context).textTheme.bodySmall,
                ),
              ],
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
                    onPressed: () => controller.selectItem(doc.documentId),
                  ),
          ),
        ),
      );
    });
  }
}
