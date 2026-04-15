import 'dart:math' as math;
import 'package:get/get.dart';
import '../Repository/activity_repository.dart';
import '../Model/activity_model.dart';
import '../../Profile/Repository/user_repository.dart';

class ActivityController extends GetxController {
  final ActivityRepository _repo = ActivityRepository();
  final UserRepository _userRepo = UserRepository();
  
  final RxBool isLoading = true.obs;
  final RxBool isPageLoading = false.obs;
  final RxInt currentPage = 1.obs;
  final RxList<ActivityModel> activities = <ActivityModel>[].obs;
  final RxList<ActivityModel> _allActivities = <ActivityModel>[].obs;

  static const int pageSize = 10;
  int get totalPages => math.max(1, (_allActivities.length / pageSize).ceil());

  List<ActivityModel> get pagedActivities {
    final start = (currentPage.value - 1) * pageSize;
    if (start >= _allActivities.length) return [];
    final end = math.min(start + pageSize, _allActivities.length);
    return _allActivities.sublist(start, end);
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
      currentPage.value = 1;
      _refreshCurrentPage();
    } finally {
      isLoading.value = false;
    }
  }

  void goToPage(int page) {
    final clamped = page.clamp(1, totalPages).toInt();
    if (currentPage.value == clamped) return;
    isPageLoading.value = true;
    currentPage.value = clamped;
    _refreshCurrentPage();
    isPageLoading.value = false;
  }

  Future<void> nextPage() async => goToPage(currentPage.value + 1);

  Future<void> previousPage() async => goToPage(currentPage.value - 1);

  void _refreshCurrentPage() {
    activities.value = pagedActivities;
  }
}
