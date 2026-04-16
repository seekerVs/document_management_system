import 'package:get/get.dart';
import '../../../../../Utils/Firebase/firebase_utils.dart';
import '../../Activity/Model/activity_model.dart';
import '../../Activity/Repository/activity_repository.dart';
import '../../Signature/Model/signature_request_model.dart';
import '../../Signature/Controller/in_app_signing_controller.dart';
import '../../../../../Utils/Routes/main_routes.dart';

class TaskDetailsController extends GetxController {
  final ActivityRepository _activityRepo = ActivityRepository();

  // The task passed via arguments
  late final SignatureRequestModel task;

  // Activities for the timeline
  final RxList<ActivityModel> activities = <ActivityModel>[].obs;
  final RxBool isLoadingActivities = false.obs;

  @override
  void onInit() {
    super.onInit();
    // Get task from arguments
    if (Get.arguments is SignatureRequestModel) {
      task = Get.arguments as SignatureRequestModel;
      loadActivities();
    }
  }

  Future<void> loadActivities() async {
    isLoadingActivities.value = true;
    try {
      final result = await _activityRepo.getActivitiesByDocumentId(
        task.documentId,
      );
      activities.value = result;
    } finally {
      isLoadingActivities.value = false;
    }
  }

  // Get the signer entry for current user in a request
  SignerModel? get currentSigner {
    final email = FirebaseUtils.currentEmail;
    if (email == null) return null;
    return task.signers.where((s) => s.signerEmail == email).firstOrNull;
  }

  void startSigning() {
    final controller = Get.find<InAppSigningController>();
    controller.init(task, currentSigner!);
    Get.toNamed(MainRoutes.inAppSigning);
  }

  void openDocument() {
    Get.toNamed(
      MainRoutes.requestDocuments,
      arguments: {'task': task},
    );
  }
}
