import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../../../Utils/Exceptions/exceptions.dart';
import '../../../../../Utils/Firebase/firebase_utils.dart';
import '../../../../../Utils/Popups/dialog.dart';
import '../../../../../Utils/Popups/full_screen_loader.dart';
import '../../../../../Utils/Routes/main_routes.dart';
import '../../Signature/Controller/in_app_signing_controller.dart';
import '../../Signature/Model/signature_request_model.dart';
import '../../Signature/Repository/in_app_signing_repository.dart';
import '../../Signature/Repository/signature_request_repository.dart';
import '../../Profile/Repository/user_repository.dart';

class TasksController extends GetxController {
  final SignatureRequestRepository _repo = SignatureRequestRepository();
  final InAppSigningRepository _signingRepo = InAppSigningRepository();
  final UserRepository _userRepo = UserRepository();

  final RxList<SignatureRequestModel> tasks = <SignatureRequestModel>[].obs;
  final RxBool isLoading = false.obs;

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
      tasks.value = result;
      _resolveRequesterNames(); // Kick off background resolution for Unknowns
    } on AppException catch (e) {
      AppDialogs.showSnackError(e.message);
    } catch (e) {
      debugPrint('Load Tasks Error: $e');
      AppDialogs.showSnackError('Failed to load tasks. Please check your connection.');
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

  // Open in-app signing for this task
  void openTask(SignatureRequestModel request) {
    final signer = currentSigner(request);
    if (signer == null) return;
    final controller = Get.find<InAppSigningController>();
    controller.init(request, signer);
    Get.toNamed(MainRoutes.inAppSigning);
  }
 
  // Resolve requester names in background for older docs missing the field
  Future<void> _resolveRequesterNames() async {
    final unknownTasks = tasks
        .where((t) => t.requesterName == null || t.requesterName == 'Unknown')
        .toList();
    if (unknownTasks.isEmpty) return;

    for (var task in unknownTasks) {
      final name = await _userRepo.getNameById(task.requestedByUid);
      if (name != null) {
        final index = tasks.indexWhere((t) => t.requestId == task.requestId);
        if (index != -1) {
          tasks[index] = tasks[index].copyWith(requesterName: name);
        }
      }
    }
  }

  // Show task ⋮ options
  void showTaskOptions(SignatureRequestModel request) {
    AppDialogs.showOptions<String>(
      title: request.documentName,
      options: [
        const AppDialogOption(
          label: 'Sign',
          icon: Icons.draw_outlined,
          value: 'sign',
        ),
        const AppDialogOption(
          label: 'Decline',
          icon: Icons.cancel_outlined,
          value: 'decline',
          isDangerous: true,
        ),
      ],
    ).then((value) {
      if (value == 'sign') openTask(request);
      if (value == 'decline') _confirmDecline(request);
    });
  }

  // Confirm then decline directly via repository
  void _confirmDecline(SignatureRequestModel request) {
    final signer = currentSigner(request);
    if (signer == null) return;

    AppDialogs.showConfirm(
      title: 'Decline to sign?',
      message:
          'The document owner will be notified that you declined to sign ${request.documentName}.',
      confirmLabel: 'Decline',
      isDangerous: true,
      onConfirm: () => _submitDecline(request, signer),
    );
  }

  // Submit decline and reload list
  Future<void> _submitDecline(
    SignatureRequestModel request,
    SignerModel signer,
  ) async {
    AppLoader.show(message: 'Submitting...');
    try {
      await _signingRepo.submitDecline(
        requestId: request.requestId,
        signerEmail: signer.signerEmail,
        signerName: signer.signerName,
      );
      AppLoader.hide();
      AppDialogs.showSnackSuccess('You have declined to sign.');
      await loadTasks();
    } on AppException catch (e) {
      AppLoader.hide();
      AppDialogs.showSnackError(e.message);
    } catch (_) {
      AppLoader.hide();
      AppDialogs.showSnackError('Failed to submit. Please try again.');
    }
  }
}
