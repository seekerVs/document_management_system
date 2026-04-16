import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../Model/breadcrumb_segment.dart';
import '../../../../../../Template/Utils/Routes/main_routes.dart';

class BreadcrumbTrail extends StatelessWidget {
  final List<BreadcrumbSegment> segments;

  const BreadcrumbTrail({
    super.key,
    required this.segments,
  });

  @override
  Widget build(BuildContext context) {
    if (segments.isEmpty) return const SizedBox.shrink();

    final cs = Theme.of(context).colorScheme;
    return Padding(
      padding: const EdgeInsets.only(top: 12),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          children: segments.asMap().entries.map((entry) {
            final idx = entry.key;
            final segment = entry.value;
            final isLast = idx == segments.length - 1;

            return Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                _buildSegment(
                  context,
                  segment.name,
                  onTap: isLast ? null : () => _navigateToSegment(segment),
                  isLast: isLast,
                ),
                if (!isLast) _buildDivider(cs),
              ],
            );
          }).toList(),
        ),
      ),
    );
  }

  void _navigateToSegment(BreadcrumbSegment segment) {
    if (segment.folderId == null) {
      // Go to root
      Get.until((route) => route.settings.name == MainRoutes.documents);
    } else {
      // Go to specific folder in history by popping until we find it
      Get.until((route) {
        final args = route.settings.arguments;
        if (args is Map && args['folder'] != null) {
          return args['folder'].folderId == segment.folderId;
        }
        return false;
      });
    }
  }

  Widget _buildSegment(
    BuildContext context,
    String name, {
    required VoidCallback? onTap,
    required bool isLast,
  }) {
    final cs = Theme.of(context).colorScheme;
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
        decoration: BoxDecoration(
          color: isLast ? cs.primaryContainer : cs.surfaceContainer,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Text(
          name,
          style: Theme.of(context).textTheme.labelMedium?.copyWith(
                color: isLast ? cs.primary : cs.onSurfaceVariant,
                fontWeight: isLast ? FontWeight.w600 : null,
              ),
        ),
      ),
    );
  }

  Widget _buildDivider(ColorScheme cs) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 4),
      child: Icon(
        Icons.chevron_right,
        size: 16,
        color: cs.onSurfaceVariant,
      ),
    );
  }
}

