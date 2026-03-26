import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../../../Commons/Widgets/empty_state.dart';
import '../../../../../Commons/Widgets/section_header.dart';
import '../Controller/dashboard_controller.dart';
import '../../../../../Utils/Constant/texts.dart';
import 'document_display_tile.dart';

class RecentDocumentsSection extends StatelessWidget {
  const RecentDocumentsSection({super.key});

  DashboardController get controller => Get.find<DashboardController>();

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final docs = controller.recentDocuments;
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SectionHeader(
            title: AppText.myDocuments,
            onSeeAll: controller.goToDocuments,
          ),
          const SizedBox(height: 8),
          docs.isEmpty
              ? const EmptyState(
                  icon: Icons.folder_open_outlined,
                  message: AppText.noDocuments,
                )
              : ListView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: docs.length,
                  itemBuilder: (_, i) => DocumentDisplayTile(
                    document: docs[i],
                    margin: const EdgeInsets.symmetric(vertical: 4),
                    onTap: () => controller.openDocument(docs[i]),
                    onMoreTap: () => controller.showDocumentOptions(docs[i]),
                  ),
                ),
        ],
      );
    });
  }
}
