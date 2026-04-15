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
                    child: const _PaginationBar(),
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

class _PaginationBar extends GetView<TasksController> {
  const _PaginationBar();

  static const double _chipSize = 48.0;
  static const double _chipSpacing = 4.0;
  static const double _borderRadius = 10.0;

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final totalPages = controller.totalPages;
      if (totalPages <= 1) return const SizedBox.shrink();

      final current = controller.currentPage.value;
      final pages = _buildVisiblePages(current, totalPages);
      final isBusy = controller.isPageLoading.value;

      return Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        child: Center(
          child: FittedBox(
            fit: BoxFit.scaleDown,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              mainAxisSize: MainAxisSize.min,
              children: [
                _PageNavButton(
                  icon: Icons.chevron_left_rounded,
                  enabled: current > 1 && !isBusy,
                  onTap: controller.previousPage,
                  size: _chipSize,
                  borderRadius: _borderRadius,
                ),
                const SizedBox(width: _chipSpacing),
                ...pages.map((page) {
                  if (page == 0) {
                    return SizedBox(
                      width: _chipSize + _chipSpacing,
                      height: _chipSize,
                    );
                  }
                  if (page == -1) {
                    return Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: _chipSpacing / 2,
                      ),
                      child: _EllipsisChip(
                        size: _chipSize,
                        borderRadius: _borderRadius,
                      ),
                    );
                  }
                  return Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: _chipSpacing / 2,
                    ),
                    child: _PageNumberChip(
                      page: page,
                      isActive: page == current,
                      onTap: isBusy ? null : () => controller.goToPage(page),
                      size: _chipSize,
                      borderRadius: _borderRadius,
                    ),
                  );
                }),
                const SizedBox(width: _chipSpacing),
                _PageNavButton(
                  icon: Icons.chevron_right_rounded,
                  enabled: current < totalPages && !isBusy,
                  onTap: controller.nextPage,
                  size: _chipSize,
                  borderRadius: _borderRadius,
                ),
              ],
            ),
          ),
        ),
      );
    });
  }

  List<int> _buildVisiblePages(int current, int total) {
    if (total <= 4) {
      final pages = List.generate(total, (i) => i + 1);
      while (pages.length < 4) {
        pages.add(0);
      }
      return pages;
    }

    if (current <= 2) {
      return [1, 2, -1, total];
    }

    if (current >= total - 1) {
      return [1, -1, total - 1, total];
    }

    return [1, current, -1, total];
  }
}

class _PageNumberChip extends StatelessWidget {
  final int page;
  final bool isActive;
  final VoidCallback? onTap;
  final double size;
  final double borderRadius;

  const _PageNumberChip({
    required this.page,
    required this.isActive,
    required this.onTap,
    required this.size,
    required this.borderRadius,
  });

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return AnimatedContainer(
      duration: const Duration(milliseconds: 180),
      curve: Curves.easeInOut,
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: isActive ? cs.primary : Colors.transparent,
        borderRadius: BorderRadius.circular(borderRadius),
        border: isActive
            ? null
            : Border.all(color: cs.outlineVariant, width: 1.2),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(borderRadius),
          onTap: onTap,
          child: Center(
            child: Text(
              '$page',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                fontWeight: isActive ? FontWeight.w700 : FontWeight.w500,
                color: isActive ? cs.onPrimary : cs.onSurfaceVariant,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _EllipsisChip extends StatelessWidget {
  final double size;
  final double borderRadius;

  const _EllipsisChip({required this.size, required this.borderRadius});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(borderRadius),
        border: Border.all(color: cs.outlineVariant, width: 1.2),
      ),
      child: Center(
        child: Text(
          '···',
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
            color: cs.onSurfaceVariant,
            fontWeight: FontWeight.w600,
            letterSpacing: 1.5,
          ),
        ),
      ),
    );
  }
}

class _PageNavButton extends StatelessWidget {
  final IconData icon;
  final bool enabled;
  final Future<void> Function() onTap;
  final double size;
  final double borderRadius;

  const _PageNavButton({
    required this.icon,
    required this.enabled,
    required this.onTap,
    required this.size,
    required this.borderRadius,
  });

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(borderRadius),
        border: Border.all(
          color: enabled
              ? cs.outlineVariant
              : cs.outlineVariant.withValues(alpha: 0.4),
          width: 1.2,
        ),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(borderRadius),
          onTap: enabled ? () => onTap() : null,
          child: Center(
            child: Icon(
              icon,
              size: 18,
              color: enabled ? cs.primary : cs.onSurface.withValues(alpha: 0.3),
            ),
          ),
        ),
      ),
    );
  }
}
