import 'dart:async';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../../../Commons/Styles/style.dart';
import '../../../../../Commons/Widgets/document_details_sheet.dart';
import '../../../../../Utils/Constant/colors.dart';
import '../../../../../Utils/Exceptions/exceptions.dart';
import '../../../../../Utils/Firebase/firebase_utils.dart';
import '../../../../../Utils/Popups/dialog.dart';
import '../../../../../Utils/Routes/main_routes.dart';
import '../../Activity/Model/activity_model.dart';
import '../../Documents/Model/document_model.dart';
import '../../Profile/Controller/user_controller.dart';
import '../../Signature/Model/signature_request_model.dart';
import '../Repository/dashboard_repository.dart';

class DashboardController extends GetxController {
  final DashboardRepository _repo = DashboardRepository();
  final UserController _userController = Get.find<UserController>();

  final RxBool isLoading = false.obs;
  final RxBool isFabExpanded = false.obs;
  final RxList<DocumentModel> recentDocuments = <DocumentModel>[].obs;
  final RxList<SignatureRequestModel> assignedTasks =
      <SignatureRequestModel>[].obs;
  final RxList<ActivityModel> recentActivity = <ActivityModel>[].obs;
  // Pending task count for badge
  final RxInt pendingTaskCount = 0.obs;

  StreamSubscription? _taskCountSub;

  String get displayName => _userController.displayName;
  String get displayEmail => _userController.displayEmail;

  void toggleFab() => isFabExpanded.toggle();

  @override
  void onReady() {
    super.onReady();
    _waitForUserThenLoad();
  }

  @override
  void onClose() {
    _taskCountSub?.cancel();
    super.onClose();
  }

  // Wait for auth before loading
  void _waitForUserThenLoad() {
    if (FirebaseUtils.currentUid != null) {
      loadDashboard();
      _listenToTaskCount();
      return;
    }
    StreamSubscription? sub;
    sub = FirebaseUtils.auth.authStateChanges().listen((user) {
      if (user != null) {
        loadDashboard();
        _listenToTaskCount();
        sub?.cancel();
      }
    });
  }

  Future<void> loadDashboard() async {
    if (FirebaseUtils.currentUid == null) return;
    isLoading.value = true;
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
      AppDialogs.showSnackError(e.message);
    } catch (_) {
      AppDialogs.showSnackError('Failed to load dashboard.');
    } finally {
      isLoading.value = false;
    }
  }

  // Stream pending task count for app bar badge
  void _listenToTaskCount() {
    final email = FirebaseUtils.currentEmail;
    if (email == null) return;
    _taskCountSub?.cancel();
    _taskCountSub = FirebaseUtils.signatureRequestsRef
        .where('status', whereIn: ['pending', 'inProgress'])
        .snapshots()
        .listen((snap) {
          pendingTaskCount.value = snap.docs.where((doc) {
            final data = doc.data() as Map<String, dynamic>;
            final signers = List<Map<String, dynamic>>.from(
              data['signers'] ?? [],
            );
            return signers.any(
              (s) =>
                  s['signerEmail'] == email &&
                  s['role'] == 'needsToSign' &&
                  s['status'] == 'pending',
            );
          }).length;
        }, onError: (_) => pendingTaskCount.value = 0);
  }

  // Open document in viewer
  void openDocument(DocumentModel doc) =>
      Get.toNamed(MainRoutes.documentViewer, arguments: doc);

  // Show document options sheet
  void showDocumentOptions(DocumentModel doc) {
    Get.bottomSheet(
      _DocumentOptionsSheet(
        onOpen: () {
          Get.back();
          openDocument(doc);
        },
        onDetails: () {
          Get.back();
          Get.bottomSheet(
            DocumentDetailsSheet(doc: doc),
            isScrollControlled: true,
          );
        },
      ),
      isScrollControlled: true,
    );
  }

  void goToDocuments() => Get.toNamed(MainRoutes.documents);
  void goToTasks() => Get.toNamed(MainRoutes.tasks);
  void goToProfile() => Get.toNamed(MainRoutes.profile);
  void goToSignature() => Get.toNamed(MainRoutes.signature);
  void goToActivity() => Get.toNamed(MainRoutes.activity);

  Future<void> signOut() async {
    try {
      _taskCountSub?.cancel();
      await FirebaseUtils.auth.signOut();
      Get.offAllNamed(MainRoutes.signIn);
    } catch (_) {
      AppDialogs.showSnackError('Could not sign out. Please try again.');
    }
  }
}

class _DocumentOptionsSheet extends StatelessWidget {
  final VoidCallback onOpen;
  final VoidCallback onDetails;
  const _DocumentOptionsSheet({required this.onOpen, required this.onDetails});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(24, 12, 24, 32),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Center(
            child: Container(
              width: 40,
              height: 4,
              decoration: AppStyle.bottomSheetHandle,
            ),
          ),
          const SizedBox(height: 8),
          ListTile(
            leading: const Icon(
              Icons.open_in_new_outlined,
              color: AppColors.textPrimary,
            ),
            title: Text(
              'Open in Documents',
              style: Theme.of(context).textTheme.titleSmall,
            ),
            onTap: onOpen,
          ),
          ListTile(
            leading: const Icon(
              Icons.info_outline,
              color: AppColors.textPrimary,
            ),
            title: Text(
              'Details',
              style: Theme.of(context).textTheme.titleSmall,
            ),
            onTap: onDetails,
          ),
        ],
      ),
    );
  }
}
