import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import '../../../../../Commons/Widgets/app_avatar.dart';
import '../../../../../Utils/Constant/images.dart';
import '../Controller/dashboard_controller.dart';
import '../Widget/activity_section.dart';
import '../Widget/assigned_tasks_section.dart';
import '../Widget/dashboard_banner.dart';
import '../Widget/dashboard_fab.dart';
import '../Widget/dashboard_shimmer.dart';
import '../Widget/recent_documents_section.dart';
import '../../../../../Utils/Helpers/fab_location_helper.dart';
import '../../Faq/View/faq_view.dart';

class DashboardView extends GetView<DashboardController> {
  const DashboardView({super.key});

  @override
  Widget build(BuildContext context) {
    final bottomPadding = MediaQuery.paddingOf(context).bottom;

    // FAB height (56) + margin (16) + gap (12)
    const fabHeight = 56.0;
    const fabMargin = 16.0;
    const fabGap = 12.0;

    final fabAreaBottom = fabHeight + fabMargin + fabGap + bottomPadding;

    return Scaffold(
      extendBody: true,
      appBar: _buildAppBar(context),
      floatingActionButton: const DashboardFab(),
      floatingActionButtonLocation: SafeEndFloatFabLocation(bottomPadding),
      body: Stack(
        children: [
          /// MAIN CONTENT
          Positioned.fill(
            child: Obx(() {
              if (controller.isLoading.value) {
                return SingleChildScrollView(
                  physics: const NeverScrollableScrollPhysics(),
                  padding: EdgeInsets.fromLTRB(
                    20,
                    16,
                    20,
                    fabAreaBottom + 16, // dynamic bottom padding
                  ),
                  child: Center(
                    child: ConstrainedBox(
                      constraints: const BoxConstraints(maxWidth: 800),
                      child: const DashboardShimmer(),
                    ),
                  ),
                );
              }

              return RefreshIndicator(
                onRefresh: controller.loadDashboard,
                child: SingleChildScrollView(
                  physics: const AlwaysScrollableScrollPhysics(),
                  padding: EdgeInsets.fromLTRB(
                    20,
                    16,
                    20,
                    fabAreaBottom + 16, // dynamic bottom padding
                  ),
                  child: Center(
                    child: ConstrainedBox(
                      constraints: const BoxConstraints(maxWidth: 800),
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
                  ),
                ),
              );
            }),
          ),

          /// SCRIM (overlay background)
          Obx(() {
            final isExpanded = controller.isFabExpanded.value;

            return Positioned.fill(
              child: IgnorePointer(
                ignoring: !isExpanded,
                child: AnimatedOpacity(
                  opacity: isExpanded ? 1.0 : 0.0,
                  duration: const Duration(milliseconds: 250),
                  child: GestureDetector(
                    onTap: controller.toggleFab,
                    behavior: HitTestBehavior.opaque,
                    child: ColoredBox(
                      color: Theme.of(
                        context,
                      ).colorScheme.scrim.withValues(alpha: 0.2),
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
                  duration: const Duration(milliseconds: 300),
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
          colorFilter: ColorFilter.mode(
            Theme.of(context).colorScheme.primary,
            BlendMode.srcIn,
          ),
        ),
      ),
      title: Obx(
        () => Text(
          'Welcome ${controller.displayName.split(' ').first}!',
          style: Theme.of(context).textTheme.titleMedium,
        ),
      ),
      actions: [
        IconButton(
          icon: Icon(
            Icons.help_outline,
            color: Theme.of(context).colorScheme.onSurfaceVariant,
            size: 24, // Standard Material icon size
          ),
          onPressed: () => Get.to(() => const FaqView()),
        ),
        Obx(
          () => Stack(
            alignment: Alignment.center,
            children: [
              IconButton(
                icon: Icon(
                  Icons.format_list_bulleted_rounded,
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                  size: 24, // Standard Material icon size
                ),
                onPressed: controller.goToTasks,
              ),
              if (controller.pendingTaskCount.value > 0)
                const Positioned(right: 10, top: 10, child: _NotificationDot()),
            ],
          ),
        ),
        const SizedBox(width: 4), // Spacing before avatar
        Center(
          child: InkWell(
            customBorder: const CircleBorder(),
            onTap: controller.goToProfile,
            child: Obx(
              () => AppAvatar(
                name: controller.displayName,
                photoUrl: controller.photoUrl,
                radius: 16, // 32x32 pixels, standard for AppBar avatars
              ),
            ),
          ),
        ),
        const SizedBox(width: 16), // Standard right margin
      ],
    );
  }
}

class _NotificationDot extends StatelessWidget {
  const _NotificationDot();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 10,
      height: 10,
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.error,
        shape: BoxShape.circle,
        border: Border.all(
          color: Theme.of(context).colorScheme.surface,
          width: 1.5,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            blurRadius: 2,
            offset: const Offset(0, 1),
          ),
        ],
      ),
    );
  }
}
