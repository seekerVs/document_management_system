import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../../../Commons/Styles/style.dart';
import '../Controller/documents_controller.dart';
import '../Model/document_model.dart';
import '../../../../../../Template/Utils/Formatters/formatter.dart';

class DocumentGridCard extends GetView<DocumentsController> {
  final DocumentModel doc;
  const DocumentGridCard({super.key, required this.doc});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => controller.isMultiSelect.value
          ? controller.toggleSelection(doc.documentId)
          : controller.openDocument(doc),
      onLongPress: () => controller.selectItem(doc.documentId),
      child: Obx(() {
        final cs = Theme.of(context).colorScheme;
        final isMultiSelect = controller.isMultiSelect.value;
        final isSelected = controller.isSelected(doc.documentId);
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
                        onPressed: () => controller.selectItem(doc.documentId),
                      ),
              ),
              Expanded(
                child: Center(
                  child: Container(
                    width: 48,
                    height: 48,
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
        ),
      ),
      Text(
        doc.name,
        style: Theme.of(context).textTheme.titleSmall,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
      ),
      const SizedBox(height: 2),
      Text(
        '${AppFormatter.fileSizeFromMB(doc.fileSizeMB)}  ·  ${AppFormatter.dateShort(doc.updatedAt)}',
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
