import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../../../Commons/Widgets/section_header.dart';
import '../../../../../Commons/Widgets/app_document_tile.dart';
import '../../../../../Commons/Widgets/empty_state.dart';
import '../../../../../Commons/Widgets/loading_shimmer.dart';
import '../../../../../Utils/Constant/enum.dart';
import '../../../../../Utils/Constant/texts.dart';
import '../../../../../Utils/Formatters/formatter.dart';
import '../../Signature/Model/signature_request_model.dart';
import '../../../../../Commons/Widgets/app_pagination_bar.dart';
import '../Controller/tasks_controller.dart';

class TasksView extends GetView<TasksController> {
  const TasksView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Tasks'),
        centerTitle: true,
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
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 6),
              child: LoadingShimmer.card(context),
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
          child: CustomScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            slivers: [
              SliverPadding(
                padding: const EdgeInsets.fromLTRB(20, 8, 20, 0),
                sliver: SliverList(
                  delegate: SliverChildListDelegate([
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
                          trailing2: AppFormatter.dateShort(request.createdAt),
                          onTap: () {
                            if (signer.status == SignerStatus.pending) {
                              controller.signDocument(request);
                            } else {
                              controller.viewTaskDetails(request);
                            }
                          },
                          trailingWidget: PopupMenuButton<String>(
                            position: PopupMenuPosition.under,
                            icon: Icon(
                              Icons.more_vert,
                              color: Theme.of(context).colorScheme.onSurface,
                              size: 20,
                            ),
                            onSelected: (value) {
                              if (value == 'details') {
                                controller.viewTaskDetails(request);
                              }
                            },
                            itemBuilder: (_) => [
                              PopupMenuItem(
                                value: 'details',
                                child: Row(
                                  children: [
                                    Icon(
                                      Icons.info_outline,
                                      size: 20,
                                      color: Theme.of(context).colorScheme.onSurface,
                                    ),
                                    const SizedBox(width: 12),
                                    Text(
                                      'Task Details',
                                      style: Theme.of(context).textTheme.bodyMedium,
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    }),
                  ]),
                ),
              ),
              SliverFillRemaining(
                hasScrollBody: false,
                child: Align(
                  alignment: Alignment.bottomCenter,
                  child: Padding(
                    padding: const EdgeInsets.only(bottom: 16),
                    child: AppPaginationBar(
                      totalPages: controller.totalPages,
                      currentPage: controller.currentPage.value,
                      isLoading: controller.isPageLoading.value,
                      onPageChanged: controller.goToPage,
                      onNext: controller.nextPage,
                      onPrevious: controller.previousPage,
                    ),
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
    }
  }
}


