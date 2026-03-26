import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../../../Commons/Styles/style.dart';
import '../../../../../Commons/Widgets/app_button.dart';
import '../../../../../Utils/Constant/colors.dart';
import '../../../../../Utils/Constant/images.dart';
import '../Controller/signature_request_controller.dart';
import 'package:flutter_svg/flutter_svg.dart';

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
                      decoration: AppStyle.card(),
                      child: Row(
                        children: [
                          const Icon(
                            Icons.add,
                            color: AppColors.primary,
                            size: 20,
                          ),
                          const SizedBox(width: 12),
                          Text(
                            doc == null
                                ? 'Select a document'
                                : 'Add another document',
                            style: Theme.of(context).textTheme.titleSmall
                                ?.copyWith(color: AppColors.primary),
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
      decoration: AppStyle.card(),
      child: ListTile(
        contentPadding: const EdgeInsets.only(left: 16),
        leading: SvgPicture.asset(AppImages.iconPdf, width: 40, height: 40),
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
          icon: const Icon(
            Icons.more_vert,
            size: 18,
            color: AppColors.textHint,
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
