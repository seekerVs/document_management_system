import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../Activity/Model/activity_model.dart';
import '../Controller/dashboard_controller.dart';

// 📁 lib/Template/OperatingSystem/Android/Page/Welcome/Widget/activity_section.dart

class ActivitySection extends GetView<DashboardController> {
  const ActivitySection({super.key});

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final activities = controller.recentActivity;
      if (activities.isEmpty) return const SizedBox.shrink();

      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Activities',
                style: Theme.of(
                  context,
                ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
              ),
              TextButton(
                onPressed: controller.goToActivity,
                child: const Text('See All'),
              ),
            ],
          ),
          const SizedBox(height: 8),
          ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: activities.length,
            separatorBuilder: (_, _) => const Divider(height: 1),
            itemBuilder: (context, index) =>
                _ActivityTile(activity: activities[index]),
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
        backgroundColor: Theme.of(context).colorScheme.primary.withOpacity(0.1),
        child: Icon(
          _actionIcon(activity.action),
          size: 16,
          color: Theme.of(context).colorScheme.primary,
        ),
      ),
      title: Text(
        activity.description,
        style: Theme.of(context).textTheme.bodySmall,
        maxLines: 2,
        overflow: TextOverflow.ellipsis,
      ),
      trailing: Text(
        _timeAgo(activity.timestamp),
        style: Theme.of(context).textTheme.labelSmall?.copyWith(
          color: Theme.of(context).colorScheme.outline,
        ),
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
      case ActivityAction.declined:
        return Icons.cancel_outlined;
      case ActivityAction.folderCreated:
        return Icons.create_new_folder_outlined;
    }
  }

  String _timeAgo(DateTime dt) {
    final diff = DateTime.now().difference(dt);
    if (diff.inMinutes < 1) return 'just now';
    if (diff.inHours < 1) return '${diff.inMinutes}m ago';
    if (diff.inDays < 1) return '${diff.inHours}h ago';
    return '${diff.inDays}d ago';
  }
}
