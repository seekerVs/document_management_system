import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../Profile/Model/user_model.dart';
import '../Model/document_model.dart';
import '../Model/folder_model.dart';
import '../Repository/document_repository.dart';
import '../Repository/folder_repository.dart';
import 'documents_document_mixin.dart';
import 'documents_folder_mixin.dart';
import 'documents_multiselect_mixin.dart';
import '../../../../../../Template/Utils/Constant/enum.dart';
import '../../../../../../Template/Utils/Exceptions/exceptions.dart';
import '../../../../../../Template/Utils/Helpers/helpers.dart';
import '../../../../../../Template/Utils/Popups/dialog.dart';
import '../../Profile/Controller/user_controller.dart';

class DocumentsController extends GetxController
    with
        DocumentsDocumentMixin,
        DocumentsFolderMixin,
        DocumentsMultiselectMixin {
  // Repos & services

  final DocumentRepository _docRepo = DocumentRepository();
  final FolderRepository _folderRepo = FolderRepository();
  final UserController _userController = Get.find<UserController>();

  @override
  DocumentRepository get docRepo => _docRepo;
  @override
  FolderRepository get folderRepo => _folderRepo;
  @override
  UserController get userController => _userController;

  // State

  @override
  final RxList<FolderModel> folders = <FolderModel>[].obs;
  @override
  final RxList<DocumentModel> documents = <DocumentModel>[].obs;
  @override
  final RxList<String> selectedIds = <String>[].obs;
  @override
  final RxBool isMultiSelect = false.obs;

  @override
  final RxList<DocumentModel> searchResults = <DocumentModel>[].obs;
  final RxList<FolderModel> folderSearchResults = <FolderModel>[].obs;
  final RxBool isLoading = false.obs;
  final RxBool isSearching = false.obs;
  final RxBool isGridView = true.obs;
  final Rx<SortOrder> sortOrder = SortOrder.dateNewest.obs;
  final Rx<DocumentTypeFilter> itemTypeFilter = DocumentTypeFilter.all.obs;
  final searchController = TextEditingController();

  // Picker Mode State
  final RxBool isPickerMode = false.obs;
  void Function(DocumentModel)? onPickCallback;

  void startPickerMode(void Function(DocumentModel) onPick) {
    isPickerMode.value = true;
    onPickCallback = onPick;
    exitMultiSelect(); // Ensure multiselect is off
  }

  void stopPickerMode() {
    isPickerMode.value = false;
    onPickCallback = null;
  }

  // Folder contents pool for multiselect operations inside folder view
  final RxList<DocumentModel> _folderDocs = <DocumentModel>[].obs;
  final RxList<FolderModel> _folderSubs = <FolderModel>[].obs;

  @override
  RxList<DocumentModel> get folderDocs => _folderDocs;
  @override
  RxList<FolderModel> get folderSubs => _folderSubs;

  void registerFolderContents(
    List<DocumentModel> docs,
    List<FolderModel> subs,
  ) {
    _folderDocs.value = docs;
    _folderSubs.value = subs;
  }

  void clearFolderContents() {
    _folderDocs.clear();
    _folderSubs.clear();
  }

  // Storage computed (Real-time synced)
  final RxDouble realtimeUsedStorageMB = 0.0.obs;
  final RxInt realtimeTotalItems = 0.obs;

  double get usedStorageMB => realtimeUsedStorageMB.value;
  double get freeStorageMB => UserModel.maxStorageMB - usedStorageMB;
  double get freeStorageGB => freeStorageMB / 1024;
  double get storagePercent => usedStorageMB / UserModel.maxStorageMB;
  int get totalItems => realtimeTotalItems.value;

  // Full sorted list of all items (folders + documents combined)
  final RxList<FolderModel> _allFolders = <FolderModel>[].obs;
  final RxList<DocumentModel> _allDocuments = <DocumentModel>[].obs;

  int get folderCount => _allFolders.length;
  int get pdfCount => _allDocuments.length;
  int get allItemCount => folderCount + pdfCount;

  late final void Function(String) _debouncedSearch;

  // Lifecycle

  @override
  void onInit() {
    super.onInit();
    _debouncedSearch = AppHelpers.debounce(
      _searchByType,
      const Duration(milliseconds: 500),
    );
  }

  @override
  void onReady() {
    super.onReady();
    loadAll();
  }

  // Load

  @override
  Future<void> loadAll() async {
    isLoading.value = true;
    try {
      final results = await Future.wait([
        _folderRepo.getFolders(),
        _docRepo.getRootDocuments(),
        _docRepo.getTotalStorageMB(),
        _docRepo.getDocumentCount(),
        _folderRepo.getFolderCount(),
      ]);

      _allFolders.value = results[0] as List<FolderModel>;
      _allDocuments.value = results[1] as List<DocumentModel>;
      realtimeUsedStorageMB.value = (results[2] as double);
      realtimeTotalItems.value = (results[3] as int) + (results[4] as int);

      _applySortToAll();
      _refreshVisibleItems();

      await _userController.syncStorageUsage(realtimeUsedStorageMB.value);
    } on AppException catch (e) {
      AppDialogs.showSnackError(e.message);
    } finally {
      isLoading.value = false;
    }
  }

  void _refreshVisibleItems() {
    switch (itemTypeFilter.value) {
      case DocumentTypeFilter.all:
        folders.assignAll(_allFolders);
        documents.assignAll(_allDocuments);
        break;
      case DocumentTypeFilter.folders:
        folders.assignAll(_allFolders);
        documents.clear();
        break;
      case DocumentTypeFilter.pdfs:
        folders.clear();
        documents.assignAll(_allDocuments);
        break;
    }
  }

  // Search

  void onSearchChanged(String query) {
    if (query.trim().isEmpty) {
      isSearching.value = false;
      searchResults.clear();
      folderSearchResults.clear();
      return;
    }
    isSearching.value = true;
    _debouncedSearch(query.trim());
  }

  Future<void> _searchByType(String query) async {
    searchResults.clear();
    folderSearchResults.clear();

    try {
      switch (itemTypeFilter.value) {
        case DocumentTypeFilter.folders:
          final normalizedQuery = query.toLowerCase();
          folderSearchResults.value = _allFolders
              .where(
                (folder) => folder.name.toLowerCase().contains(normalizedQuery),
              )
              .toList();
          break;
        case DocumentTypeFilter.pdfs:
          searchResults.value = await _docRepo.searchDocuments(query);
          break;
        case DocumentTypeFilter.all:
          final normalizedQuery = query.toLowerCase();
          final folders = _allFolders
              .where(
                (folder) => folder.name.toLowerCase().contains(normalizedQuery),
              )
              .toList();
          final docs = await _docRepo.searchDocuments(query);

          folderSearchResults.value = folders;
          searchResults.value = docs;
          break;
      }
    } on AppException catch (e) {
      AppDialogs.showSnackError(e.message);
    }
  }

  void clearSearch() {
    searchController.clear();
    isSearching.value = false;
    searchResults.clear();
    folderSearchResults.clear();
  }

  // Sort

  void applySortOrder(SortOrder order) {
    sortOrder.value = order;
    _applySortToAll();
    _refreshVisibleItems();
  }

  void applyItemTypeFilter(DocumentTypeFilter filter) {
    if (itemTypeFilter.value == filter) return;
    itemTypeFilter.value = filter;
    _refreshVisibleItems();

    final query = searchController.text.trim();
    if (isSearching.value && query.isNotEmpty) {
      _searchByType(query);
    }
  }

  void _applySortToAll() {
    final sortedDocs = [..._allDocuments];
    sortedDocs.sort(AppHelpers.documentComparator(sortOrder.value));
    _allDocuments.value = sortedDocs;

    final sortedFolders = [..._allFolders];
    sortedFolders.sort(AppHelpers.documentComparator(sortOrder.value));
    _allFolders.value = sortedFolders;
  }

  void toggleViewMode() => isGridView.toggle();

  @override
  void onClose() {
    searchController.dispose();
    super.onClose();
  }
}
