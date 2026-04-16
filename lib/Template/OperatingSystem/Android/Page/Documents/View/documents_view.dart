import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../../../Commons/Widgets/empty_state.dart';
import '../Controller/documents_controller.dart';
import '../Model/document_model.dart';
import '../Model/folder_model.dart';
import '../Widget/document_grid_card.dart';
import '../Widget/document_list_tile.dart';
import '../Widget/documents_toolbar.dart';
import '../Widget/documents_shimmer.dart';
import '../Widget/folder_grid_card.dart';
import '../Widget/folder_list_tile.dart';
import '../Widget/multiselect_bar.dart';
import '../Widget/storage_banner.dart';

class DocumentsView extends GetView<DocumentsController> {
  const DocumentsView({super.key});

  @override
  Widget build(BuildContext context) {
    return PopScope(
      onPopInvokedWithResult: (didPop, dynamic result) {
        if (controller.isPickerMode.value) controller.stopPickerMode();
      },
      child: Scaffold(
        resizeToAvoidBottomInset: false,
        appBar: _buildAppBar(context),
        body: Stack(
          children: [
            Positioned.fill(
              child: GestureDetector(
                onTap: () => FocusScope.of(context).unfocus(),
                behavior: HitTestBehavior.opaque,
                child: Obx(() {
                  if (controller.isLoading.value) {
                    return SingleChildScrollView(
                      physics: const NeverScrollableScrollPhysics(),
                      padding: const EdgeInsets.fromLTRB(20, 16, 20, 16),
                      child: Center(
                        child: ConstrainedBox(
                          constraints: const BoxConstraints(maxWidth: 800),
                          child: DocumentsShimmer(
                            isGridView: controller.isGridView.value,
                          ),
                        ),
                      ),
                    );
                  }

                return RefreshIndicator(
                  onRefresh: controller.loadAll,
                  child: SingleChildScrollView(
                    physics: const AlwaysScrollableScrollPhysics(),
                    padding: const EdgeInsets.fromLTRB(20, 16, 20, 16),
                    child: Center(
                      child: ConstrainedBox(
                        constraints: const BoxConstraints(maxWidth: 800),
                        child: Column(
                          children: [
                            _SearchBar(),
                            const SizedBox(height: 12),
                            const StorageBanner(),
                            DocumentsToolbar(),
                            const SizedBox(height: 8),
                            _Body(),
                          ],
                        ),
                      ),
                    ),
                  ),
                );
              }),
            ),
          ),
        ],
      ),
      bottomNavigationBar: Obx(
        () => controller.isMultiSelect.value
            ? const MultiSelectBar()
            : const SizedBox.shrink(),
      ),
    );
  }

  PreferredSizeWidget _buildAppBar(BuildContext context) {
    return AppBar(
      title: Obx(
        () => Text(
          controller.isPickerMode.value ? 'Select Document' : 'My Document',
        ),
      ),
      leading: Obx(
        () => IconButton(
          icon: Icon(
            controller.isPickerMode.value ? Icons.close : Icons.chevron_left,
          ),
          onPressed: () {
            if (controller.isPickerMode.value) controller.stopPickerMode();
            Get.back();
          },
        ),
      ),
      actions: [
        Obx(
          () => controller.isMultiSelect.value
              ? TextButton(
                  onPressed: controller.exitMultiSelect,
                  style: TextButton.styleFrom(
                    padding: const EdgeInsets.only(right: 16),
                  ),
                  child: const Text('Cancel'),
                )
              : const SizedBox.shrink(),
        ),
      ],
    );
  }
}

// ─── Search Bar ───────────────────────────────────────────────────────────────

class _SearchBar extends GetView<DocumentsController> {
  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return TextField(
      controller: controller.searchController,
      onChanged: controller.onSearchChanged,
      style: Theme.of(context).textTheme.bodyLarge,
      decoration: InputDecoration(
        hintText: 'Search document',
        hintStyle: TextStyle(color: cs.onSurfaceVariant.withValues(alpha: 0.7)),
        prefixIcon: Icon(Icons.search, size: 20, color: cs.onSurfaceVariant),
        suffixIcon: Obx(
          () => controller.isSearching.value
              ? IconButton(
                  icon: Icon(Icons.close, size: 18, color: cs.onSurfaceVariant),
                  onPressed: controller.clearSearch,
                )
              : const SizedBox.shrink(),
        ),
      ),
    );
  }
}

// ─── Body ─────────────────────────────────────────────────────────────────────

class _Body extends GetView<DocumentsController> {
  @override
  Widget build(BuildContext context) {
    return Obx(() {
      if (controller.isSearching.value) {
        if (controller.searchResults.isEmpty) {
          return const EmptyState(
            icon: Icons.search_off,
            message: 'No documents found',
          );
        }
        return ListView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          padding: EdgeInsets.zero,
          itemCount: controller.searchResults.length,
          itemBuilder: (_, i) =>
              DocumentListTile(doc: controller.searchResults[i]),
        );
      }

      if (controller.folders.isEmpty && controller.documents.isEmpty) {
        return const EmptyState(
          icon: Icons.folder_open_outlined,
          message: 'No documents yet',
          subtitle: 'Tap + New to upload a file or create a folder',
        );
      }

      return controller.isGridView.value
          ? const _GridBody()
          : const _ListBody();
    });
  }
}

// ─── Grid Body ────────────────────────────────────────────────────────────────

class _GridBody extends GetView<DocumentsController> {
  const _GridBody();

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final items = [
        ...controller.folders.map((f) => _Item.folder(f)),
        ...controller.documents.map((d) => _Item.document(d)),
      ];
      return GridView.builder(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        padding: const EdgeInsets.only(top: 8, bottom: 16),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          crossAxisSpacing: 12,
          mainAxisSpacing: 12,
          childAspectRatio: 0.95,
        ),
        itemCount: items.length,
        itemBuilder: (_, i) => items[i].isFolder
            ? FolderGridCard(folder: items[i].folder!)
            : DocumentGridCard(doc: items[i].document!),
      );
    });
  }
}

// ─── List Body ────────────────────────────────────────────────────────────────

class _ListBody extends GetView<DocumentsController> {
  const _ListBody();

  @override
  Widget build(BuildContext context) {
    return Obx(
      () => ListView(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        padding: EdgeInsets.zero,
        children: [
          if (controller.folders.isNotEmpty)
            ...controller.folders.map((f) => FolderListTile(folder: f)),
          if (controller.documents.isNotEmpty)
            ...controller.documents.map((d) => DocumentListTile(doc: d)),
        ],
      ),
    );
  }
}

// ─── Pagination Bar ───────────────────────────────────────────────────────────

class _PaginationBar extends GetView<DocumentsController> {
  const _PaginationBar();

  static const double _chipSize = 48.0;
  static const double _chipSpacing = 4.0;
  static const double _borderRadius = 10.0;

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final totalPages = controller.totalPages;
      if (totalPages <= 1) return const SizedBox.shrink();

      final current = controller.currentPage.value;
      final pages = _buildVisiblePages(current, totalPages);
      final isBusy = controller.isPageLoading.value;

      return Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        child: Center(
          child: FittedBox(
            fit: BoxFit.scaleDown,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              mainAxisSize: MainAxisSize.min,
              children: [
                // ← Prev button
                _PageNavButton(
                  icon: Icons.chevron_left_rounded,
                  enabled: current > 1 && !isBusy,
                  onTap: controller.previousPage,
                  size: _chipSize,
                  borderRadius: _borderRadius,
                ),
                const SizedBox(width: _chipSpacing),

                ...pages.map((page) {
                  if (page == 0) {
                    return SizedBox(
                      width: _chipSize + _chipSpacing,
                      height: _chipSize,
                    );
                  }
                  if (page == -1) {
                    return Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: _chipSpacing / 2,
                      ),
                      child: _EllipsisChip(
                        size: _chipSize,
                        borderRadius: _borderRadius,
                      ),
                    );
                  }
                  return Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: _chipSpacing / 2,
                    ),
                    child: _PageNumberChip(
                      page: page,
                      isActive: page == current,
                      onTap: isBusy ? null : () => controller.goToPage(page),
                      size: _chipSize,
                      borderRadius: _borderRadius,
                    ),
                  );
                }),

                const SizedBox(width: _chipSpacing),
                // → Next button
                _PageNavButton(
                  icon: Icons.chevron_right_rounded,
                  enabled: current < totalPages && !isBusy,
                  onTap: controller.nextPage,
                  size: _chipSize,
                  borderRadius: _borderRadius,
                ),
              ],
            ),
          ),
        ),
      );
    });
  }

  List<int> _buildVisiblePages(int current, int total) {
    if (total <= 4) {
      final pages = List.generate(total, (i) => i + 1);
      while (pages.length < 4) {
        pages.add(0);
      }
      return pages;
    }

    if (current <= 2) {
      return [1, 2, -1, total];
    }

    if (current >= total - 1) {
      return [1, -1, total - 1, total];
    }

    return [1, current, -1, total];
  }
}

// ─── Page Number Chip ─────────────────────────────────────────────────────────

class _PageNumberChip extends StatelessWidget {
  final int page;
  final bool isActive;
  final VoidCallback? onTap;
  final double size;
  final double borderRadius;

  const _PageNumberChip({
    required this.page,
    required this.isActive,
    required this.onTap,
    required this.size,
    required this.borderRadius,
  });

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return AnimatedContainer(
      duration: const Duration(milliseconds: 180),
      curve: Curves.easeInOut,
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: isActive ? cs.primary : Colors.transparent,
        borderRadius: BorderRadius.circular(borderRadius),
        border: isActive
            ? null
            : Border.all(color: cs.outlineVariant, width: 1.2),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(borderRadius),
          onTap: onTap,
          child: Center(
            child: Text(
              '$page',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                fontWeight: isActive ? FontWeight.w700 : FontWeight.w500,
                color: isActive ? cs.onPrimary : cs.onSurfaceVariant,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

// ─── Ellipsis Chip ────────────────────────────────────────────────────────────

class _EllipsisChip extends StatelessWidget {
  final double size;
  final double borderRadius;

  const _EllipsisChip({required this.size, required this.borderRadius});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(borderRadius),
        border: Border.all(color: cs.outlineVariant, width: 1.2),
      ),
      child: Center(
        child: Text(
          '···',
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
            color: cs.onSurfaceVariant,
            fontWeight: FontWeight.w600,
            letterSpacing: 1.5,
          ),
        ),
      ),
    );
  }
}

// ─── Page Nav Button ──────────────────────────────────────────────────────────

class _PageNavButton extends StatelessWidget {
  final IconData icon;
  final bool enabled;
  final Future<void> Function() onTap;
  final double size;
  final double borderRadius;

  const _PageNavButton({
    required this.icon,
    required this.enabled,
    required this.onTap,
    required this.size,
    required this.borderRadius,
  });

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(borderRadius),
        border: Border.all(
          color: enabled
              ? cs.outlineVariant
              : cs.outlineVariant.withValues(alpha: 0.4),
          width: 1.2,
        ),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(borderRadius),
          onTap: enabled ? () => onTap() : null,
          child: Center(
            child: Icon(
              icon,
              size: 18,
              color: enabled ? cs.primary : cs.onSurface.withValues(alpha: 0.3),
            ),
          ),
        ),
      ),
    );
  }
}

// ─── Grid Item Helper ─────────────────────────────────────────────────────────

class _Item {
  final FolderModel? folder;
  final DocumentModel? document;
  bool get isFolder => folder != null;

  _Item.folder(this.folder) : document = null;
  _Item.document(this.document) : folder = null;
}
