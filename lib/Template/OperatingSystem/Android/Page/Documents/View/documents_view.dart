import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../../../Commons/Widgets/empty_state.dart';
import '../../../../../Commons/Widgets/loading_shimmer.dart';
import '../Controller/documents_controller.dart';
import '../Model/document_model.dart';
import '../Model/folder_model.dart';
import '../Widget/document_grid_card.dart';
import '../Widget/document_list_tile.dart';
import '../Widget/documents_toolbar.dart';
import '../Widget/folder_grid_card.dart';
import '../Widget/folder_list_tile.dart';
import '../Widget/multiselect_bar.dart';
import '../Widget/storage_banner.dart';

class DocumentsView extends GetView<DocumentsController> {
  const DocumentsView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      appBar: _buildAppBar(context),
      body: GestureDetector(
        onTap: () => FocusScope.of(context).unfocus(),
        behavior: HitTestBehavior.opaque,
        child: Column(
          children: [
            _SearchBar(),
            const StorageBanner(),
            const DocumentsToolbar(),
            Expanded(child: _Body()),
          ],
        ),
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
      title: const Text('My Document'),
      leading: IconButton(
        icon: const Icon(Icons.chevron_left),
        onPressed: () => Get.back(),
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

// Search bar

class _SearchBar extends GetView<DocumentsController> {
  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
      child: TextField(
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
      ),
    );
  }
}

// Body

class _Body extends GetView<DocumentsController> {
  @override
  Widget build(BuildContext context) {
    return Obx(() {
      if (controller.isLoading.value) {
        return controller.isGridView.value
            ? LoadingShimmer.documentGrid()
            : LoadingShimmer.documentList();
      }

      if (controller.isSearching.value) {
        if (controller.searchResults.isEmpty) {
          return const EmptyState(
            icon: Icons.search_off,
            message: 'No documents found',
          );
        }
        return ListView.builder(
          padding: EdgeInsets.zero,
          itemCount: controller.searchResults.length,
          itemBuilder: (_, i) =>
              DocumentListTile(doc: controller.searchResults[i]),
        );
      }

      if (controller.folders.isEmpty && controller.documents.isEmpty) {
        return RefreshIndicator(
          onRefresh: controller.loadAll,
          child: ListView(
            children: const [
              EmptyState(
                icon: Icons.folder_open_outlined,
                message: 'No documents yet',
                subtitle: 'Tap + New to upload a file or create a folder',
              ),
            ],
          ),
        );
      }

      return RefreshIndicator(
        onRefresh: controller.loadAll,
        child: controller.isGridView.value
            ? const _GridBody()
            : const _ListBody(),
      );
    });
  }
}

// Grid body
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
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
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

// List body

class _ListBody extends GetView<DocumentsController> {
  const _ListBody();

  @override
  Widget build(BuildContext context) {
    return Obx(
      () => CustomScrollView(
        slivers: [
          if (controller.folders.isNotEmpty)
            SliverList(
              delegate: SliverChildBuilderDelegate(
                (_, i) => FolderListTile(folder: controller.folders[i]),
                childCount: controller.folders.length,
              ),
            ),
          if (controller.documents.isNotEmpty)
            SliverList(
              delegate: SliverChildBuilderDelegate(
                (_, i) => DocumentListTile(doc: controller.documents[i]),
                childCount: controller.documents.length,
              ),
            ),
        ],
      ),
    );
  }
}

// Grid item helper

class _Item {
  final FolderModel? folder;
  final DocumentModel? document;
  bool get isFolder => folder != null;

  _Item.folder(this.folder) : document = null;
  _Item.document(this.document) : folder = null;
}
