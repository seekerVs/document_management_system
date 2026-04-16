import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../../../Commons/Widgets/app_document_tile.dart';
import '../../../../../Commons/Widgets/empty_state.dart';
import '../../../../../Commons/Widgets/loading_shimmer.dart';
import '../../../../../Commons/Widgets/section_header.dart';
import '../../../../../Utils/Formatters/formatter.dart';
import '../../../../../Commons/Widgets/app_pagination_bar.dart';
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

        final activities = controller.activities;

        if (activities.isEmpty) {
          return const EmptyState(
            icon: Icons.history_outlined,
            message: 'No activities yet',
            subtitle: 'Your document activities will appear here.',
          );
        }

        return RefreshIndicator(
          onRefresh: controller.loadActivities,
          child: CustomScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            slivers: [
              SliverPadding(
                padding: const EdgeInsets.fromLTRB(20, 8, 20, 0),
                sliver: SliverList(
                  delegate: SliverChildListDelegate([
                    const SectionHeader(title: 'Recents'),
                    const SizedBox(height: 8),
                    ...activities.map((activity) {
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 8),
                        child: AppDocumentTile(
                          title: activity.documentName ?? 'Untitled Document',
                          subtitle1: 'From: ${activity.actorName}',
                          subtitle2:
                              activity.action.name.capitalizeFirst ??
                              activity.action.name,
                          trailing2: AppFormatter.dateShort(activity.timestamp),
                          icon: Icons.draw_outlined,
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
}


