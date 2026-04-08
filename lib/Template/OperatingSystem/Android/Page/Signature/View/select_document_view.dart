import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../../../Commons/Styles/style.dart';
import '../../../../../Commons/Widgets/app_button.dart';
import '../../../../../Utils/Popups/dialog.dart';
import '../../Documents/Widget/pdf_viewer.dart';
import '../Controller/signature_request_controller.dart';

class SelectDocumentView extends GetView<SignatureRequestController> {
  const SelectDocumentView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Add Documents'),
        leading: IconButton(
          icon: const Icon(Icons.chevron_left),
          onPressed: Get.back,
        ),
      ),
      body: Obx(() {
        final doc = controller.selectedDocument.value;
        return Column(
          children: [
            Expanded(
              child: ListView(
                padding: const EdgeInsets.all(16),
                children: [
                  if (doc != null) ...[
                    _DocumentTile(controller: controller),
                    const SizedBox(height: 8),
                  ],
                  // Add another document row
                  GestureDetector(
                    onTap: controller.showDocumentSourceSheet,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 14,
                      ),
                      decoration: AppStyle.cardOf(context),
                      child: Row(
                        children: [
                          Icon(
                            Icons.add,
                            color: Theme.of(context).colorScheme.primary,
                            size: 20,
                          ),
                          const SizedBox(width: 12),
                          Text(
                            doc == null
                                ? 'Select a document'
                                : 'Add another document',
                            style: Theme.of(context).textTheme.titleSmall
                                ?.copyWith(color: Theme.of(context).colorScheme.primary),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
            _BottomActions(controller: controller),
          ],
        );
      }),
    );
  }
}

class _DocumentTile extends StatelessWidget {
  final SignatureRequestController controller;
  const _DocumentTile({required this.controller});

  @override
  Widget build(BuildContext context) {
    final doc = controller.selectedDocument.value!;
    return Container(
      decoration: AppStyle.cardOf(context),
      child: ListTile(
        contentPadding: const EdgeInsets.only(left: 16),
        onTap: () {
          Get.to(
            () => Scaffold(
              backgroundColor: Theme.of(context).colorScheme.surface,
              appBar: AppBar(
                backgroundColor: Theme.of(context).colorScheme.surface,
                scrolledUnderElevation: 0,
                elevation: 1,
                title: Text(
                  doc.name,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                    color: Theme.of(context).colorScheme.onSurface,
                  ),
                ),
                leading: IconButton(
                  icon: const Icon(Icons.chevron_left),
                  onPressed: Get.back,
                ),
              ),
              body: PdfViewer(
                localPath: doc.file.path,
                onError: (e) => AppDialogs.showSnackError('Failed to load PDF'),
              ),
            ),
          );
        },
        leading: Container(
          width: 42,
          height: 42,
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.error,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Center(
            child: Text(
              'PDF',
              style: TextStyle(
                color: Theme.of(context).colorScheme.onError,
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
        subtitle: Text(
          doc.sizeLabel,
          style: Theme.of(context).textTheme.bodySmall,
        ),
        trailing: IconButton(
          icon: Icon(
            Icons.more_vert,
            size: 18,
            color: Theme.of(context).colorScheme.onSurfaceVariant,
          ),
          onPressed: () => controller.showSelectedDocumentOptions(doc),
        ),
      ),
    );
  }
}

class _BottomActions extends StatelessWidget {
  final SignatureRequestController controller;
  const _BottomActions({required this.controller});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 32),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Obx(
            () => AppButton.primary(
              label: 'Next',
              onPressed: controller.selectedDocument.value != null
                  ? controller.goToAddRecipients
                  : null,
            ),
          ),
          const SizedBox(height: 8),
          AppButton.outlined(label: 'Cancel', onPressed: Get.back),
        ],
      ),
    );
  }
}
