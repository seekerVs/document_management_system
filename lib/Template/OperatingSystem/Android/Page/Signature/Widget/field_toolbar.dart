import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../../../Utils/Constant/enum.dart';
import '../Controller/signature_placement_controller.dart';

class SignatureFieldToolbar extends StatefulWidget {
  final SignaturePlacementController controller;
  final void Function(SignatureFieldType) onAddField;
  final VoidCallback onShowReassign;
  final VoidCallback onShowChangeType;

  const SignatureFieldToolbar({
    super.key,
    required this.controller,
    required this.onAddField,
    required this.onShowReassign,
    required this.onShowChangeType,
  });

  @override
  State<SignatureFieldToolbar> createState() => _SignatureFieldToolbarState();
}

class _SignatureFieldToolbarState extends State<SignatureFieldToolbar> {
  bool _isChangingType = false;
  String? _lastBoundFieldId;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 16),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceContainer,
        boxShadow: const [
          BoxShadow(
            color: Color(0x14000000),
            blurRadius: 12,
            offset: Offset(0, -4),
          ),
        ],
      ),
      child: Obx(() {
        final selectedId = widget.controller.selectedFieldId.value;

        // Auto-reset if field selection changes or is cleared
        if (selectedId != _lastBoundFieldId) {
          _isChangingType = false;
          _lastBoundFieldId = selectedId;
        }

        return AnimatedSwitcher(
          duration: const Duration(milliseconds: 250),
          child: selectedId == null
              ? _buildAddActions()
              : (_isChangingType
                    ? _buildChangeTypeActions()
                    : _buildEditActions()),
        );
      }),
    );
  }

  Widget _buildAddActions() {
    return Row(
      key: const ValueKey('add_actions'),
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        _ToolbarItem(
          icon: Icons.draw_outlined,
          label: 'Signature',
          onTap: () => widget.onAddField(SignatureFieldType.signature),
        ),
        _ToolbarItem(
          icon: Icons.draw_outlined, // Same with signature
          label: 'Initials',
          onTap: () => widget.onAddField(SignatureFieldType.initials),
        ),
        _ToolbarItem(
          icon: Icons.calendar_month_outlined,
          label: 'Date Signed',
          onTap: () => widget.onAddField(SignatureFieldType.dateSigned),
        ),
        _ToolbarItem(
          icon: Icons.text_fields_outlined,
          label: 'Textbox',
          onTap: () => widget.onAddField(SignatureFieldType.textbox),
        ),
      ],
    );
  }

  Widget _buildEditActions() {
    final entry = widget.controller.allFields.firstWhereOrNull(
      (e) => e.field.fieldId == widget.controller.selectedFieldId.value,
    );
    final isRequired = entry?.field.isRequired ?? true;

    return Row(
      key: const ValueKey('edit_actions'),
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        _ToolbarItem(
          icon: Icons.swap_horiz,
          label: 'Reassign',
          onTap: widget.onShowReassign,
          themeOverride: (
            surface: Theme.of(context).colorScheme.primary,
            icon: Theme.of(context).colorScheme.onPrimary,
          ),
        ),
        _ToolbarItem(
          icon: isRequired ? Icons.lock_outline : Icons.lock_open_outlined,
          label: isRequired ? 'Required' : 'Optional',
          onTap: widget.controller.toggleSelectedFieldRequired,
          themeOverride: (
            surface: isRequired
                ? Theme.of(context).colorScheme.primary
                : Theme.of(context).colorScheme.surfaceContainerHigh,
            icon: isRequired
                ? Theme.of(context).colorScheme.onPrimary
                : Theme.of(context).colorScheme.onSurface,
          ),
        ),
        _ToolbarItem(
          icon: Icons.category_outlined,
          label: 'Field Type',
          onTap: () => setState(() => _isChangingType = true),
          themeOverride: (
            surface: Theme.of(context).colorScheme.primary,
            icon: Theme.of(context).colorScheme.onPrimary,
          ),
        ),
        _ToolbarItem(
          icon: Icons.delete_outline,
          label: 'Delete',
          onTap: widget.controller.deleteSelectedField,
          themeOverride: (
            surface: Theme.of(context).colorScheme.error,
            icon: Theme.of(context).colorScheme.onError,
          ),
        ),
      ],
    );
  }

  Widget _buildChangeTypeActions() {
    final entry = widget.controller.allFields.firstWhereOrNull(
      (e) => e.field.fieldId == widget.controller.selectedFieldId.value,
    );
    final currentType = entry?.field.type;

    return Row(
      key: const ValueKey('change_type_actions'),
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        _ToolbarItem(
          icon: Icons.draw_outlined,
          label: 'Signature',
          onTap: () => _updateType(SignatureFieldType.signature),
          themeOverride: (
            surface: currentType == SignatureFieldType.signature
                ? Theme.of(context).colorScheme.primary
                : Theme.of(context).colorScheme.surfaceContainerHigh,
            icon: currentType == SignatureFieldType.signature
                ? Theme.of(context).colorScheme.onPrimary
                : Theme.of(context).colorScheme.onSurface,
          ),
        ),
        _ToolbarItem(
          icon: Icons.draw_outlined,
          label: 'Initials',
          onTap: () => _updateType(SignatureFieldType.initials),
          themeOverride: (
            surface: currentType == SignatureFieldType.initials
                ? Theme.of(context).colorScheme.primary
                : Theme.of(context).colorScheme.surfaceContainerHigh,
            icon: currentType == SignatureFieldType.initials
                ? Theme.of(context).colorScheme.onPrimary
                : Theme.of(context).colorScheme.onSurface,
          ),
        ),
        _ToolbarItem(
          icon: Icons.calendar_month_outlined,
          label: 'Date Signed',
          onTap: () => _updateType(SignatureFieldType.dateSigned),
          themeOverride: (
            surface: currentType == SignatureFieldType.dateSigned
                ? Theme.of(context).colorScheme.primary
                : Theme.of(context).colorScheme.surfaceContainerHigh,
            icon: currentType == SignatureFieldType.dateSigned
                ? Theme.of(context).colorScheme.onPrimary
                : Theme.of(context).colorScheme.onSurface,
          ),
        ),
        _ToolbarItem(
          icon: Icons.text_fields_outlined,
          label: 'Textbox',
          onTap: () => _updateType(SignatureFieldType.textbox),
          themeOverride: (
            surface: currentType == SignatureFieldType.textbox
                ? Theme.of(context).colorScheme.primary
                : Theme.of(context).colorScheme.surfaceContainerHigh,
            icon: currentType == SignatureFieldType.textbox
                ? Theme.of(context).colorScheme.onPrimary
                : Theme.of(context).colorScheme.onSurface,
          ),
        ),
      ],
    );
  }

  void _updateType(SignatureFieldType type) {
    widget.controller.changeSelectedFieldType(type);
    setState(() => _isChangingType = false);
  }
}

class _ToolbarItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;
  final ({Color surface, Color icon})? themeOverride;

  const _ToolbarItem({
    required this.icon,
    required this.label,
    required this.onTap,
    this.themeOverride,
  });

  @override
  Widget build(BuildContext context) {
    final themeSurfaceColor =
        themeOverride?.surface ?? Theme.of(context).colorScheme.primary;
    final themeIconColor =
        themeOverride?.icon ?? Theme.of(context).colorScheme.onPrimary;

    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 52,
              height: 52,
              decoration: BoxDecoration(
                color: themeSurfaceColor,
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: themeSurfaceColor.withValues(alpha: 0.15),
                    blurRadius: 8,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Icon(icon, color: themeIconColor, size: 24),
            ),
            const SizedBox(height: 8),
            Text(
              label,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: Theme.of(context).colorScheme.onSurface,
                fontSize: 10.5,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
