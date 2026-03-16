import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../../../Utils/Exceptions/exceptions.dart';
import '../../../../../Utils/Routes/main_routes.dart';
import '../../../../../Utils/Services/user_controller.dart';
import '../Repository/auth_repository.dart';

// 📁 lib/Template/OperatingSystem/Android/Page/SignIn/Controller/sign_in_controller.dart

class SignInController extends GetxController {
  final AuthRepository _repo = AuthRepository();

  // ─── Form ────────────────────────────────────────────────────────────────

  final formKey = GlobalKey<FormState>();
  final emailController = TextEditingController();
  final passwordController = TextEditingController();

  // ─── State ───────────────────────────────────────────────────────────────

  final RxBool isLoading = false.obs;
  final RxBool obscurePassword = true.obs;
  final RxString errorMessage = ''.obs;

  // ─── Actions ─────────────────────────────────────────────────────────────

  Future<void> signIn() async {
    if (!formKey.currentState!.validate()) return;
    errorMessage.value = '';
    isLoading.value = true;

    try {
      final user = await _repo.signInWithEmail(
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

  Future<void> sendPasswordReset() async {
    final email = emailController.text.trim();
    if (email.isEmpty) {
      errorMessage.value = 'Enter your email address first.';
      return;
    }

    isLoading.value = true;
    try {
      await _repo.sendPasswordReset(email: email);
      Get.snackbar(
        'Email sent',
        'Check your inbox for password reset instructions.',
        snackPosition: SnackPosition.BOTTOM,
      );
    } on AppException catch (e) {
      errorMessage.value = e.message;
    } finally {
      isLoading.value = false;
    }
  }

  void togglePasswordVisibility() => obscurePassword.toggle();

  void goToSignUp() => Get.toNamed(MainRoutes.signUp);

  @override
  void onClose() {
    emailController.dispose();
    passwordController.dispose();
    super.onClose();
  }
}
