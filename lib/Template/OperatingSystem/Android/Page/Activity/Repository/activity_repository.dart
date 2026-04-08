import '../../../../../../Template/Utils/Firebase/firebase_method.dart';
import '../../../../../../Template/Utils/Firebase/firebase_utils.dart';
import '../../../../../Utils/Firebase/base_repository.dart';
import '../../../../../Utils/Constant/enum.dart';
import '../Model/activity_model.dart';
import '../../Profile/Controller/user_controller.dart';
import 'package:get/get.dart';

class ActivityRepository extends BaseRepository {
  static final ActivityRepository _instance = ActivityRepository._();
  factory ActivityRepository() => _instance;
  ActivityRepository._();

  Future<void> logActivity({
    required String documentId,
    String? documentName,
    required ActivityAction action,
  }) async {
    final uid = currentUidOrNull;
    if (uid == null) return;

    String actorName = 'Unknown';
    try {
      if (Get.isRegistered<UserController>()) {
        actorName = Get.find<UserController>().displayName;
      }
    } catch (_) {}

    final docRef = FirebaseUtils.activitiesRef.doc();
    final activity = ActivityModel(
      activityId: docRef.id,
      documentId: documentId,
      documentName: documentName,
      actorUid: uid,
      actorName: actorName,
      action: action,
      timestamp: DateTime.now(),
    );

    // Using addDocument directly to the ref or setDocument on the docRef
    await FirebaseMethod.setDocument(ref: docRef, data: activity.toFirestore());
  }
}
