import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../../../Utils/Themes/component_themes.dart';
import '../Controller/documents_controller.dart';
import '../../../../../../Template/Utils/Constant/enum.dart';

class SortMenu extends GetView<DocumentsController> {
  const SortMenu({super.key});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Obx(() {
      final current = controller.sortOrder.value;
      return MenuAnchor(
        style: AppComponentThemes.appMenuStyle,
        menuChildren: [
          _SortItem(
            label: 'A-Z / 0-9',
            isSelected: current == SortOrder.nameAsc,
            onPressed: () => controller.applySortOrder(SortOrder.nameAsc),
          ),
          _SortItem(
            label: 'Z-A / 9-0',
            isSelected: current == SortOrder.nameDesc,
            onPressed: () => controller.applySortOrder(SortOrder.nameDesc),
          ),
          const Divider(height: 1, indent: 12, endIndent: 12),
          _SortItem(
            label: 'Name',
            isSelected:
                current == SortOrder.nameAsc || current == SortOrder.nameDesc,
            onPressed: () => controller.applySortOrder(SortOrder.nameAsc),
          ),
          _SortItem(
            label: 'Size',
            isSelected:
                current == SortOrder.sizeAsc || current == SortOrder.sizeDesc,
            onPressed: () => controller.applySortOrder(SortOrder.sizeAsc),
          ),
          _SortItem(
            label: 'Time modified',
            isSelected:
                current == SortOrder.dateNewest ||
                current == SortOrder.dateOldest,
            onPressed: () => controller.applySortOrder(SortOrder.dateNewest),
          ),
          _SortItem(
            label: 'Type',
            isSelected: current == SortOrder.type,
            onPressed: () => controller.applySortOrder(SortOrder.type),
          ),
        ],
        builder: (_, menuController, _) => IconButton(
          icon: Icon(Icons.sort, color: cs.onSurfaceVariant),
          onPressed: () => menuController.isOpen
              ? menuController.close()
              : menuController.open(),
        ),
      );
    });
  }
}

class _SortItem extends StatelessWidget {
  final String label;
  final bool isSelected;
  final VoidCallback onPressed;

  const _SortItem({
    required this.label,
    required this.isSelected,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return MenuItemButton(
      onPressed: onPressed,
      trailingIcon: isSelected
          ? Icon(Icons.check, size: 16, color: cs.primary)
          : const SizedBox(width: 16),
      style: isSelected
          ? ButtonStyle(
              foregroundColor: WidgetStatePropertyAll(cs.primary),
              textStyle: const WidgetStatePropertyAll(
                TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  fontFamily: 'Inter',
                ),
              ),
            )
          : null,
      child: Text(label),
    );
  }
}
