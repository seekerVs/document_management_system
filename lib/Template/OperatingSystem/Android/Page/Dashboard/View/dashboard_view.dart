import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import '../../../../../Commons/Widgets/app_avatar.dart';
import '../../../../../Utils/Constant/colors.dart';
import '../../../../../Utils/Constant/images.dart';
import '../Controller/dashboard_controller.dart';
import '../Widget/activity_section.dart';
import '../Widget/assigned_tasks_section.dart';
import '../Widget/dashboard_banner.dart';
import '../Widget/dashboard_fab.dart';
import '../Widget/recent_documents_section.dart';

class DashboardView extends GetView<DashboardController> {
  const DashboardView({super.key});

  @override
  Widget build(BuildContext context) {
    final bottomPadding = MediaQuery.of(context).padding.bottom;

    // FAB height (56) + margin (16) + gap (12)
    const fabHeight = 56.0;
    const fabMargin = 16.0;
    const fabGap = 12.0;

    final fabAreaBottom = fabHeight + fabMargin + fabGap + bottomPadding;

    return Scaffold(
      extendBody: true,
      appBar: _buildAppBar(context),
      floatingActionButton: const DashboardFab(),
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
      body: Stack(
        children: [
          /// MAIN CONTENT
          Obx(() {
            if (controller.isLoading.value) {
              return const Center(child: CircularProgressIndicator());
            }

            return RefreshIndicator(
              onRefresh: controller.loadDashboard,
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: EdgeInsets.fromLTRB(
                  20,
                  16,
                  20,
                  fabAreaBottom + 80, // dynamic bottom padding
                ),
                child: const Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    DashboardBanner(),
                    SizedBox(height: 24),
                    AssignedTasksSection(),
                    SizedBox(height: 24),
                    RecentDocumentsSection(),
                    SizedBox(height: 24),
                    ActivitySection(),
                  ],
                ),
              ),
            );
          }),

          /// SCRIM (overlay background)
          Obx(() {
            final isExpanded = controller.isFabExpanded.value;

            return Positioned(
              top: 0,
              left: 0,
              right: 0,
              bottom: -bottomPadding,
              child: IgnorePointer(
                ignoring: !isExpanded,
                child: AnimatedOpacity(
                  opacity: isExpanded ? 1.0 : 0.0,
                  duration: const Duration(milliseconds: 250),
                  child: GestureDetector(
                    onTap: controller.toggleFab,
                    behavior: HitTestBehavior.opaque,
                    child: ColoredBox(
                      color: AppColors.primaryDark.withAlpha(54),
                    ),
                  ),
                ),
              ),
            );
          }),

          /// FAB ACTIONS (overlay buttons)
          Obx(() {
            final isExpanded = controller.isFabExpanded.value;

            return Positioned(
              right: fabMargin,
              bottom: fabAreaBottom,
              child: IgnorePointer(
                ignoring: !isExpanded,
                child: AnimatedOpacity(
                  opacity: isExpanded ? 1.0 : 0.0,
                  duration: const Duration(milliseconds: 200),
                  child: const DashboardFabActions(),
                ),
              ),
            );
          }),
        ],
      ),
    );
  }

  PreferredSizeWidget _buildAppBar(BuildContext context) {
    return AppBar(
      centerTitle: false,
      titleSpacing: 0,
      leading: Padding(
        padding: const EdgeInsets.only(left: 16),
        child: SvgPicture.asset(
          AppImages.logo,
          width: 36,
          height: 36,
          colorFilter: const ColorFilter.mode(
            AppColors.primary,
            BlendMode.srcIn,
          ),
        ),
      ),
      title: Obx(
        () => Text(
          'Welcome ${controller.displayName.split(' ').first}!',
          style: Theme.of(context).textTheme.titleLarge,
        ),
      ),
      actions: [
        IconButton(
          icon: const Icon(Icons.help_outline, color: AppColors.textSecondary),
          onPressed: () {},
        ),
        Obx(
          () => Stack(
            children: [
              IconButton(
                icon: const Icon(
                  Icons.task_alt_outlined,
                  color: AppColors.textSecondary,
                ),
                onPressed: controller.goToTasks,
              ),
              if (controller.pendingTaskCount.value > 0)
                const Positioned(right: 8, top: 8, child: _NotificationDot()),
            ],
          ),
        ),
        GestureDetector(
          onTap: controller.goToProfile,
          child: Padding(
            padding: const EdgeInsets.only(right: 16),
            child: Obx(
              () => AppAvatar(name: controller.displayName, radius: 16),
            ),
          ),
        ),
      ],
    );
  }
}

class _NotificationDot extends StatelessWidget {
  const _NotificationDot();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 8,
      height: 8,
      decoration: const BoxDecoration(
        color: AppColors.error,
        shape: BoxShape.circle,
      ),
    );
  }
}
