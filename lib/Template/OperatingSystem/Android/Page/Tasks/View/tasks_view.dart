import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../../../Commons/Widgets/section_header.dart';
import '../../../../../Commons/Widgets/app_document_tile.dart';
import '../../../../../Commons/Widgets/empty_state.dart';
import '../../../../../Commons/Widgets/loading_shimmer.dart';
import '../../../../../Utils/Constant/colors.dart';
import '../../../../../Utils/Constant/enum.dart';
import '../../../../../Utils/Constant/texts.dart';
import '../../../../../Utils/Formatters/formatter.dart';
import '../../Signature/Model/signature_request_model.dart';
import '../Controller/tasks_controller.dart';

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
          child: ListView(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
            children: [
              const SectionHeader(title: 'Recents'),
              const SizedBox(height: 8),
              ...tasks.map((request) {
                final signer = controller.currentSigner(request);
                if (signer == null) return const SizedBox.shrink();

                return Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: AppDocumentTile(
                    title: request.documentName,
                    subtitle1: 'From: ${request.requesterName ?? 'Unknown'}',
                    subtitle2: _getStatusLabel(signer),
                    trailing1: null, // Size not available in model
                    trailing2: AppFormatter.dateShort(request.createdAt),
                    onTap: () => controller.openTask(request),
                    onMoreTap: () => controller.showTaskOptions(request),
                  ),
                );
              }),
              const SizedBox(height: 32),
              const Center(
                child: Text(
                  'No more tasks',
                  style: TextStyle(
                    color: AppColors.textHint,
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ],
          ),
        );
      }),
    );
  }

  String _getStatusLabel(SignerModel signer) {
    if (signer.role == SignerRole.receivesACopy) return 'Received a copy';

    switch (signer.status) {
      case SignerStatus.pending:
        return 'Needs to sign';
      case SignerStatus.signed:
        return 'Signed';
      case SignerStatus.declined:
        return 'Declined';
    }
  }
}
