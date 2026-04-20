import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../../../Commons/Widgets/app_document_tile.dart';
import '../../../../../Commons/Widgets/empty_state.dart';
import '../../../../../Commons/Widgets/loading_shimmer.dart';
import '../../../../../Commons/Widgets/section_header.dart';
import '../../../../../Utils/Constant/enum.dart';
import '../../../../../Utils/Formatters/formatter.dart';
import '../Controller/activity_controller.dart';

class ActivityView extends GetView<ActivityController> {
  const ActivityView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Activity'),
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

        if (controller.allActivitiesCount == 0) {
          return const EmptyState(
            icon: Icons.history_outlined,
            message: 'No activities yet',
            subtitle: 'Your document activities will appear here.',
          );
        }

        final activities = controller.activities;

        return RefreshIndicator(
          onRefresh: controller.loadActivities,
          child: CustomScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            slivers: [
              SliverPadding(
                padding: const EdgeInsets.fromLTRB(20, 8, 20, 0),
                sliver: SliverList(
                  delegate: SliverChildListDelegate([
                    _ActivitySearchBar(),
                    const SizedBox(height: 12),
                    const SectionHeader(title: 'Recents'),
                    const SizedBox(height: 8),
                    const _ActivityTypeFilters(),
                    const SizedBox(height: 8),
                    if (activities.isEmpty)
                      Padding(
                        padding: const EdgeInsets.only(top: 16),
                        child: EmptyState(
                          icon: controller.isSearching.value
                              ? Icons.search_off
                              : Icons.filter_alt_off,
                          message: controller.isSearching.value
                              ? 'No activities found'
                              : 'No matching activities',
                          subtitle: controller.isSearching.value
                              ? 'Try a different keyword.'
                              : 'Try another filter.',
                        ),
                      )
                    else
                      ...activities.map((activity) {
                        return Padding(
                          padding: const EdgeInsets.only(bottom: 8),
                          child: AppDocumentTile(
                            title: activity.documentName ?? 'Untitled Document',
                            subtitle1: 'From: ${activity.actorName}',
                            subtitle2:
                                activity.action.name.capitalizeFirst ??
                                activity.action.name,
                            trailing2: AppFormatter.dateShort(
                              activity.timestamp,
                            ),
                            icon: Icons.draw_outlined,
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
}

class _ActivitySearchBar extends GetView<ActivityController> {
  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return TextField(
      controller: controller.searchController,
      onChanged: controller.onSearchChanged,
      style: Theme.of(context).textTheme.bodyLarge,
      decoration: InputDecoration(
        hintText: 'Search activity',
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

class _ActivityTypeFilters extends GetView<ActivityController> {
  const _ActivityTypeFilters();

  static const _filters = [
    (label: 'All', value: DocumentTypeFilter.all),
    (label: 'Folders', value: DocumentTypeFilter.folders),
    (label: 'PDF', value: DocumentTypeFilter.pdfs),
  ];

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return Obx(() {
      final selected = controller.itemTypeFilter.value;
      final selectedIndex = _filters
          .indexWhere((f) => f.value == selected)
          .clamp(0, _filters.length - 1);

      return Container(
        height: 40,
        padding: const EdgeInsets.all(3),
        decoration: BoxDecoration(
          color: cs.surfaceContainerHigh,
          borderRadius: BorderRadius.circular(12),
        ),
        child: LayoutBuilder(
          builder: (context, constraints) {
            final tabWidth = constraints.maxWidth / _filters.length;

            return Stack(
              children: [
                // Sliding indicator
                AnimatedPositioned(
                  duration: const Duration(milliseconds: 200),
                  curve: Curves.easeInOut,
                  left: selectedIndex * tabWidth,
                  top: 0,
                  bottom: 0,
                  width: tabWidth,
                  child: Container(
                    decoration: BoxDecoration(
                      color: cs.surface,
                      borderRadius: BorderRadius.circular(9),
                      boxShadow: [
                        BoxShadow(
                          color: cs.shadow.withValues(alpha: 0.08),
                          blurRadius: 4,
                          offset: const Offset(0, 1),
                        ),
                      ],
                    ),
                  ),
                ),
                // Tab labels
                Row(
                  children: _filters.map((filter) {
                    final isSelected = filter.value == selected;
                    return Expanded(
                      child: GestureDetector(
                        behavior: HitTestBehavior.opaque,
                        onTap: () =>
                            controller.applyItemTypeFilter(filter.value),
                        child: AnimatedDefaultTextStyle(
                          duration: const Duration(milliseconds: 200),
                          style: Theme.of(context).textTheme.labelMedium!
                              .copyWith(
                                color: isSelected
                                    ? cs.onSurface
                                    : cs.onSurfaceVariant,
                                fontWeight: isSelected
                                    ? FontWeight.w600
                                    : FontWeight.w500,
                              ),
                          child: Center(child: Text(filter.label)),
                        ),
                      ),
                    );
                  }).toList(),
                ),
              ],
            );
          },
        ),
      );
    });
  }
}
