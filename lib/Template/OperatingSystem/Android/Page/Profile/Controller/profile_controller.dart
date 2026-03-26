import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../../../Utils/Exceptions/exceptions.dart';
import '../../../../../../Template/Utils/Firebase/firebase_utils.dart';
import '../../../../../../Template/Utils/Popups/dialog.dart';
import '../../../../../../Template/Utils/Popups/full_screen_loader.dart';
import '../../../../../../Template/Utils/Routes/main_routes.dart';
import '../Model/user_model.dart';
import '../Repository/user_repository.dart';
import 'user_controller.dart';

class ProfileController extends GetxController {
  final UserRepository _repo = UserRepository();
  final UserController _userController = Get.find<UserController>();

  final nameFormKey = GlobalKey<FormState>();
  final passwordFormKey = GlobalKey<FormState>();
  final nameController = TextEditingController();
  final currentPasswordController = TextEditingController();
  final newPasswordController = TextEditingController();
  final confirmPasswordController = TextEditingController();

  final RxBool obscureCurrent = true.obs;
  final RxBool obscureNew = true.obs;
  final RxBool obscureConfirm = true.obs;
  final RxBool isDarkMode = false.obs;
  final RxBool isSavingName = false.obs;
  final RxBool isChangingPassword = false.obs;

  UserModel? get user => _userController.user.value;
  String get displayName => _userController.displayName;
  String get displayEmail => _userController.displayEmail;
  String? get photoUrl => user?.photoUrl;

  @override
  void onReady() {
    super.onReady();
    nameController.text = displayName;
    // Sync dark mode state with current theme
    isDarkMode.value = Get.isDarkMode;
  }

  void toggleDarkMode(bool value) {
    isDarkMode.value = value;
    Get.changeThemeMode(value ? ThemeMode.dark : ThemeMode.light);
  }

  // Show edit name bottom sheet
  void showEditName(BuildContext context) {
    nameController.text = displayName;
    Get.bottomSheet(
      _EditNameSheet(controller: this),
      isScrollControlled: true,
      ignoreSafeArea: false,
    );
  }

  // Show change password bottom sheet
  void showChangePassword(BuildContext context) {
    currentPasswordController.clear();
    newPasswordController.clear();
    confirmPasswordController.clear();
    Get.bottomSheet(
      _ChangePasswordSheet(controller: this),
      isScrollControlled: true,
      ignoreSafeArea: false,
    );
  }

  Future<void> saveName() async {
    if (!nameFormKey.currentState!.validate()) return;
    isSavingName.value = true;
    try {
      final uid = FirebaseUtils.currentUid;
      if (uid == null) throw const SessionExpiredException();
      await _repo.updateProfile(uid, name: nameController.text.trim());
      await _userController.refreshUser();
      Get.back();
      AppDialogs.showSnackSuccess('Name updated successfully.');
    } on AppException catch (e) {
      AppDialogs.showSnackError(e.message);
    } finally {
      isSavingName.value = false;
    }
  }

  Future<void> changePassword() async {
    if (!passwordFormKey.currentState!.validate()) return;
    isChangingPassword.value = true;
    try {
      final firebaseUser = FirebaseUtils.auth.currentUser;
      if (firebaseUser == null) throw const SessionExpiredException();
      final credential = await FirebaseUtils.auth.signInWithEmailAndPassword(
        email: firebaseUser.email!,
        password: currentPasswordController.text,
      );
      await credential.user!.updatePassword(newPasswordController.text);
      Get.back();
      AppDialogs.showSnackSuccess('Password changed successfully.');
    } on AppException catch (e) {
      AppDialogs.showSnackError(e.message);
    } catch (_) {
      AppDialogs.showSnackError('Current password is incorrect.');
    } finally {
      isChangingPassword.value = false;
    }
  }

  Future<void> signOut() async {
    AppDialogs.showSignOutConfirm(
      onConfirm: () async {
        try {
          await FirebaseUtils.auth.signOut();
          Get.offAllNamed(MainRoutes.signIn);
        } catch (_) {
          AppDialogs.showSnackError('Could not sign out. Please try again.');
        }
      },
    );
  }

  Future<void> deleteAccount() async {
    AppDialogs.showConfirm(
      title: 'Delete Account',
      message:
          'This will permanently delete your account and all your documents. This action cannot be undone.',
      confirmLabel: 'Delete',
      isDangerous: true,
      onConfirm: () async {
        AppLoader.show(message: 'Deleting account...');
        try {
          final uid = FirebaseUtils.currentUid;
          if (uid == null) throw const SessionExpiredException();
          await FirebaseUtils.auth.currentUser!.delete();
          Get.offAllNamed(MainRoutes.signIn);
        } on AppException catch (e) {
          AppDialogs.showSnackError(e.message);
        } catch (_) {
          AppDialogs.showSnackError(
            'Please sign out and sign in again before deleting your account.',
          );
        } finally {
          AppLoader.hide();
        }
      },
    );
  }
}

// Edit name bottom sheet

class _EditNameSheet extends StatelessWidget {
  final ProfileController controller;
  const _EditNameSheet({required this.controller});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
      ),
      child: Container(
        padding: const EdgeInsets.fromLTRB(24, 16, 24, 32),
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: Form(
          key: controller.nameFormKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Handle
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: Colors.grey[300],
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
              ),
              const SizedBox(height: 20),
              Text('Edit Name', style: Theme.of(context).textTheme.titleMedium),
              const SizedBox(height: 20),
              TextFormField(
                controller: controller.nameController,
                autofocus: true,
                textCapitalization: TextCapitalization.words,
                decoration: const InputDecoration(
                  labelText: 'Full name',
                  prefixIcon: Icon(Icons.person_outline),
                ),
                validator: (v) =>
                    v == null || v.trim().isEmpty ? 'Name is required.' : null,
              ),
              const SizedBox(height: 24),
              Obx(
                () => SizedBox(
                  width: double.infinity,
                  height: 52,
                  child: ElevatedButton(
                    onPressed: controller.isSavingName.value
                        ? null
                        : controller.saveName,
                    child: controller.isSavingName.value
                        ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: Colors.white,
                            ),
                          )
                        : const Text('Save'),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// Change password bottom sheet
class _ChangePasswordSheet extends StatelessWidget {
  final ProfileController controller;
  const _ChangePasswordSheet({required this.controller});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
      ),
      child: Container(
        padding: const EdgeInsets.fromLTRB(24, 16, 24, 32),
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: Form(
          key: controller.passwordFormKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Handle
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: Colors.grey[300],
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
              ),
              const SizedBox(height: 20),
              Text(
                'Change Password',
                style: Theme.of(context).textTheme.titleMedium,
              ),
              const SizedBox(height: 20),
              // Current password
              Obx(
                () => TextFormField(
                  controller: controller.currentPasswordController,
                  obscureText: controller.obscureCurrent.value,
                  decoration: InputDecoration(
                    labelText: 'Current password',
                    prefixIcon: const Icon(Icons.lock_outline),
                    suffixIcon: IconButton(
                      icon: Icon(
                        controller.obscureCurrent.value
                            ? Icons.visibility_off_outlined
                            : Icons.visibility_outlined,
                      ),
                      onPressed: controller.obscureCurrent.toggle,
                    ),
                  ),
                  validator: (v) => v == null || v.isEmpty
                      ? 'Current password is required.'
                      : null,
                ),
              ),
              const SizedBox(height: 12),
              // New password
              Obx(
                () => TextFormField(
                  controller: controller.newPasswordController,
                  obscureText: controller.obscureNew.value,
                  decoration: InputDecoration(
                    labelText: 'New password',
                    prefixIcon: const Icon(Icons.lock_outline),
                    suffixIcon: IconButton(
                      icon: Icon(
                        controller.obscureNew.value
                            ? Icons.visibility_off_outlined
                            : Icons.visibility_outlined,
                      ),
                      onPressed: controller.obscureNew.toggle,
                    ),
                  ),
                  validator: (v) => v == null || v.length < 6
                      ? 'Password must be at least 6 characters.'
                      : null,
                ),
              ),
              const SizedBox(height: 12),
              // Confirm password
              Obx(
                () => TextFormField(
                  controller: controller.confirmPasswordController,
                  obscureText: controller.obscureConfirm.value,
                  textInputAction: TextInputAction.done,
                  decoration: InputDecoration(
                    labelText: 'Confirm new password',
                    prefixIcon: const Icon(Icons.lock_outline),
                    suffixIcon: IconButton(
                      icon: Icon(
                        controller.obscureConfirm.value
                            ? Icons.visibility_off_outlined
                            : Icons.visibility_outlined,
                      ),
                      onPressed: controller.obscureConfirm.toggle,
                    ),
                  ),
                  validator: (v) => v != controller.newPasswordController.text
                      ? 'Passwords do not match.'
                      : null,
                ),
              ),
              const SizedBox(height: 24),
              Obx(
                () => SizedBox(
                  width: double.infinity,
                  height: 52,
                  child: ElevatedButton(
                    onPressed: controller.isChangingPassword.value
                        ? null
                        : controller.changePassword,
                    child: controller.isChangingPassword.value
                        ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: Colors.white,
                            ),
                          )
                        : const Text('Change Password'),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
