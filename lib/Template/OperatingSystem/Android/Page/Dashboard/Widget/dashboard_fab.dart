import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import '../Controller/dashboard_controller.dart';
import '../../Signature/Controller/signature_request_controller.dart';
import '../../../../../../Template/Utils/Constant/colors.dart';

// Only the FAB circle — lives in the floatingActionButton slot.
class DashboardFab extends StatelessWidget {
  const DashboardFab({super.key});

  DashboardController get _dashController => Get.find<DashboardController>();

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final isExpanded = _dashController.isFabExpanded.value;
      return PopScope(
        canPop: !isExpanded,
        onPopInvokedWithResult: (didPop, _) {
          if (!didPop) _dashController.toggleFab();
        },
        child: FloatingActionButton(
          onPressed: () {
            HapticFeedback.lightImpact();
            _dashController.toggleFab();
          },
          child: AnimatedRotation(
            turns: isExpanded ? 0.125 : 0,
            duration: const Duration(milliseconds: 250),
            curve: Curves.easeInOut,
            child: AnimatedSwitcher(
              duration: const Duration(milliseconds: 200),
              child: Icon(
                isExpanded ? Icons.close : Icons.add,
                key: ValueKey(isExpanded),
              ),
            ),
          ),
        ),
      );
    });
  }
}

// Action items — lives in the body Stack via Positioned in DashboardView.
// Show/hide and pointer blocking are handled by the parent (AnimatedOpacity
// + IgnorePointer in dashboard_view.dart), so this widget always renders
// its children unconditionally — no ever() listener or visibility logic needed.
class DashboardFabActions extends StatefulWidget {
  const DashboardFabActions({super.key});

  @override
  State<DashboardFabActions> createState() => _DashboardFabActionsState();
}

class _DashboardFabActionsState extends State<DashboardFabActions>
    with SingleTickerProviderStateMixin {
  late final AnimationController _animController;

  DashboardController get _dashController => Get.find<DashboardController>();
  SignatureRequestController get _sigController =>
      Get.find<SignatureRequestController>();

  static const _actions = [
    _ActionDef(icon: Icons.add_circle_outline, label: 'Add Document'),
    _ActionDef(icon: Icons.draw_outlined, label: 'Request Signature'),
  ];

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 250),
    );
    ever(_dashController.isFabExpanded, (expanded) {
      if (!mounted) return;
      if (expanded) {
        _animController.forward();
      } else {
        _animController.reverse();
      }
    });
  }

  @override
  void dispose() {
    _animController.dispose();
    super.dispose();
  }

  void _onActionTap(int index) {
    _dashController.toggleFab();
    Future.microtask(() {
      if (index == 0) _dashController.goToDocuments();
      if (index == 1) _sigController.showDocumentSourceSheet();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.end,
      children: _actions.asMap().entries.map((entry) {
        final index = entry.key;
        final action = entry.value;
        final staggerDelay = index * 50;
        final begin = staggerDelay / _animController.duration!.inMilliseconds;
        final interval = Interval(
          begin.clamp(0.0, 1.0),
          1.0,
          curve: Curves.easeOut,
        );
        final fadeAnim = Tween<double>(
          begin: 0,
          end: 1,
        ).animate(CurvedAnimation(parent: _animController, curve: interval));
        final slideAnim = Tween<Offset>(
          begin: const Offset(0, 0.3),
          end: Offset.zero,
        ).animate(CurvedAnimation(parent: _animController, curve: interval));

        return Padding(
          padding: const EdgeInsets.only(bottom: 12),
          child: FadeTransition(
            opacity: fadeAnim,
            child: SlideTransition(
              position: slideAnim,
              child: _FabAction(
                icon: action.icon,
                label: action.label,
                onTap: () => _onActionTap(index),
              ),
            ),
          ),
        );
      }).toList(),
    );
  }
}

class _FabAction extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  const _FabAction({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppColors.primary,
      borderRadius: BorderRadius.circular(12),
      elevation: 4,
      shadowColor: AppColors.primary.withOpacity(0.4),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        splashColor: Colors.white24,
        highlightColor: Colors.white12,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, color: AppColors.textOnPrimary, size: 20),
              const SizedBox(width: 10),
              Text(
                label,
                style: const TextStyle(
                  color: AppColors.textOnPrimary,
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  fontFamily: 'Inter',
                  decoration: TextDecoration.none,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ActionDef {
  final IconData icon;
  final String label;
  const _ActionDef({required this.icon, required this.label});
}
