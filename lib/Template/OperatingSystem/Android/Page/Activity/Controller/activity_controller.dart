import 'package:get/get.dart';
import '../Repository/activity_repository.dart';
import '../Model/activity_model.dart';
import '../../Profile/Repository/user_repository.dart';

class ActivityController extends GetxController {
  final ActivityRepository _repo = ActivityRepository();
  final UserRepository _userRepo = UserRepository();
  
  final RxBool isLoading = true.obs;
  final RxList<ActivityModel> activities = <ActivityModel>[].obs;

  @override
  void onInit() {
    super.onInit();
    loadActivities();
  }

  Future<void> loadActivities() async {
    isLoading.value = true;
    try {
      final results = await _repo.getUserActivities();
      activities.value = results;
      
      // Resolve actor names
      for (var activity in activities) {
        if (activity.actorName == '' || activity.actorName == 'Unknown') {
          final name = await _userRepo.getNameById(activity.actorUid);
          if (name != null) {
            final index = activities.indexWhere((a) => a.activityId == activity.activityId);
            if (index != -1) {
              activities[index] = ActivityModel(
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
      }
    } finally {
      isLoading.value = false;
    }
  }
}
