import 'dart:async';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../../../Commons/Styles/style.dart';
import '../../../../../Commons/Widgets/document_details_sheet.dart';
import '../../../../../Utils/Firebase/firebase_utils.dart';
import '../../../../../Utils/Popups/dialog.dart';
import '../../../../../Utils/Routes/main_routes.dart';
import '../../Activity/Model/activity_model.dart';
import '../../Documents/Model/document_model.dart';
import '../../Profile/Controller/user_controller.dart';
import '../../Signature/Model/signature_request_model.dart';
import '../../Profile/Repository/user_repository.dart';
import '../Repository/dashboard_repository.dart';

class DashboardController extends GetxController {
  final DashboardRepository _repo = DashboardRepository();
  final UserRepository _userRepo = UserRepository();
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
  String? get photoUrl => _userController.resolvedPhotoUrl.value;

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
      // Fetch each section safely so one failing index doesn't crash the whole dashboard
      final docsFuture = _repo.getRecentDocuments().catchError((e) {
        debugPrint('Docs Error: $e');
        return <DocumentModel>[];
      });
      final tasksFuture = _repo.getAssignedTasks().catchError((e) {
        debugPrint('Tasks Error: $e');
        return <SignatureRequestModel>[];
      });
      final actFuture = _repo.getRecentActivity().catchError((e) {
        debugPrint('Activity Error: $e');
        return <ActivityModel>[];
      });

      final results = await Future.wait([docsFuture, tasksFuture, actFuture]);
      
      recentDocuments.value = results[0] as List<DocumentModel>;
      assignedTasks.value = results[1] as List<SignatureRequestModel>;
      recentActivity.value = results[2] as List<ActivityModel>;

      _resolveNames(); // Background fetching for real names
    } catch (e) {
      debugPrint('Dashboard Load Error: $e');
      AppDialogs.showSnackError('Failed to load dashboard.');
    } finally {
      isLoading.value = false;
    }
  }

  // Resolve Names in background
  Future<void> _resolveNames() async {
    // 1. Resolve Task Requester names
    for (var task in assignedTasks) {
      if (task.requesterName == null || task.requesterName == 'Unknown') {
        final name = await _userRepo.getNameById(task.requestedByUid);
        if (name != null) {
          final index = assignedTasks.indexWhere((t) => t.requestId == task.requestId);
          if (index != -1) assignedTasks[index] = assignedTasks[index].copyWith(requesterName: name);
        }
      }
    }

    // 2. Resolve Activity Actor names
    for (var activity in recentActivity) {
      if (activity.actorName == '' || activity.actorName == 'Unknown') {
        final name = await _userRepo.getNameById(activity.actorUid);
        if (name != null) {
          final index = recentActivity.indexWhere((a) => a.activityId == activity.activityId);
          if (index != -1) {
             recentActivity[index] = ActivityModel(
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
  }

  // Stream pending task count for app bar badge
  void _listenToTaskCount() {
    final email = FirebaseUtils.currentEmail;
    if (email == null) return;
    _taskCountSub?.cancel();
    _taskCountSub = FirebaseUtils.signatureRequestsRef
        .where('signerEmails', arrayContains: email.toLowerCase())
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
    final cs = Theme.of(context).colorScheme;
    return Container(
      padding: const EdgeInsets.fromLTRB(24, 12, 24, 32),
      decoration: AppStyle.bottomSheetDecoration(context),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Center(
            child: Container(
              width: 40,
              height: 4,
              decoration: AppStyle.bottomSheetHandleOf(context),
            ),
          ),
          const SizedBox(height: 8),
          ListTile(
            contentPadding: EdgeInsets.zero,
            leading: Icon(
              Icons.open_in_new_outlined,
              color: cs.onSurface,
            ),
            title: Text(
              'Open in Documents',
              style: Theme.of(context).textTheme.titleSmall,
            ),
            onTap: onOpen,
          ),
          ListTile(
            contentPadding: EdgeInsets.zero,
            leading: Icon(
              Icons.info_outline,
              color: cs.onSurface,
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
