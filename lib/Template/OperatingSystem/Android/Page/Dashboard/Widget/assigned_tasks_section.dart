import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../../../Commons/Styles/style.dart';
import '../../../../../Commons/Widgets/section_header.dart';
import '../../Signature/Model/signature_request_model.dart';
import '../Controller/dashboard_controller.dart';
import '../../../../../Utils/Constant/colors.dart';
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
            height: 90,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              itemCount: tasks.length,
              separatorBuilder: (_, _) => const SizedBox(width: 12),
              itemBuilder: (_, i) => _TaskCard(request: tasks[i]),
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
      width: 170,
      padding: const EdgeInsets.all(14),
      decoration: AppStyle.card(),
      child: Row(
        children: [
          const Icon(
            Icons.draw_outlined,
            size: 18,
            color: AppColors.textSecondary,
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  'Need to sign',
                  style: Theme.of(context).textTheme.labelMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'From: ${request.requestedByUid}',
                  style: Theme.of(context).textTheme.labelSmall,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
          const Icon(Icons.open_in_new, size: 14, color: AppColors.textHint),
        ],
      ),
    );
  }
}
