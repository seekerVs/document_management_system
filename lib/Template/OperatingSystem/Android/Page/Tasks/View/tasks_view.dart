import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../../../Commons/Widgets/app_document_tile.dart';
import '../../../../../Commons/Widgets/empty_state.dart';
import '../../../../../Commons/Widgets/loading_shimmer.dart';
import '../../../../../Commons/Widgets/section_header.dart';
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

        if (controller.allTasksCount == 0) {
          return const EmptyState(
            icon: Icons.task_alt_outlined,
            message: AppText.noSignatureRequests,
            subtitle: 'Documents assigned to you will appear here.',
          );
        }

        final tasks = controller.tasks;

        return RefreshIndicator(
          onRefresh: controller.loadTasks,
          child: CustomScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            slivers: [
              SliverPadding(
                padding: const EdgeInsets.fromLTRB(20, 8, 20, 0),
                sliver: SliverList(
                  delegate: SliverChildListDelegate([
                    _TasksSearchBar(),
                    const SizedBox(height: 12),
                    const _TasksTopBar(),
                    const SizedBox(height: 8),
                    const _TasksTypeTabs(),
                    const SizedBox(height: 8),
                    const SectionHeader(title: 'Recents'),
                    const SizedBox(height: 8),
                    if (tasks.isEmpty)
                      Padding(
                        padding: const EdgeInsets.only(top: 16),
                        child: EmptyState(
                          icon: controller.isSearching.value
                              ? Icons.search_off
                              : Icons.filter_alt_off,
                          message: controller.isSearching.value
                              ? 'No tasks found'
                              : 'No matching tasks',
                          subtitle: controller.isSearching.value
                              ? 'Try a different keyword.'
                              : 'Try another sort option.',
                        ),
                      )
                    else
                      ...tasks.map((request) {
                        final signer = controller.currentSigner(request);
                        if (signer == null) return const SizedBox.shrink();

                        return Padding(
                          padding: const EdgeInsets.only(bottom: 8),
                          child: AppDocumentTile(
                            title: request.documentName,
                            subtitle1:
                                'From: ${request.requesterName ?? 'Unknown'}',
                            subtitle2: _getStatusLabel(signer),
                            trailing2: AppFormatter.dateShort(
                              request.createdAt,
                            ),
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
                              itemBuilder: (_) {
                                return [
                                  PopupMenuItem<String>(
                                    value: 'details',
                                    child: Row(
                                      children: [
                                        Icon(
                                          Icons.info_outline,
                                          size: 20,
                                          color: Theme.of(
                                            context,
                                          ).colorScheme.onSurface,
                                        ),
                                        const SizedBox(width: 12),
                                        Text(
                                          'Task Details',
                                          style: Theme.of(
                                            context,
                                          ).textTheme.bodyMedium,
                                        ),
                                      ],
                                    ),
                                  ),
                                ];
                              },
                            ),
                          ),
                        );
                      }),
                  ]),
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

class _TasksSearchBar extends GetView<TasksController> {
  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return TextField(
      controller: controller.searchController,
      onChanged: controller.onSearchChanged,
      style: Theme.of(context).textTheme.bodyLarge,
      decoration: InputDecoration(
        hintText: 'Search task',
        hintStyle: TextStyle(color: cs.onSurfaceVariant.withValues(alpha: 0.7)),
        prefixIcon: Icon(Icons.search, size: 20, color: cs.onSurfaceVariant),
        suffixIcon: Obx(
          () => controller.isSearching.value
              ? IconButton(
                  icon: Icon(Icons.close, size: 18, color: cs.onSurfaceVariant),
                  onPressed: controller.clearSearch,
                )
              : const SizedBox.shrink(),
        ),
      ),
    );
  }
}

class _TasksTopBar extends GetView<TasksController> {
  const _TasksTopBar();

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Row(
      children: [
        Text(
          'Sort by',
          style: Theme.of(
            context,
          ).textTheme.labelMedium?.copyWith(color: cs.onSurfaceVariant),
        ),
        const SizedBox(width: 8),
        Obx(() {
          final current = controller.sortOrder.value;
          return PopupMenuButton<SortOrder>(
            position: PopupMenuPosition.under,
            onSelected: controller.applySortOrder,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: cs.surfaceContainerHigh,
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: cs.outline),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    _sortLabel(current),
                    style: Theme.of(context).textTheme.labelMedium?.copyWith(
                      color: cs.onSurface,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(width: 6),
                  Icon(Icons.expand_more, size: 18, color: cs.onSurfaceVariant),
                ],
              ),
            ),
            itemBuilder: (_) => [
              _sortItem(context, SortOrder.dateNewest, 'Newest first'),
              _sortItem(context, SortOrder.dateOldest, 'Oldest first'),
              const PopupMenuDivider(height: 1),
              _sortItem(context, SortOrder.nameAsc, 'Name A-Z'),
              _sortItem(context, SortOrder.nameDesc, 'Name Z-A'),
            ],
          );
        }),
      ],
    );
  }

  PopupMenuItem<SortOrder> _sortItem(
    BuildContext context,
    SortOrder value,
    String label,
  ) {
    final cs = Theme.of(context).colorScheme;
    final isSelected = controller.sortOrder.value == value;
    return PopupMenuItem<SortOrder>(
      value: value,
      child: Row(
        children: [
          Expanded(
            child: Text(
              label,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: isSelected ? cs.primary : cs.onSurface,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
              ),
            ),
          ),
          if (isSelected) Icon(Icons.check, size: 16, color: cs.primary),
        ],
      ),
    );
  }

  String _sortLabel(SortOrder order) {
    switch (order) {
      case SortOrder.dateNewest:
        return 'Newest';
      case SortOrder.dateOldest:
        return 'Oldest';
      case SortOrder.nameAsc:
        return 'Name A-Z';
      case SortOrder.nameDesc:
        return 'Name Z-A';
      default:
        return 'Newest';
    }
  }
}

class _TasksTypeTabs extends GetView<TasksController> {
  const _TasksTypeTabs();

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final selected = controller.itemTypeFilter.value;
      return Wrap(
        spacing: 8,
        runSpacing: 8,
        children: [
          _TaskTypeTab(
            label: 'All',
            isSelected: selected == DocumentTypeFilter.all,
            onTap: () => controller.applyItemTypeFilter(DocumentTypeFilter.all),
          ),
          _TaskTypeTab(
            label: 'Folders',
            isSelected: selected == DocumentTypeFilter.folders,
            onTap: () =>
                controller.applyItemTypeFilter(DocumentTypeFilter.folders),
          ),
          _TaskTypeTab(
            label: 'PDF',
            isSelected: selected == DocumentTypeFilter.pdfs,
            onTap: () =>
                controller.applyItemTypeFilter(DocumentTypeFilter.pdfs),
          ),
        ],
      );
    });
  }
}

class _TaskTypeTab extends StatelessWidget {
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  const _TaskTypeTab({
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final selectedBg = cs.primary;
    final selectedText = cs.onPrimary;
    final idleBg = cs.surfaceContainerHigh;
    final idleText = cs.onSurfaceVariant;
    const tabRadius = 12.0;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(tabRadius),
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          curve: Curves.easeOut,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
          decoration: BoxDecoration(
            color: isSelected ? selectedBg : idleBg,
            borderRadius: BorderRadius.circular(tabRadius),
          ),
          child: Text(
            label,
            style: Theme.of(context).textTheme.titleSmall?.copyWith(
              color: isSelected ? selectedText : idleText,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ),
    );
  }
}
