import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../Controller/task_details_controller.dart';
import '../Widget/task_activity_timeline.dart';
import '../Widget/task_recipients_list.dart';
import '../../../../../Utils/Formatters/formatter.dart';
import '../../../../../Commons/Widgets/app_badge.dart';
import '../../../../../Commons/Widgets/app_button.dart';

class TaskDetailsView extends GetView<TaskDetailsController> {
  const TaskDetailsView({super.key});

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Task Details'),
          centerTitle: true,
          leading: IconButton(
            icon: const Icon(Icons.chevron_left),
            onPressed: Get.back,
          ),
          bottom: const TabBar(
            tabs: [
              Tab(text: 'Activity'),
              Tab(text: 'Details'),
            ],
          ),
        ),
        body: Column(
          children: [
            _buildHeader(context),
            Expanded(
              child: TabBarView(
                children: [
                  // Activity Tab
                  Obx(() {
                    if (controller.isLoadingActivities.value) {
                      return const Center(child: CircularProgressIndicator());
                    }
                    return Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20.0),
                      child: TaskActivityTimeline(
                        activities: controller.activities,
                        task: controller.task,
                      ),
                    );
                  }),
                  // Details Tab
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20.0),
                    child: TaskRecipientsList(signers: controller.task.signers),
                  ),
                ],
              ),
            ),
          ],
        ),
        bottomNavigationBar: _buildBottomActions(context),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    final task = controller.task;
    final docCount = task.documents.isNotEmpty ? task.documents.length : 1;
    final titleText = docCount > 1
        ? '${task.documentName} +${docCount - 1} more'
        : task.documentName;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        border: Border(
          bottom: BorderSide(
            color: Theme.of(
              context,
            ).colorScheme.outlineVariant.withValues(alpha: 0.5),
          ),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            titleText,
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.bold,
              color: Theme.of(context).colorScheme.onSurface,
            ),
          ),
          const SizedBox(height: 12),
          AppBadge(
            label: 'Assigned ${AppFormatter.timeAgo(task.createdAt)}',
            color: Theme.of(context).colorScheme.primary,
            surface: Theme.of(
              context,
            ).colorScheme.primary.withValues(alpha: 0.1),
          ),
          const SizedBox(height: 12),
          Text(
            'From: ${task.requesterName ?? "Unknown"}',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: Theme.of(context).colorScheme.onSurfaceVariant,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBottomActions(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        border: Border(
          top: BorderSide(
            color: Theme.of(
              context,
            ).colorScheme.outlineVariant.withValues(alpha: 0.5),
          ),
        ),
      ),
      child: Row(
        children: [
          Expanded(
            child: AppButton.outlined(
              label: 'View Documents',
              onPressed: controller.openDocument,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: AppButton.primary(
              label: 'Sign',
              onPressed: controller.startSigning,
            ),
          ),
        ],
      ),
    );
  }
}
