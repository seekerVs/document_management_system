import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../../../Commons/Widgets/empty_state.dart';
import '../../../../../Commons/Widgets/loading_shimmer.dart';
import '../../../../../Utils/Themes/component_themes.dart';
import '../Controller/documents_controller.dart';
import '../Controller/upload_controller.dart';
import '../Model/document_model.dart';
import '../Model/folder_model.dart';
import '../Widget/breadcrumb_trail.dart';
import '../Widget/document_grid_card.dart';
import '../Widget/document_list_tile.dart';
import '../Widget/multiselect_bar.dart';
import '../Widget/sort_menu.dart';
import '../../../../../../Template/Utils/Exceptions/exceptions.dart';
import '../../../../../../Template/Utils/Firebase/firebase_method.dart';
import '../../../../../../Template/Utils/Firebase/firebase_utils.dart';
import '../../../../../../Template/Utils/Helpers/helpers.dart';
import '../../../../../../Template/Utils/Popups/dialog.dart';

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
  final RxList<DocumentModel> filteredDocs = <DocumentModel>[].obs;
  final RxBool isLoading = false.obs;
  final RxBool isGridView = false.obs;
  final RxBool isSearching = false.obs;
  final TextEditingController searchController = TextEditingController();

  Worker? _sortWorker;

  @override
  void initState() {
    super.initState();
    folder = Get.arguments as FolderModel;
    _docsController = Get.find<DocumentsController>();
    _uploadController = Get.find<UploadController>();
    _sortWorker = ever(
      _docsController.sortOrder,
      (_) => _applyFilter(searchController.text),
    );
    _loadDocs();
  }

  @override
  void dispose() {
    _sortWorker?.dispose();
    searchController.dispose();
    _docsController.clearFolderDocs();
    _docsController.exitMultiSelect();
    super.dispose();
  }

  Future<void> _loadDocs() async {
    isLoading.value = true;
    try {
      final snap = await FirebaseUtils.documentsRef
          .where('ownerUid', isEqualTo: FirebaseUtils.currentUid)
          .where('folderId', isEqualTo: folder.folderId)
          .orderBy('updatedAt', descending: true)
          .get();
      docs.value = snap.docs
          .map((d) => DocumentModel.fromFirestore(d))
          .toList();
      _docsController.registerFolderDocs(docs);
      _applyFilter(searchController.text);
    } catch (_) {
      AppDialogs.showSnackError('Failed to load folder contents.');
    } finally {
      isLoading.value = false;
    }
  }

  void _applyFilter(String query) {
    var result = docs.toList();
    if (query.trim().isNotEmpty) {
      result = result
          .where(
            (d) => d.name.toLowerCase().contains(query.trim().toLowerCase()),
          )
          .toList();
    }
    result.sort(
      AppHelpers.documentComparator(_docsController.sortOrder.value)
          as int Function(DocumentModel, DocumentModel),
    );
    filteredDocs.value = result;
    // Keep controller in sync with current visible docs
    _docsController.registerFolderDocs(result);
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
        try {
          await FirebaseMethod.updateDocument(
            ref: FirebaseUtils.documentDoc(doc.documentId),
            data: {'name': name},
          );
          final i = docs.indexWhere((d) => d.documentId == doc.documentId);
          if (i != -1) docs[i] = doc.copyWith(name: name);
          _applyFilter(searchController.text);
        } catch (_) {
          AppDialogs.showSnackError('Failed to rename document.');
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
          filteredDocs.removeWhere((d) => d.documentId == doc.documentId);
          _docsController.registerFolderDocs(docs);
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
        body: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            BreadcrumbTrail(folderName: folder.name),
            if (!isMultiSelect) _buildToolbar(context),
            const SizedBox(height: 4),
            Expanded(
              child: _FolderBody(
                docs: filteredDocs,
                isLoading: isLoading,
                isGridView: isGridView,
                onRename: _renameDoc,
                onDelete: _deleteDoc,
                onRefresh: _loadDocs,
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
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
          child: Obx(
            () => TextField(
              controller: searchController,
              onChanged: _onSearchChanged,
              style: Theme.of(context).textTheme.bodyLarge,
              decoration: InputDecoration(
                hintText: 'Search in folder',
                hintStyle: TextStyle(color: cs.onSurfaceVariant.withValues(alpha: 0.7)),
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
        ),
        // Toolbar row — + New | spacer | grid/list | sort
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 4),
          child: Row(
            children: [
              MenuAnchor(
                style: AppComponentThemes.appMenuStyle,
                menuChildren: [
                  MenuItemButton(
                    leadingIcon: const Icon(Icons.upload_file_outlined),
                    onPressed: () => _uploadController.pickAndUploadToFolder(
                      folder.folderId,
                    ),
                    child: const Text('Upload file'),
                  ),
                ],
                builder: (_, menuController, _) => ElevatedButton.icon(
                  onPressed: () => menuController.isOpen
                      ? menuController.close()
                      : menuController.open(),
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
  final RxList<DocumentModel> docs;
  final RxBool isLoading;
  final RxBool isGridView;
  final void Function(DocumentModel) onRename;
  final void Function(DocumentModel) onDelete;
  final Future<void> Function() onRefresh;

  const _FolderBody({
    required this.docs,
    required this.isLoading,
    required this.isGridView,
    required this.onRename,
    required this.onDelete,
    required this.onRefresh,
  });

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      if (isLoading.value) {
        return isGridView.value
            ? LoadingShimmer.documentGrid()
            : LoadingShimmer.documentList();
      }
      if (docs.isEmpty) {
        return RefreshIndicator(
          onRefresh: onRefresh,
          child: ListView(
            children: const [
              EmptyState(
                icon: Icons.folder_open_outlined,
                message: 'This folder is empty',
                subtitle: 'Tap + New to upload a file',
              ),
            ],
          ),
        );
      }
      return RefreshIndicator(
        onRefresh: onRefresh,
        child: isGridView.value ? _buildGrid() : _buildList(),
      );
    });
  }

  Widget _buildList() {
    return ListView.builder(
      padding: EdgeInsets.zero,
      itemCount: docs.length,
      itemBuilder: (_, i) => DocumentListTile(
        doc: docs[i],
        onRenameOverride: () => onRename(docs[i]),
        onDeleteOverride: () => onDelete(docs[i]),
      ),
    );
  }

  Widget _buildGrid() {
    return GridView.builder(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
        childAspectRatio: 0.95,
      ),
      itemCount: docs.length,
      itemBuilder: (_, i) => DocumentGridCard(doc: docs[i]),
    );
  }
}
