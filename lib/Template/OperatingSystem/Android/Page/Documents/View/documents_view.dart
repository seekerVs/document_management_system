import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../../../Commons/Widgets/empty_state.dart';
import '../../../../../Utils/Constant/enum.dart';
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
        final typeFilter = controller.itemTypeFilter.value;
        final hasFolderResults = controller.folderSearchResults.isNotEmpty;
        final hasDocumentResults = controller.searchResults.isNotEmpty;

        if (!hasFolderResults && !hasDocumentResults) {
          return EmptyState(
            icon: Icons.search_off,
            message: _searchEmptyMessage(typeFilter),
          );
        }

        return ListView(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          padding: EdgeInsets.zero,
          children: [
            if (hasFolderResults && typeFilter == DocumentTypeFilter.all)
              const _SearchSectionLabel('Folders'),
            if (hasFolderResults)
              ...controller.folderSearchResults.map(
                (folder) => FolderListTile(folder: folder),
              ),
            if (hasFolderResults && hasDocumentResults)
              const SizedBox(height: 8),
            if (hasDocumentResults && typeFilter == DocumentTypeFilter.all)
              const _SearchSectionLabel('PDFs'),
            if (hasDocumentResults)
              ...controller.searchResults.map(
                (doc) => DocumentListTile(doc: doc),
              ),
          ],
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

// ─── Grid Item Helper ─────────────────────────────────────────────────────────

class _Item {
  final FolderModel? folder;
  final DocumentModel? document;
  bool get isFolder => folder != null;

  _Item.folder(this.folder) : document = null;
  _Item.document(this.document) : folder = null;
}

class _SearchSectionLabel extends StatelessWidget {
  final String title;
  const _SearchSectionLabel(this.title);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 8, bottom: 6),
      child: Text(
        title,
        style: Theme.of(
          context,
        ).textTheme.labelMedium?.copyWith(fontWeight: FontWeight.w600),
      ),
    );
  }
}

String _searchEmptyMessage(DocumentTypeFilter typeFilter) {
  switch (typeFilter) {
    case DocumentTypeFilter.folders:
      return 'No folders found';
    case DocumentTypeFilter.pdfs:
      return 'No PDFs found';
    case DocumentTypeFilter.all:
      return 'No documents or folders found';
  }
}
