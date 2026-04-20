import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../../../Utils/Constant/enum.dart';
import '../Repository/activity_repository.dart';
import '../Model/activity_model.dart';
import '../../Profile/Repository/user_repository.dart';

class ActivityController extends GetxController {
  final ActivityRepository _repo = ActivityRepository();
  final UserRepository _userRepo = UserRepository();

  final RxBool isLoading = true.obs;
  final RxBool isSearching = false.obs;
  final Rx<DocumentTypeFilter> itemTypeFilter = DocumentTypeFilter.all.obs;
  final RxList<ActivityModel> activities = <ActivityModel>[].obs;
  final RxList<ActivityModel> _allActivities = <ActivityModel>[].obs;
  final TextEditingController searchController = TextEditingController();
  final RxString _searchQuery = ''.obs;

  int get allActivitiesCount => _allActivities.length;

  List<ActivityModel> get _filteredByType {
    switch (itemTypeFilter.value) {
      case DocumentTypeFilter.all:
        return _allActivities;
      case DocumentTypeFilter.folders:
        return _allActivities.where(_isFolderActivity).toList();
      case DocumentTypeFilter.pdfs:
        return _allActivities.where((a) => !_isFolderActivity(a)).toList();
    }
  }

  List<ActivityModel> get _filteredActivities {
    final query = _searchQuery.value.trim().toLowerCase();
    final source = _filteredByType;
    if (query.isEmpty) return source;

    return source.where((activity) {
      final name = (activity.documentName ?? '').toLowerCase();
      final actor = activity.actorName.toLowerCase();
      final action = activity.action.name.toLowerCase();
      return name.contains(query) ||
          actor.contains(query) ||
          action.contains(query);
    }).toList();
  }

  @override
  void onInit() {
    super.onInit();
    loadActivities();
  }

  Future<void> loadActivities() async {
    isLoading.value = true;
    try {
      final results = await _repo.getUserActivities();
      final resolvedActivities = List<ActivityModel>.from(results);

      // Resolve actor names
      for (var i = 0; i < resolvedActivities.length; i++) {
        final activity = resolvedActivities[i];
        if (activity.actorName == '' || activity.actorName == 'Unknown') {
          final name = await _userRepo.getNameById(activity.actorUid);
          if (name != null) {
            resolvedActivities[i] = ActivityModel(
              activityId: activity.activityId,
              documentId: activity.documentId,
              documentName: activity.documentName,
              actorUid: activity.actorUid,
              actorName: name,
              action: activity.action,
              timestamp: activity.timestamp,
            );
          }
        }
      }

      _allActivities.value = resolvedActivities;
      _refreshCurrentPage();
    } finally {
      isLoading.value = false;
    }
  }

  void applyItemTypeFilter(DocumentTypeFilter filter) {
    if (itemTypeFilter.value == filter) return;
    itemTypeFilter.value = filter;
    _refreshCurrentPage();
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

  void _refreshCurrentPage() {
    activities.assignAll(_filteredActivities);
  }

  bool _isFolderActivity(ActivityModel activity) {
    if (activity.action == ActivityAction.folderCreated ||
        activity.action == ActivityAction.folderDeleted) {
      return true;
    }

    final name = (activity.documentName ?? '').trim().toLowerCase();
    if (name.isEmpty) return false;
    return !name.endsWith('.pdf');
  }

  @override
  void onClose() {
    searchController.dispose();
    super.onClose();
  }
}
