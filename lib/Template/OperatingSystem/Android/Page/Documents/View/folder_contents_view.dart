import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../../../Commons/Widgets/empty_state.dart';
import '../Controller/documents_controller.dart';
import '../Controller/upload_controller.dart';
import '../Model/document_model.dart';
import '../Model/folder_model.dart';
import '../Model/breadcrumb_segment.dart';
import '../Widget/breadcrumb_trail.dart';
import '../Widget/document_grid_card.dart';
import '../Widget/document_list_tile.dart';
import '../Widget/documents_shimmer.dart';
import '../Widget/folder_grid_card.dart';
import '../Widget/folder_list_tile.dart';
import '../Widget/multiselect_bar.dart';
import '../Widget/sort_menu.dart';
import '../../../../../../Template/Utils/Exceptions/exceptions.dart';
import '../../../../../../Template/Utils/Firebase/firebase_method.dart';
import '../../../../../../Template/Utils/Firebase/firebase_utils.dart';
import '../../../../../../Template/Utils/Helpers/helpers.dart';
import '../../../../../../Template/Utils/Popups/dialog.dart';
import '../../../../../../Template/Utils/Popups/full_screen_loader.dart';

class FolderContentsView extends StatefulWidget {
  const FolderContentsView({super.key});

  @override
  State<FolderContentsView> createState() => _FolderContentsViewState();
}

class _FolderContentsViewState extends State<FolderContentsView> {
  late final FolderModel folder;
  late final DocumentsController _docsController;
  late final UploadController _uploadController;

  final RxList<DocumentModel> docs = <DocumentModel>[].obs;
  final RxList<FolderModel> subFolders = <FolderModel>[].obs;
  final RxList<dynamic> filteredItems = <dynamic>[].obs;
  final RxBool isLoading = false.obs;
  final RxBool isGridView = false.obs;
  final RxBool isSearching = false.obs;
  final TextEditingController searchController = TextEditingController();
  late final List<BreadcrumbSegment> trail;

  Worker? _sortWorker;

  final GlobalKey<PopupMenuButtonState<String>> _menuKey = GlobalKey();

  @override
  void initState() {
    super.initState();
    final args = Get.arguments;
    if (args is FolderModel) {
      folder = args;
      trail = [
        BreadcrumbSegment(name: 'My Documents'),
        BreadcrumbSegment(name: folder.name, folderId: folder.folderId),
      ];
    } else if (args is Map) {
      folder = args['folder'] as FolderModel;
      trail =
          (args['trail'] as List<dynamic>?)?.cast<BreadcrumbSegment>() ??
          [
            BreadcrumbSegment(name: 'My Documents'),
            BreadcrumbSegment(name: folder.name, folderId: folder.folderId),
          ];
    } else {
      // Fallback
      folder = args as FolderModel;
      trail = [
        BreadcrumbSegment(name: 'My Documents'),
        BreadcrumbSegment(name: folder.name, folderId: folder.folderId),
      ];
    }

    _docsController = Get.find<DocumentsController>();
    _uploadController = Get.find<UploadController>();
    _sortWorker = ever(
      _docsController.sortOrder,
      (_) => _applyFilter(searchController.text),
    );
    _loadContents();
  }

  @override
  void dispose() {
    _sortWorker?.dispose();
    searchController.dispose();
    _docsController.clearFolderContents();
    _docsController.exitMultiSelect();
    super.dispose();
  }

  Future<void> _loadContents() async {
    isLoading.value = true;
    try {
      final results = await Future.wait([
        FirebaseUtils.documentsRef
            .where('ownerUid', isEqualTo: FirebaseUtils.currentUid)
            .where('folderId', isEqualTo: folder.folderId)
            .orderBy('updatedAt', descending: true)
            .get(),
        _docsController.folderRepo.getSubFolders(folder.folderId),
      ]);

      final docSnap = results[0] as QuerySnapshot;
      docs.value = docSnap.docs
          .map((d) => DocumentModel.fromFirestore(d))
          .toList();

      subFolders.value = results[1] as List<FolderModel>;

      _syncWithController();
      _applyFilter(searchController.text);
    } catch (_) {
      AppDialogs.showSnackError('Failed to load folder contents.');
    } finally {
      isLoading.value = false;
    }
  }

  void _applyFilter(String query) {
    final q = query.trim().toLowerCase();

    final filteredDocs = docs
        .where((d) => d.name.toLowerCase().contains(q))
        .toList();
    final filteredSubs = subFolders
        .where((f) => f.name.toLowerCase().contains(q))
        .toList();

    filteredDocs.sort(
      AppHelpers.documentComparator(_docsController.sortOrder.value)
          as int Function(DocumentModel, DocumentModel),
    );
    filteredSubs.sort(
      AppHelpers.documentComparator(_docsController.sortOrder.value)
          as int Function(FolderModel, FolderModel),
    );

    filteredItems.value = [...filteredSubs, ...filteredDocs];
  }

  void _syncWithController() {
    _docsController.registerFolderContents(docs, subFolders);
  }

  void _onSearchChanged(String query) {
    isSearching.value = query.trim().isNotEmpty;
    _applyFilter(query);
  }

  void _clearSearch() {
    searchController.clear();
    isSearching.value = false;
    _applyFilter('');
  }

  void _renameDoc(DocumentModel doc) {
    AppDialogs.showInput(
      title: 'Rename Document',
      hint: 'Document name',
      initialValue: doc.name,
      confirmLabel: 'Rename',
      onConfirm: (name) async {
        final trimmedName = name.trim();
        if (trimmedName.isEmpty) return;
        if (trimmedName.toLowerCase() == doc.name.toLowerCase()) return;

        if (AppHelpers.nameExists(
          trimmedName,
          _docsController.folderDocs.map((d) => d.name),
        )) {
          AppDialogs.showSnackError('A file with this name already exists.');
          return;
        }

        try {
          AppLoader.show(message: 'Renaming Document...');
          await FirebaseMethod.updateDocument(
            ref: FirebaseUtils.documentDoc(doc.documentId),
            data: {'name': trimmedName},
          );
          final i = docs.indexWhere((d) => d.documentId == doc.documentId);
          if (i != -1) {
            docs[i] = doc.copyWith(name: trimmedName);
            docs.refresh();
          }
          _syncWithController();
          _applyFilter(searchController.text);
          AppDialogs.showSnackSuccess('Document renamed.');
        } catch (_) {
          AppDialogs.showSnackError('Failed to rename document.');
        } finally {
          AppLoader.hide();
        }
      },
    );
  }

  void _deleteDoc(DocumentModel doc) {
    AppDialogs.showDeleteConfirm(
      itemName: doc.name,
      onConfirm: () async {
        try {
          await FirebaseMethod.deleteDocument(
            ref: FirebaseUtils.documentDoc(doc.documentId),
          );
          docs.removeWhere((d) => d.documentId == doc.documentId);
          filteredItems.removeWhere(
            (item) =>
                item is DocumentModel && item.documentId == doc.documentId,
          );
          _syncWithController();
          await FirebaseUtils.folderDoc(
            folder.folderId,
          ).update({'itemCount': docs.length});
          AppDialogs.showSnackSuccess('Document deleted.');
        } on AppException catch (e) {
          AppDialogs.showSnackError(e.message);
        }
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final isMultiSelect = _docsController.isMultiSelect.value;
      return Scaffold(
        appBar: AppBar(
          title: Text(folder.name),
          leading: IconButton(
            icon: const Icon(Icons.chevron_left),
            onPressed: () => Get.back(),
          ),
          actions: [
            if (isMultiSelect)
              TextButton(
                onPressed: _docsController.exitMultiSelect,
                style: TextButton.styleFrom(
                  padding: const EdgeInsets.only(right: 16),
                ),
                child: const Text('Cancel'),
              ),
          ],
        ),
        bottomNavigationBar: isMultiSelect ? const MultiSelectBar() : null,
        body: Stack(
          children: [
            Positioned.fill(
              child: RefreshIndicator(
                onRefresh: _loadContents,
                child: SingleChildScrollView(
                  physics: isLoading.value
                      ? const NeverScrollableScrollPhysics()
                      : const AlwaysScrollableScrollPhysics(),
                  padding: const EdgeInsets.fromLTRB(20, 16, 20, 16),
                  child: Center(
                    child: ConstrainedBox(
                      constraints: const BoxConstraints(maxWidth: 800),
                      child: isLoading.value
                          ? const DocumentsShimmer(showStorageBanner: false)
                          : Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                BreadcrumbTrail(segments: trail),
                                const SizedBox(height: 12),
                                if (!isMultiSelect) _buildToolbar(context),
                                const SizedBox(height: 12),
                                _FolderBody(
                                  items: filteredItems,
                                  isGridView: isGridView,
                                  folder: folder,
                                  controller: _docsController,
                                  trail: trail,
                                  onRenameDoc: _renameDoc,
                                  onDeleteDoc: _deleteDoc,
                                ),
                              ],
                            ),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      );
    });
  }

  Widget _buildToolbar(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Column(
      children: [
        // Search field — full width, same as documents_view
        Obx(
          () => TextField(
            controller: searchController,
            onChanged: _onSearchChanged,
            style: Theme.of(context).textTheme.bodyLarge,
            decoration: InputDecoration(
              hintText: 'Search in folder',
              hintStyle: TextStyle(
                color: cs.onSurfaceVariant.withValues(alpha: 0.7),
              ),
              prefixIcon: Icon(
                Icons.search,
                color: cs.onSurfaceVariant,
                size: 20,
              ),
              suffixIcon: isSearching.value
                  ? IconButton(
                      icon: Icon(
                        Icons.close,
                        size: 18,
                        color: cs.onSurfaceVariant,
                      ),
                      onPressed: _clearSearch,
                    )
                  : null,
            ),
          ),
        ),
        // Toolbar row — + New | spacer | grid/list | sort
        Padding(
          padding: const EdgeInsets.only(top: 12, bottom: 4),
          child: Row(
            children: [
              PopupMenuButton<String>(
                key: _menuKey,
                position: PopupMenuPosition.under,
                onSelected: (value) {
                  if (value == 'upload') {
                    _uploadController.showUploadSourceSheet(
                      folderId: folder.folderId,
                    );
                  } else if (value == 'folder') {
                    _docsController.showCreateFolderDialog(
                      parentId: folder.folderId,
                    );
                  }
                },
                itemBuilder: (_) => [
                  PopupMenuItem(
                    value: 'upload',
                    child: Row(
                      children: [
                        Icon(
                          Icons.upload_file_outlined,
                          size: 20,
                          color: cs.onSurface,
                        ),
                        const SizedBox(width: 12),
                        Text(
                          'Upload file',
                          style: Theme.of(context).textTheme.bodyMedium,
                        ),
                      ],
                    ),
                  ),
                  if (folder.parentId == null)
                    PopupMenuItem(
                      value: 'folder',
                      child: Row(
                        children: [
                          Icon(
                            Icons.folder_open_outlined,
                            size: 20,
                            color: cs.onSurface,
                          ),
                          const SizedBox(width: 12),
                          Text(
                            'New folder',
                            style: Theme.of(context).textTheme.bodyMedium,
                          ),
                        ],
                      ),
                    ),
                ],
                child: ElevatedButton.icon(
                  onPressed: () => _menuKey.currentState?.showButtonMenu(),
                  icon: const Icon(Icons.add, size: 18),
                  label: const Text('New'),
                  style: ElevatedButton.styleFrom(
                    minimumSize: Size.zero,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 10,
                    ),
                  ),
                ),
              ),
              const Spacer(),
              Obx(
                () => IconButton(
                  icon: Icon(
                    isGridView.value
                        ? Icons.format_list_bulleted
                        : Icons.grid_view_rounded,
                    color: cs.onSurfaceVariant,
                  ),
                  onPressed: () => isGridView.toggle(),
                ),
              ),
              const SortMenu(),
            ],
          ),
        ),
      ],
    );
  }
}

// Folder body

class _FolderBody extends StatelessWidget {
  final RxList<dynamic> items;
  final RxBool isGridView;
  final FolderModel folder;
  final DocumentsController controller;
  final List<BreadcrumbSegment> trail;
  final void Function(DocumentModel) onRenameDoc;
  final void Function(DocumentModel) onDeleteDoc;

  const _FolderBody({
    required this.items,
    required this.isGridView,
    required this.folder,
    required this.controller,
    required this.trail,
    required this.onRenameDoc,
    required this.onDeleteDoc,
  });

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      if (items.isEmpty) {
        return const EmptyState(
          icon: Icons.folder_open_outlined,
          message: 'This folder is empty',
          subtitle: 'Tap + New to upload a file',
        );
      }
      return isGridView.value ? _buildGrid() : _buildList();
    });
  }

  Widget _buildList() {
    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      padding: EdgeInsets.zero,
      itemCount: items.length,
      itemBuilder: (_, i) {
        final item = items[i];
        if (item is FolderModel) {
          return FolderListTile(
            folder: item,
            onTapOverride: () => controller.goToFolder(item, trail: trail),
          );
        }
        final doc = item as DocumentModel;
        return DocumentListTile(
          doc: doc,
          onRenameOverride: () => onRenameDoc(doc),
          onDeleteOverride: () => onDeleteDoc(doc),
        );
      },
    );
  }

  Widget _buildGrid() {
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
      itemBuilder: (_, i) {
        final item = items[i];
        if (item is FolderModel) {
          return FolderGridCard(
            folder: item,
            onTapOverride: () => controller.goToFolder(item, trail: trail),
          );
        }
        return DocumentGridCard(doc: item as DocumentModel);
      },
    );
  }
}
