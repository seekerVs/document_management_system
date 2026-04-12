import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../Controller/documents_controller.dart';
import '../../../../../../Template/Utils/Constant/enum.dart';

class SortMenu extends GetView<DocumentsController> {
  const SortMenu({super.key});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Obx(() {
      final current = controller.sortOrder.value;
      return PopupMenuButton<SortOrder>(
        position: PopupMenuPosition.under,
        icon: Icon(Icons.sort, color: cs.onSurfaceVariant),
        onSelected: controller.applySortOrder,
        itemBuilder: (_) => [
          _buildPopupItem(
            value: SortOrder.nameAsc,
            label: 'A-Z / 0-9',
            icon: Icons.expand_less_rounded,
            isSelected: current == SortOrder.nameAsc,
            cs: cs,
          ),
          _buildPopupItem(
            value: SortOrder.nameDesc,
            label: 'Z-A / 9-0',
            icon: Icons.expand_more_rounded,
            isSelected: current == SortOrder.nameDesc,
            cs: cs,
          ),
          const PopupMenuDivider(height: 1),
          _buildPopupItem(
            value: SortOrder.nameAsc,
            label: 'Name',
            icon: Icons.abc_rounded,
            isSelected:
                current == SortOrder.nameAsc || current == SortOrder.nameDesc,
            cs: cs,
          ),
          _buildPopupItem(
            value: SortOrder.sizeAsc,
            label: 'Size',
            icon: Icons.data_usage_rounded,
            isSelected:
                current == SortOrder.sizeAsc || current == SortOrder.sizeDesc,
            cs: cs,
          ),
          _buildPopupItem(
            value: SortOrder.dateNewest,
            label: 'Time modified',
            icon: Icons.calendar_today_rounded,
            isSelected:
                current == SortOrder.dateNewest ||
                current == SortOrder.dateOldest,
            cs: cs,
          ),
          _buildPopupItem(
            value: SortOrder.type,
            label: 'Type',
            icon: Icons.category_rounded,
            isSelected: current == SortOrder.type,
            cs: cs,
          ),
        ],
      );
    });
  }

  PopupMenuItem<SortOrder> _buildPopupItem({
    required SortOrder value,
    required String label,
    required IconData icon,
    required bool isSelected,
    required ColorScheme cs,
  }) {
    final theme = Get.context!;
    return PopupMenuItem<SortOrder>(
      value: value,
      child: Row(
        children: [
          Icon(
            icon,
            size: 20,
            color: isSelected ? cs.primary : cs.onSurface,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              label,
              style: Theme.of(theme).textTheme.bodyMedium?.copyWith(
                    color: isSelected ? cs.primary : cs.onSurface,
                    fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
                  ),
            ),
          ),
          if (isSelected)
            Icon(
              Icons.check,
              size: 16,
              color: cs.primary,
            ),
        ],
      ),
    );
  }
}
