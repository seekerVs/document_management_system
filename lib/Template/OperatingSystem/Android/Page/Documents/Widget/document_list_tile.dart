import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../../../Commons/Styles/style.dart';
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
      final cs = Theme.of(context).colorScheme;
      final isMultiSelect = controller.isMultiSelect.value;
      final isSelected = controller.isSelected(doc.documentId);

      return GestureDetector(
        onTap: () => isMultiSelect
            ? controller.toggleSelection(doc.documentId)
            : controller.openDocument(doc),
        onLongPress: () => controller.selectItem(doc.documentId),
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
            leading: Container(
              width: 42,
              height: 42,
              decoration: BoxDecoration(
                color: cs.error,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Center(
                child: Text(
                  'PDF',
                  style: TextStyle(
                    color: cs.surfaceContainer,
                    fontWeight: FontWeight.w800,
                    fontSize: 11,
                  ),
                ),
              ),
            ),
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
                    onPressed: () => controller.selectItem(doc.documentId),
                  ),
          ),
        ),
      );
    });
  }
}
