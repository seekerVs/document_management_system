import 'dart:async';
import 'package:get/get.dart';
import '../../../../../../../../Template/Utils/Exceptions/exceptions.dart';
import '../../../../../../../../Template/Utils/Routes/main_routes.dart';
import '../../../../../../../../Template/Utils/Services/user_controller.dart';
import '../../Activity/Model/activity_model.dart';
import '../../Documents/Model/document_model.dart';
import '../../Signature/Model/signature_request_model.dart';
import '../Repository/dashboard_repository.dart';

// 📁 lib/Template/OperatingSystem/Android/Page/Welcome/Controller/dashboard_controller.dart

class DashboardController extends GetxController {
  final DashboardRepository _repo = DashboardRepository();
  final UserController _userController = Get.find<UserController>();

  // ─── State ───────────────────────────────────────────────────────────────

  final RxBool isLoading = false.obs;
  final RxString errorMessage = ''.obs;

  final RxList<DocumentModel> recentDocuments = <DocumentModel>[].obs;
  final RxList<SignatureRequestModel> assignedTasks =
      <SignatureRequestModel>[].obs;
  final RxList<ActivityModel> recentActivity = <ActivityModel>[].obs;
  final RxInt unreadCount = 0.obs;

  StreamSubscription? _notificationSub;

  // ─── Getters ─────────────────────────────────────────────────────────────

  String get displayName => _userController.displayName;
  String get displayEmail => _userController.displayEmail;

  // ─── Lifecycle ───────────────────────────────────────────────────────────

  @override
  void onReady() {
    super.onReady();
    loadDashboard();
    _listenToNotifications();
  }

  @override
  void onClose() {
    _notificationSub?.cancel();
    super.onClose();
  }

  // ─── Data loading ────────────────────────────────────────────────────────

  Future<void> loadDashboard() async {
    isLoading.value = true;
    errorMessage.value = '';

    try {
      final results = await Future.wait([
        _repo.getRecentDocuments(),
        _repo.getAssignedTasks(),
        _repo.getRecentActivity(),
      ]);

      recentDocuments.value = results[0] as List<DocumentModel>;
      assignedTasks.value = results[1] as List<SignatureRequestModel>;
      recentActivity.value = results[2] as List<ActivityModel>;
    } on AppException catch (e) {
      errorMessage.value = e.message;
    } finally {
      isLoading.value = false;
    }
  }

  void _listenToNotifications() {
    _notificationSub = _repo.unreadNotificationCount().listen((count) {
      unreadCount.value = count;
    });
  }

  // ─── Navigation ──────────────────────────────────────────────────────────

  void goToDocuments() => Get.toNamed(MainRoutes.documents);
  void goToNotifications() => Get.toNamed(MainRoutes.notifications);
  void goToProfile() => Get.toNamed(MainRoutes.profile);
  void goToSignature() => Get.toNamed(MainRoutes.signature);
  void goToActivity() => Get.toNamed(MainRoutes.activity);

  Future<void> signOut() async {
    Get.find<UserController>();
    Get.offAllNamed(MainRoutes.signIn);
  }
}
