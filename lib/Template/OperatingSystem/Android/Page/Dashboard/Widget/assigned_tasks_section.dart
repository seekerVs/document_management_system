import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../../../Commons/Styles/style.dart';
import '../../../../../Commons/Widgets/section_header.dart';
import '../Controller/dashboard_controller.dart';
import '../../../../../Utils/Constant/texts.dart';

class AssignedTasksSection extends StatelessWidget {
  const AssignedTasksSection({super.key});

  DashboardController get controller => Get.find<DashboardController>();

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final tasks = controller.assignedTasks;
      if (tasks.isEmpty) return const SizedBox.shrink();

      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SectionHeader(title: AppText.assignedTasks),
          const SizedBox(height: 12),
          SizedBox(
            height: 80,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,

              itemCount: tasks.length,
              separatorBuilder: (_, _) => const SizedBox(width: 8),
              itemBuilder: (_, i) {
                final task = tasks[i];
                return _TaskCard(
                  title: 'Signature Request',
                  from: task.requesterName ?? 'Unknown',
                  filename: task.documentName,
                );
              },
            ),
          ),
        ],
      );
    });
  }
}

class _TaskCard extends StatelessWidget {
  final String title;
  final String from;
  final String filename;

  const _TaskCard({
    required this.title,
    required this.from,
    required this.filename,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 300,
      height: 80,
      decoration: AppStyle.cardOf(context, radius: 8),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        child: Row(
          children: [
            Icon(
              Icons.draw_outlined,
              color: Theme.of(context).colorScheme.onSurface,
              size: 30,
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: Theme.of(context).colorScheme.onSurface,
                    ),
                  ),
                  Text(
                    'From: $from',
                    style: TextStyle(
                      fontSize: 10,
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                    ),
                  ),
                  Text(
                    filename,
                    style: TextStyle(
                      fontSize: 10,
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            ),
            Icon(
              Icons.open_in_new,
              color: Theme.of(context).colorScheme.onSurface,
              size: 20,
            ),
          ],
        ),
      ),
    );
  }
}
