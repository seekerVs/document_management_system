import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../Controller/dashboard_controller.dart';
import 'activity_section.dart';
import 'assigned_tasks_section.dart';
import '../View/dashboard_banner.dart';
import 'recent_documents_section.dart';

// 📁 lib/Template/OperatingSystem/Android/Page/Welcome/View/dashboard_view.dart

class DashboardView extends GetView<DashboardController> {
  const DashboardView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: _buildAppBar(context),
      body: Obx(() {
        if (controller.isLoading.value) {
          return const Center(child: CircularProgressIndicator());
        }
        return RefreshIndicator(
          onRefresh: controller.loadDashboard,
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Greeting
                Text(
                  'Welcome !',
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Obx(
                  () => Text(
                    controller.displayName,
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: Theme.of(context).colorScheme.outline,
                    ),
                  ),
                ),

                const SizedBox(height: 20),

                // Banner
                const DashboardBanner(),

                const SizedBox(height: 24),

                // Assigned tasks
                const AssignedTasksSection(),

                const SizedBox(height: 24),

                // Recent documents
                const RecentDocumentsSection(),

                const SizedBox(height: 24),

                // Activity feed
                const ActivitySection(),

                const SizedBox(height: 32),
              ],
            ),
          ),
        );
      }),
      floatingActionButton: FloatingActionButton(
        onPressed: controller.goToDocuments,
        child: const Icon(Icons.add),
      ),
    );
  }

  PreferredSizeWidget _buildAppBar(BuildContext context) {
    return AppBar(
      leading: Padding(
        padding: const EdgeInsets.all(10),
        child: Container(
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.primary,
            borderRadius: BorderRadius.circular(8),
          ),
          child: const Icon(
            Icons.description_outlined,
            color: Colors.white,
            size: 20,
          ),
        ),
      ),
      title: const Text('Welcome !'),
      actions: [
        // Notification bell with badge
        Obx(
          () => Stack(
            children: [
              IconButton(
                icon: const Icon(Icons.notifications_outlined),
                onPressed: controller.goToNotifications,
              ),
              if (controller.unreadCount.value > 0)
                Positioned(
                  right: 8,
                  top: 8,
                  child: Container(
                    width: 8,
                    height: 8,
                    decoration: BoxDecoration(
                      color: Theme.of(context).colorScheme.error,
                      shape: BoxShape.circle,
                    ),
                  ),
                ),
            ],
          ),
        ),

        // Help icon
        IconButton(icon: const Icon(Icons.help_outline), onPressed: () {}),

        // Profile avatar
        GestureDetector(
          onTap: controller.goToProfile,
          child: Padding(
            padding: const EdgeInsets.only(right: 12),
            child: Obx(
              () => CircleAvatar(
                radius: 16,
                backgroundColor: Theme.of(context).colorScheme.primary,
                child: Text(
                  controller.displayName.isNotEmpty
                      ? controller.displayName[0].toUpperCase()
                      : '?',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
