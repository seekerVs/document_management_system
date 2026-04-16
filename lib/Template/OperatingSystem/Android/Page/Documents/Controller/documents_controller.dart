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
  final RxBool isLoading = false.obs;
  final RxBool isSearching = false.obs;
  final RxBool isGridView = true.obs;
  final Rx<SortOrder> sortOrder = SortOrder.dateNewest.obs;
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

  void registerFolderContents(List<DocumentModel> docs, List<FolderModel> subs) {
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

      folders.value = results[0] as List<FolderModel>;
      documents.value = results[1] as List<DocumentModel>;
      realtimeUsedStorageMB.value = (results[2] as double);
      realtimeTotalItems.value = (results[3] as int) + (results[4] as int);

      _applySortToAll();

      // Sync storage usage to Firestore if it has drifted
      await _userController.syncStorageUsage(realtimeUsedStorageMB.value);
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
    _applySortToAll();
  }

  void _applySortToAll() {
    // Sort documents
    final sortedDocs = [...documents];
    sortedDocs.sort(AppHelpers.documentComparator(sortOrder.value));
    documents.value = sortedDocs;

    // Sort folders
    final sortedFolders = [...folders];
    sortedFolders.sort(AppHelpers.documentComparator(sortOrder.value));
    folders.value = sortedFolders;
  }

  void toggleViewMode() => isGridView.toggle();
}
