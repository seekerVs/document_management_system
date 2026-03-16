import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../../../Utils/Exceptions/exceptions.dart';
import '../../../../../Utils/Routes/main_routes.dart';
import '../../../../../Utils/Services/user_controller.dart';
import '../Repository/auth_repository.dart';

// 📁 lib/Template/OperatingSystem/Android/Page/SignIn/Controller/sign_up_controller.dart

class SignUpController extends GetxController {
  final AuthRepository _repo = AuthRepository();

  // ─── Form ────────────────────────────────────────────────────────────────

  final formKey = GlobalKey<FormState>();
  final nameController = TextEditingController();
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  final confirmPasswordController = TextEditingController();

  // ─── State ───────────────────────────────────────────────────────────────

  final RxBool isLoading = false.obs;
  final RxBool obscurePassword = true.obs;
  final RxBool obscureConfirm = true.obs;
  final RxString errorMessage = ''.obs;

  // ─── Actions ─────────────────────────────────────────────────────────────

  Future<void> signUp() async {
    if (!formKey.currentState!.validate()) return;
    errorMessage.value = '';
    isLoading.value = true;

    try {
      final user = await _repo.signUpWithEmail(
        name: nameController.text,
        email: emailController.text,
        password: passwordController.text,
      );

      if (user != null) {
        await Get.find<UserController>().refreshUser();
        Get.offAllNamed(MainRoutes.home);
      }
    } on AppException catch (e) {
      errorMessage.value = e.message;
    } finally {
      isLoading.value = false;
    }
  }

  void togglePasswordVisibility() => obscurePassword.toggle();
  void toggleConfirmVisibility() => obscureConfirm.toggle();
  void goToSignIn() => Get.back();

  @override
  void onClose() {
    nameController.dispose();
    emailController.dispose();
    passwordController.dispose();
    confirmPasswordController.dispose();
    super.onClose();
  }
}
