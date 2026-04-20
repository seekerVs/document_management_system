import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../../../Utils/Constant/enum.dart';
import '../../../../../Utils/Exceptions/exceptions.dart';
import '../../../../../Utils/Firebase/firebase_utils.dart';
import '../../../../../Utils/Popups/dialog.dart';
import '../../../../../Utils/Routes/main_routes.dart';
import '../../Signature/Model/signature_request_model.dart';
import '../../Signature/Repository/signature_request_repository.dart';
import '../../Signature/Controller/in_app_signing_controller.dart';
import '../../Profile/Repository/user_repository.dart';

class TasksController extends GetxController {
  final SignatureRequestRepository _repo = SignatureRequestRepository();
  final UserRepository _userRepo = UserRepository();

  final RxList<SignatureRequestModel> tasks = <SignatureRequestModel>[].obs;
  final RxBool isLoading = false.obs;
  final RxBool isSearching = false.obs;
  final Rx<SortOrder> sortOrder = SortOrder.dateNewest.obs;
  final Rx<DocumentTypeFilter> itemTypeFilter = DocumentTypeFilter.all.obs;
  final RxList<SignatureRequestModel> _allTasks = <SignatureRequestModel>[].obs;
  final TextEditingController searchController = TextEditingController();
  final RxString _searchQuery = ''.obs;

  int get allTasksCount => _allTasks.length;

  List<SignatureRequestModel> get _filteredAndSortedTasks {
    final query = _searchQuery.value.trim().toLowerCase();

    final filteredByType = _allTasks.where((task) {
      switch (itemTypeFilter.value) {
        case DocumentTypeFilter.all:
          return true;
        case DocumentTypeFilter.folders:
          return !_isPdfTask(task);
        case DocumentTypeFilter.pdfs:
          return _isPdfTask(task);
      }
    }).toList();

    final filtered = query.isEmpty
        ? filteredByType
        : filteredByType.where((task) {
            final docName = task.documentName.toLowerCase();
            final requester = (task.requesterName ?? 'unknown').toLowerCase();
            return docName.contains(query) || requester.contains(query);
          }).toList();

    filtered.sort((a, b) {
      switch (sortOrder.value) {
        case SortOrder.nameAsc:
          return a.documentName.toLowerCase().compareTo(
            b.documentName.toLowerCase(),
          );
        case SortOrder.nameDesc:
          return b.documentName.toLowerCase().compareTo(
            a.documentName.toLowerCase(),
          );
        case SortOrder.dateOldest:
          return a.createdAt.compareTo(b.createdAt);
        case SortOrder.dateNewest:
        default:
          return b.createdAt.compareTo(a.createdAt);
      }
    });

    return filtered;
  }

  @override
  void onReady() {
    super.onReady();
    loadTasks();
  }

  // Fetch assigned signing requests for current user
  Future<void> loadTasks() async {
    if (FirebaseUtils.currentUid == null) return;
    isLoading.value = true;
    try {
      final result = await _repo.getAssignedRequests();
      _allTasks.value = result;
      _refreshCurrentPage();
      _resolveRequesterNames(); // Kick off background resolution for Unknowns
    } on AppException catch (e) {
      AppDialogs.showSnackError(e.message);
    } catch (e) {
      debugPrint('Load Tasks Error: $e');
      AppDialogs.showSnackError(
        'Failed to load tasks. Please check your connection.',
      );
    } finally {
      isLoading.value = false;
    }
  }

  // Get the signer entry for current user in a request
  SignerModel? currentSigner(SignatureRequestModel request) {
    final email = FirebaseUtils.currentEmail;
    if (email == null) return null;
    return request.signers.where((s) => s.signerEmail == email).firstOrNull;
  }

  // Open task details/audit trail
  void viewTaskDetails(SignatureRequestModel request) {
    Get.toNamed(MainRoutes.taskDetails, arguments: request);
  }

  // Open in-app signing for this task
  void signDocument(SignatureRequestModel request) {
    final signer = currentSigner(request);
    if (signer == null) return;

    final signingController = Get.find<InAppSigningController>();
    signingController.init(request, signer);
    Get.toNamed(MainRoutes.inAppSigning);
  }

  // Resolve requester names in background for older docs missing the field
  Future<void> _resolveRequesterNames() async {
    final unknownTasks = _allTasks
        .where((t) => t.requesterName == null || t.requesterName == 'Unknown')
        .toList();
    if (unknownTasks.isEmpty) return;

    for (final task in unknownTasks) {
      final name = await _userRepo.getNameById(task.requestedByUid);
      if (name != null) {
        final index = _allTasks.indexWhere(
          (t) => t.requestId == task.requestId,
        );
        if (index != -1) {
          _allTasks[index] = _allTasks[index].copyWith(requesterName: name);
          _refreshCurrentPage();
        }
      }
    }
  }

  void onSearchChanged(String query) {
    final trimmed = query.trim();
    _searchQuery.value = trimmed;
    isSearching.value = trimmed.isNotEmpty;
    _refreshCurrentPage();
  }

  void clearSearch() {
    searchController.clear();
    _searchQuery.value = '';
    isSearching.value = false;
    _refreshCurrentPage();
  }

  void applySortOrder(SortOrder order) {
    if (sortOrder.value == order) return;
    sortOrder.value = order;
    _refreshCurrentPage();
  }

  void applyItemTypeFilter(DocumentTypeFilter filter) {
    if (itemTypeFilter.value == filter) return;
    itemTypeFilter.value = filter;
    _refreshCurrentPage();
  }

  void _refreshCurrentPage() {
    tasks.assignAll(_filteredAndSortedTasks);
  }

  bool _isPdfTask(SignatureRequestModel task) {
    return task.documentName.toLowerCase().endsWith('.pdf');
  }

  @override
  void onClose() {
    searchController.dispose();
    super.onClose();
  }
}
