import 'package:flutter/material.dart';
import 'package:get/get.dart';
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

  final RxList<DocumentModel> searchResults = <DocumentModel>[].obs;
  final RxBool isLoading = false.obs;
  final RxBool isSearching = false.obs;
  final RxBool isGridView = true.obs;
  final Rx<SortOrder> sortOrder = SortOrder.nameAsc.obs;
  final searchController = TextEditingController();

  // Folder docs pool for multiselect operations inside folder view
  final RxList<DocumentModel> _folderDocs = <DocumentModel>[].obs;
  @override
  RxList<DocumentModel> get folderDocs => _folderDocs;

  void registerFolderDocs(List<DocumentModel> docs) => _folderDocs.value = docs;
  void clearFolderDocs() => _folderDocs.clear();

  // Storage computed
  double get usedStorageMB => _userController.user.value?.usedStorageMB ?? 0;
  double get freeStorageMB => _userController.user.value?.freeStorageMB ?? 0;
  double get freeStorageGB => freeStorageMB / 1024;
  double get storagePercent =>
      _userController.user.value?.storageUsagePercent ?? 0;
  int get totalItems => folders.length + documents.length;

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
      ]);
      folders.value = results[0] as List<FolderModel>;
      documents.value = results[1] as List<DocumentModel>;
      _applySortToDocuments();
    } on AppException catch (e) {
      AppDialogs.showSnackError(e.message);
    } finally {
      isLoading.value = false;
    }
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
    _applySortToDocuments();
  }

  void _applySortToDocuments() {
    final sorted = [...documents];
    sorted.sort(AppHelpers.documentComparator(sortOrder.value));
    documents.value = sorted;
  }

  void toggleViewMode() => isGridView.toggle();
}
