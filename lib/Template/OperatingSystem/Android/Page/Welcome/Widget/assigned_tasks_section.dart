import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../Signature/Model/signature_request_model.dart';
import '../Controller/dashboard_controller.dart';

// 📁 lib/Template/OperatingSystem/Android/Page/Welcome/Widget/assigned_tasks_section.dart

class AssignedTasksSection extends GetView<DashboardController> {
  const AssignedTasksSection({super.key});

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final tasks = controller.assignedTasks;
      if (tasks.isEmpty) return const SizedBox.shrink();

      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Assigned Tasks',
            style: Theme.of(
              context,
            ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 12),
          SizedBox(
            height: 100,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              itemCount: tasks.length,
              separatorBuilder: (_, _) => const SizedBox(width: 12),
              itemBuilder: (context, index) => _TaskCard(request: tasks[index]),
            ),
          ),
        ],
      );
    });
  }
}

class _TaskCard extends StatelessWidget {
  final SignatureRequestModel request;
  const _TaskCard({required this.request});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 160,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: Theme.of(context).colorScheme.outline.withOpacity(0.2),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.draw_outlined,
                size: 16,
                color: Theme.of(context).colorScheme.primary,
              ),
              const SizedBox(width: 6),
              Expanded(
                child: Text(
                  'Need to sign',
                  style: Theme.of(context).textTheme.labelSmall?.copyWith(
                    color: Theme.of(context).colorScheme.primary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            'From: ${request.requestedByUid}',
            style: Theme.of(context).textTheme.bodySmall,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }
}
