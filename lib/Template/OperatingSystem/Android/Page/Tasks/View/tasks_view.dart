import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../../../Commons/Widgets/empty_state.dart';
import '../../../../../Commons/Widgets/loading_shimmer.dart';
import '../../../../../Utils/Constant/texts.dart';
import '../Controller/tasks_controller.dart';
import '../Widget/task_tile.dart';

class TasksView extends GetView<TasksController> {
  const TasksView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Tasks'),
        leading: IconButton(
          icon: const Icon(Icons.chevron_left),
          onPressed: Get.back,
        ),
      ),
      body: Obx(() {
        if (controller.isLoading.value) {
          return ListView.builder(
            padding: const EdgeInsets.symmetric(vertical: 8),
            itemCount: 6,
            itemBuilder: (_, _) => Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
              child: LoadingShimmer.card(),
            ),
          );
        }

        final tasks = controller.tasks;

        if (tasks.isEmpty) {
          return const EmptyState(
            icon: Icons.task_alt_outlined,
            message: AppText.noSignatureRequests,
            subtitle: 'Documents assigned to you will appear here.',
          );
        }

        return RefreshIndicator(
          onRefresh: controller.loadTasks,
          child: ListView.builder(
            padding: const EdgeInsets.symmetric(vertical: 8),
            itemCount: tasks.length,
            itemBuilder: (_, i) {
              final request = tasks[i];
              final signer = controller.currentSigner(request);
              if (signer == null) return const SizedBox.shrink();
              return TaskTile(
                request: request,
                signer: signer,
                onTap: () => controller.openTask(request),
                onMoreTap: () => controller.showTaskOptions(request),
              );
            },
          ),
        );
      }),
    );
  }
}
