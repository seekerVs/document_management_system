import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'dart:math' as math;
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
  final RxBool isLoading = false.obs;
  final RxBool isPageLoading = false.obs;
  final RxBool isSearching = false.obs;
  final RxBool isGridView = true.obs;
  final Rx<SortOrder> sortOrder = SortOrder.dateNewest.obs;
  final RxInt currentPage = 1.obs;
  final searchController = TextEditingController();

  static const int pageSize = 10;

  // Folder docs pool for multiselect operations inside folder view
  final RxList<DocumentModel> _folderDocs = <DocumentModel>[].obs;
  @override
  RxList<DocumentModel> get folderDocs => _folderDocs;

  void registerFolderDocs(List<DocumentModel> docs) => _folderDocs.value = docs;
  void clearFolderDocs() => _folderDocs.clear();

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

  // Total combined item count
  int get _totalItemCount => _allFolders.length + _allDocuments.length;

  int get totalPages => math.max(1, (_totalItemCount / pageSize).ceil());

  // Paged folders for current page
  List<FolderModel> get pagedFolders {
    final start = (currentPage.value - 1) * pageSize;
    final end = math.min(start + pageSize, _allFolders.length);
    if (start >= _allFolders.length) return [];
    return _allFolders.sublist(start, end);
  }

  // Paged documents for current page (after folders fill their slots)
  List<DocumentModel> get pagedDocuments {
    final start = (currentPage.value - 1) * pageSize;
    final foldersOnPage = pagedFolders.length;
    final docsStart = math.max(0, start - _allFolders.length);
    final slotsLeft = pageSize - foldersOnPage;
    if (slotsLeft <= 0 || docsStart >= _allDocuments.length) return [];
    final docsEnd = math.min(docsStart + slotsLeft, _allDocuments.length);
    return _allDocuments.sublist(docsStart, docsEnd);
  }

  late final void Function(String) _debouncedSearch;

  // Lifecycle

  @override
  void onInit() {
    super.onInit();
    _debouncedSearch = AppHelpers.debounce(
      _searchDocuments,
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
      currentPage.value = 1;
      _refreshCurrentPage();

      await _userController.syncStorageUsage(realtimeUsedStorageMB.value);
    } on AppException catch (e) {
      AppDialogs.showSnackError(e.message);
    } finally {
      isLoading.value = false;
    }
  }

  // Pagination

  void goToPage(int page) {
    final clamped = page.clamp(1, totalPages);
    if (currentPage.value == clamped) return;
    isPageLoading.value = true;
    currentPage.value = clamped;
    _refreshCurrentPage();
    isPageLoading.value = false;
  }

  Future<void> nextPage() async => goToPage(currentPage.value + 1);

  Future<void> previousPage() async => goToPage(currentPage.value - 1);

  void _refreshCurrentPage() {
    folders.value = pagedFolders;
    documents.value = pagedDocuments;
  }

  // Search

  void onSearchChanged(String query) {
    if (query.trim().isEmpty) {
      isSearching.value = false;
      searchResults.clear();
      return;
    }
    isSearching.value = true;
    _debouncedSearch(query.trim());
  }

  Future<void> _searchDocuments(String query) async {
    try {
      final results = await _docRepo.searchDocuments(query);
      searchResults.value = results;
    } on AppException catch (e) {
      AppDialogs.showSnackError(e.message);
    }
  }

  void clearSearch() {
    searchController.clear();
    isSearching.value = false;
    searchResults.clear();
  }

  // Sort

  void applySortOrder(SortOrder order) {
    sortOrder.value = order;
    _applySortToAll();
    currentPage.value = 1;
    _refreshCurrentPage();
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
