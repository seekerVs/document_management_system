import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import '../../../../../Utils/Exceptions/exceptions.dart';
import '../../../../../../Template/Utils/Firebase/firebase_utils.dart';
import '../../../../../../Template/Utils/Popups/dialog.dart';
import '../../../../../../Template/Utils/Popups/full_screen_loader.dart';
import '../../../../../../Template/Utils/Routes/main_routes.dart';
import '../../../../../../Template/Utils/Services/supabase_service.dart';
import '../../../../../Commons/Widgets/app_text_field.dart';
import '../../Signature/Widget/modern_signing_modal.dart';
import '../../../../../Utils/Constant/enum.dart';
import 'dart:typed_data';
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
  final RxBool isUploadingPhoto = false.obs;

  UserModel? get user => _userController.user.value;
  String get displayName => _userController.displayName;
  String get displayEmail => _userController.displayEmail;
  String? get photoUrl => _userController.resolvedPhotoUrl.value;
  String? get signatureUrl => _userController.resolvedSignatureUrl.value;
  String? get initialsUrl => _userController.resolvedInitialsUrl.value;

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

  // Show edit name dialog
  void showEditName(BuildContext context) {
    nameController.text = displayName;
    Get.dialog(_EditNameDialog(controller: this));
  }

  // Show change password dialog
  void showChangePassword(BuildContext context) {
    currentPasswordController.clear();
    newPasswordController.clear();
    confirmPasswordController.clear();
    Get.dialog(_ChangePasswordDialog(controller: this));
  }

  // Profile Photo logic
  void showChangePhoto(BuildContext context) {
    AppDialogs.showOptions(
      title: 'Profile Photo',
      options: [
        const AppDialogOption(
          label: 'Camera',
          icon: Icons.camera_alt_outlined,
          value: 'camera',
        ),
        const AppDialogOption(
          label: 'Gallery',
          icon: Icons.photo_library_outlined,
          value: 'gallery',
        ),
        if (photoUrl != null && photoUrl!.isNotEmpty)
          const AppDialogOption(
            label: 'Remove Photo',
            icon: Icons.delete_outline,
            value: 'remove',
            isDangerous: true,
          ),
      ],
    ).then((value) {
      if (value == 'camera') {
        _pickAndUpload(ImageSource.camera);
      } else if (value == 'gallery') {
        _pickAndUpload(ImageSource.gallery);
      } else if (value == 'remove') {
        removePhoto();
      }
    });
  }

  Future<void> _pickAndUpload(ImageSource source) async {
    try {
      final picker = ImagePicker();
      final image = await picker.pickImage(
        source: source,
        maxWidth: 512,
        maxHeight: 512,
        imageQuality: 75,
      );

      if (image == null) return;

      AppLoader.show(message: 'Updating profile photo...');
      isUploadingPhoto.value = true;

      final uid = FirebaseUtils.currentUid;
      if (uid == null) throw const SessionExpiredException();

      // Upload to Supabase
      final bytes = await image.readAsBytes();
      final uploadResult = await SupabaseService.uploadBytes(
        bytes: bytes,
        storagePath: 'users/$uid/avatar',
        fileName: 'profile_photo.jpg',
      );

      // Save storage path to Firestore
      await _repo.updateProfile(uid, photoUrl: uploadResult.storagePath);

      // Increment storage
      await _userController.incrementStorage(uploadResult.fileSizeMB);

      // Refresh user to trigger UI update
      await _userController.refreshUser();

      AppDialogs.showSnackSuccess('Profile photo updated successfully.');
    } on AppException catch (e) {
      AppDialogs.showSnackError(e.message);
    } catch (e) {
      AppDialogs.showSnackError(e.toString());
    } finally {
      isUploadingPhoto.value = false;
      AppLoader.hide();
    }
  }

  Future<void> addSignature() async {
    ModernSigningModal.show(
      fieldType: SignatureFieldType.signature,
      onSave: (bytes) async {
        if (bytes != null) {
          await _uploadSignatureOrInitials(bytes, true);
        }
      },
    );
  }

  Future<void> addInitials() async {
    ModernSigningModal.show(
      fieldType: SignatureFieldType.initials,
      onSave: (bytes) async {
        if (bytes != null) {
          await _uploadSignatureOrInitials(bytes, false);
        }
      },
    );
  }

  Future<void> _uploadSignatureOrInitials(
    Uint8List bytes,
    bool isSignature,
  ) async {
    AppLoader.show(
      message: isSignature ? 'Saving signature...' : 'Saving initials...',
    );
    try {
      final uid = FirebaseUtils.currentUid;
      if (uid == null) throw const SessionExpiredException();

      final fileName = isSignature ? 'signature.png' : 'initials.png';
      final uploadResult = await SupabaseService.uploadBytes(
        bytes: bytes,
        storagePath: 'users/$uid/$fileName',
        fileName: fileName,
      );

      if (isSignature) {
        await _repo.updateProfile(uid, signatureUrl: uploadResult.storagePath);
      } else {
        await _repo.updateProfile(uid, initialsUrl: uploadResult.storagePath);
      }

      await _userController.refreshUser();
      AppDialogs.showSnackSuccess(
        isSignature ? 'Signature saved.' : 'Initials saved.',
      );
    } catch (e) {
      AppDialogs.showSnackError(
        'Failed to save ${isSignature ? 'signature' : 'initials'}.',
      );
    } finally {
      AppLoader.hide();
    }
  }

  Future<void> deleteSignature() async {
    AppDialogs.showConfirm(
      title: 'Delete Signature',
      message: 'Are you sure you want to delete your saved signature?',
      confirmLabel: 'Delete',
      isDangerous: true,
      onConfirm: () async {
        AppLoader.show(message: 'Deleting signature...');
        try {
          final uid = FirebaseUtils.currentUid;
          if (uid == null) throw const SessionExpiredException();

          await _repo.updateProfile(uid, clearSignature: true);
          if (signatureUrl != null && signatureUrl!.isNotEmpty) {
            try {
              await SupabaseService.deleteFile(signatureUrl!);
            } catch (_) {}
          }
          await _userController.refreshUser();
          AppDialogs.showSnackSuccess('Signature deleted.');
        } finally {
          AppLoader.hide();
        }
      },
    );
  }

  Future<void> deleteInitials() async {
    AppDialogs.showConfirm(
      title: 'Delete Initials',
      message: 'Are you sure you want to delete your saved initials?',
      confirmLabel: 'Delete',
      isDangerous: true,
      onConfirm: () async {
        AppLoader.show(message: 'Deleting initials...');
        try {
          final uid = FirebaseUtils.currentUid;
          if (uid == null) throw const SessionExpiredException();

          await _repo.updateProfile(uid, clearInitials: true);
          if (initialsUrl != null && initialsUrl!.isNotEmpty) {
            try {
              await SupabaseService.deleteFile(initialsUrl!);
            } catch (_) {}
          }
          await _userController.refreshUser();
          AppDialogs.showSnackSuccess('Initials deleted.');
        } finally {
          AppLoader.hide();
        }
      },
    );
  }

  Future<void> removePhoto() async {
    AppDialogs.showConfirm(
      title: 'Remove Photo',
      message: 'Are you sure you want to remove your profile photo?',
      confirmLabel: 'Remove',
      isDangerous: true,
      onConfirm: () async {
        AppLoader.show(message: 'Removing photo...');
        try {
          final uid = FirebaseUtils.currentUid;
          if (uid == null) throw const SessionExpiredException();

          // Clear photoUrl in Firestore
          final currentPhotoPath = user?.photoUrl;
          await _repo.updateProfile(uid, photoUrl: '');

          // Optionally delete from storage too
          if (currentPhotoPath != null && currentPhotoPath.isNotEmpty) {
            try {
              await SupabaseService.deleteFile(currentPhotoPath);
            } catch (_) {}
          }

          await _userController.refreshUser();
          AppDialogs.showSnackSuccess('Profile photo removed.');
        } on AppException catch (e) {
          AppDialogs.showSnackError(e.message);
        } finally {
          AppLoader.hide();
        }
      },
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
          AppLoader.hide();
          Get.offAllNamed(MainRoutes.signIn);
        } on AppException catch (e) {
          AppLoader.hide();
          AppDialogs.showSnackError(e.message);
        } catch (_) {
          AppLoader.hide();
          AppDialogs.showSnackError(
            'Please sign out and sign in again before deleting your account.',
          );
        }
      },
    );
  }
}

// Edit name dialog

class _EditNameDialog extends StatelessWidget {
  final ProfileController controller;
  const _EditNameDialog({required this.controller});

  @override
  Widget build(BuildContext context) {
    return AppDialogBase(
      title: 'Edit Name',
      content: Form(
        key: controller.nameFormKey,
        child: AppTextField(
          controller: controller.nameController,
          autofocus: true,
          hint: 'Enter your full name',
          label: 'Full name',
          prefixIcon: Icons.person_outline,
          textCapitalization: TextCapitalization.words,
          validator: (v) =>
              v == null || v.trim().isEmpty ? 'Name is required.' : null,
        ),
      ),
      actions: [
        AppDialogAction(
          label: 'Cancel',
          onPressed: () => Get.back(),
          isPrimary: false,
        ),
        Obx(
          () => AppDialogAction(
            label: 'Save',
            isLoading: controller.isSavingName.value,
            onPressed: controller.saveName,
          ),
        ),
      ],
    );
  }
}

// Change password dialog
class _ChangePasswordDialog extends StatelessWidget {
  final ProfileController controller;
  const _ChangePasswordDialog({required this.controller});

  @override
  Widget build(BuildContext context) {
    return AppDialogBase(
      title: 'Change Password',
      content: Form(
        key: controller.passwordFormKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Current password
            Obx(
              () => AppTextField(
                controller: controller.currentPasswordController,
                obscureText: controller.obscureCurrent.value,
                hint: 'Enter current password',
                label: 'Current password',
                prefixIcon: Icons.lock_outline,
                suffixIcon: IconButton(
                  icon: Icon(
                    controller.obscureCurrent.value
                        ? Icons.visibility_off_outlined
                        : Icons.visibility_outlined,
                  ),
                  onPressed: controller.obscureCurrent.toggle,
                ),
                validator: (v) => v == null || v.isEmpty
                    ? 'Current password is required.'
                    : null,
              ),
            ),
            const SizedBox(height: 16),
            // New password
            Obx(
              () => AppTextField(
                controller: controller.newPasswordController,
                obscureText: controller.obscureNew.value,
                hint: 'Enter new password',
                label: 'New password',
                prefixIcon: Icons.lock_outline,
                suffixIcon: IconButton(
                  icon: Icon(
                    controller.obscureNew.value
                        ? Icons.visibility_off_outlined
                        : Icons.visibility_outlined,
                  ),
                  onPressed: controller.obscureNew.toggle,
                ),
                validator: (v) => v == null || v.length < 6
                    ? 'Password must be at least 6 characters.'
                    : null,
              ),
            ),
            const SizedBox(height: 16),
            // Confirm password
            Obx(
              () => AppTextField(
                controller: controller.confirmPasswordController,
                obscureText: controller.obscureConfirm.value,
                textInputAction: TextInputAction.done,
                hint: 'Confirm new password',
                label: 'Confirm new password',
                prefixIcon: Icons.lock_outline,
                suffixIcon: IconButton(
                  icon: Icon(
                    controller.obscureConfirm.value
                        ? Icons.visibility_off_outlined
                        : Icons.visibility_outlined,
                  ),
                  onPressed: controller.obscureConfirm.toggle,
                ),
                validator: (v) => v != controller.newPasswordController.text
                    ? 'Passwords do not match.'
                    : null,
              ),
            ),
          ],
        ),
      ),
      actions: [
        AppDialogAction(
          label: 'Cancel',
          onPressed: () => Get.back(),
          isPrimary: false,
        ),
        Obx(
          () => AppDialogAction(
            label: 'Change Password',
            isLoading: controller.isChangingPassword.value,
            onPressed: controller.changePassword,
          ),
        ),
      ],
    );
  }
}
