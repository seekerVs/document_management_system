import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../../../Commons/Widgets/section_header.dart';
import '../../../../../Commons/Widgets/app_document_tile.dart';
import '../Controller/dashboard_controller.dart';
import '../../../../../Utils/Constant/texts.dart';
import '../../../../../Utils/Formatters/formatter.dart';

class ActivitySection extends StatelessWidget {
  const ActivitySection({super.key});

  DashboardController get controller => Get.find<DashboardController>();

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final activities = controller.recentActivity;
      if (activities.isEmpty) return const SizedBox.shrink();

      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SectionHeader(
            title: AppText.activities,
            onSeeAll: controller.goToActivity,
          ),
          const SizedBox(height: 8),
          ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: activities.length,
            separatorBuilder: (_, _) => const SizedBox(height: 8),
            itemBuilder: (_, i) {
              final activity = activities[i];
              return AppDocumentTile(
                title: activity.documentName ?? 'Untitled Document',
                subtitle1: 'From: ${activity.actorName}',
                subtitle2: activity.action.name.capitalizeFirst!,
                trailing2: AppFormatter.dateShort(activity.timestamp),
                icon: Icons.draw_outlined,
              );
            },
          ),
        ],
      );
    });
  }
}
