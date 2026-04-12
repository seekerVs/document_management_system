import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../Controller/documents_controller.dart';

class MultiSelectBar extends GetView<DocumentsController> {
  const MultiSelectBar({super.key});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
      decoration: BoxDecoration(
        color: cs.surfaceContainer,
        border: Border(top: BorderSide(color: cs.outlineVariant)),
      ),
      child: SafeArea(
        top: false,
        child: Obx(() {
          final isSingle = controller.isSingleSelection;
          return Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _BarAction(
                icon: Icons.copy_outlined,
                label: 'Copy',
                onTap: controller.showCopyPicker,
              ),
              _BarAction(
                icon: Icons.drive_file_move_outlined,
                label: 'Move',
                onTap: controller.showMovePicker,
              ),
              _BarAction(
                icon: Icons.delete_outline,
                label: 'Delete',
                color: cs.error,
                onTap: controller.deleteSelected,
              ),
              // Rename — disabled when more than 1 item selected
              _BarAction(
                icon: Icons.edit_outlined,
                label: 'Rename',
                onTap: isSingle ? controller.renameSelected : null,
              ),
              _MoreMenu(),
            ],
          );
        }),
      ),
    );
  }
}

// ─── More MenuAnchor ──────────────────────────────────────────────────────────

class _MoreMenu extends GetView<DocumentsController> {
  final GlobalKey<PopupMenuButtonState<String>> _menuKey = GlobalKey();

  @override
  Widget build(BuildContext context) {
    return PopupMenuButton<String>(
      key: _menuKey,
      onSelected: (value) {
        if (value == 'details') controller.showSelectedDetails();
        if (value == 'share') controller.shareSelected();
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
              Text('Details', style: Theme.of(context).textTheme.bodyMedium),
            ],
          ),
        ),
        PopupMenuItem(
          value: 'share',
          child: Row(
            children: [
              Icon(
                Icons.share_outlined,
                size: 20,
                color: Theme.of(context).colorScheme.onSurface,
              ),
              const SizedBox(width: 12),
              Text('Share', style: Theme.of(context).textTheme.bodyMedium),
            ],
          ),
        ),
      ],
      child: _BarAction(
        icon: Icons.more_horiz,
        label: 'More',
        onTap: () => _menuKey.currentState?.showButtonMenu(),
      ),
    );
  }
}

// ─── Bar action button ────────────────────────────────────────────────────────

class _BarAction extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback? onTap;
  final Color? color;

  const _BarAction({
    required this.icon,
    required this.label,
    required this.onTap,
    this.color,
  });

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final c = onTap == null
        ? cs.onSurfaceVariant.withValues(alpha: 0.38)
        : (color ?? cs.onSurfaceVariant);

    return GestureDetector(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 4),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, color: c, size: 22),
            const SizedBox(height: 2),
            Text(label, style: TextStyle(fontSize: 11, color: c)),
          ],
        ),
      ),
    );
  }
}
