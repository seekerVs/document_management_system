import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../../../Commons/Widgets/section_header.dart';
import '../../Activity/Model/activity_model.dart';
import '../Controller/dashboard_controller.dart';
import '../../../../../Utils/Constant/colors.dart';
import '../../../../../Utils/Constant/enum.dart';
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
            separatorBuilder: (_, _) => const Divider(height: 1),
            itemBuilder: (_, i) => _ActivityTile(activity: activities[i]),
          ),
        ],
      );
    });
  }
}

class _ActivityTile extends StatelessWidget {
  final ActivityModel activity;
  const _ActivityTile({required this.activity});

  @override
  Widget build(BuildContext context) {
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(vertical: 4),
      leading: CircleAvatar(
        radius: 18,
        backgroundColor: AppColors.primarySurface,
        child: Icon(
          _actionIcon(activity.action),
          size: 16,
          color: AppColors.primary,
        ),
      ),
      title: Text(
        AppFormatter.activityDescription(
          actorName: activity.actorName,
          action: activity.action,
          documentName: activity.documentName,
        ),
        style: Theme.of(context).textTheme.bodySmall,
        maxLines: 2,
        overflow: TextOverflow.ellipsis,
      ),
      trailing: Text(
        AppFormatter.dateShort(activity.timestamp),
        style: Theme.of(context).textTheme.labelSmall,
      ),
    );
  }

  IconData _actionIcon(ActivityAction action) {
    switch (action) {
      case ActivityAction.uploaded:
        return Icons.upload_outlined;
      case ActivityAction.signed:
        return Icons.draw_outlined;
      case ActivityAction.requestedSignature:
        return Icons.send_outlined;
      case ActivityAction.deleted:
        return Icons.delete_outline;
      case ActivityAction.moved:
        return Icons.drive_file_move_outlined;
      case ActivityAction.copied:
        return Icons.copy_outlined;
      case ActivityAction.renamed:
        return Icons.edit_outlined;
      case ActivityAction.declined:
        return Icons.cancel_outlined;
      case ActivityAction.folderCreated:
        return Icons.create_new_folder_outlined;
      case ActivityAction.folderDeleted:
        return Icons.folder_off_outlined;
      case ActivityAction.shared:
        return Icons.share_outlined;
    }
  }
}
