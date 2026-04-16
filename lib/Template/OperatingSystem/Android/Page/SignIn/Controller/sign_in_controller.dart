import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../../../Utils/Exceptions/exceptions.dart';
import '../../../../../../Template/Utils/Routes/main_routes.dart';
import '../../../../../../Template/Utils/Popups/full_screen_loader.dart';
import '../../../../../../Template/Utils/Popups/dialog.dart';
import '../../Profile/Controller/user_controller.dart';
import '../Repository/auth_repository.dart';

class SignInController extends GetxController {
  final AuthRepository _repo = AuthRepository();

  final formKey = GlobalKey<FormState>();
  final emailController = TextEditingController();
  final passwordController = TextEditingController();

  final RxBool obscurePassword = true.obs;
  final RxString errorMessage = ''.obs;

  Future<void> signIn() async {
    if (!formKey.currentState!.validate()) return;
    errorMessage.value = '';
    AppLoader.show(message: 'Signing in...');

    try {
      final user = await _repo.signInWithEmail(
        email: emailController.text.trim(),
        password: passwordController.text,
      );
      if (user != null) {
        await Get.find<UserController>().refreshUser();
        AppLoader.hide();
        Get.offAllNamed(MainRoutes.dashboard);
      } else {
        AppLoader.hide();
      }
    } on AppException catch (e) {
      AppLoader.hide();
      errorMessage.value = e.message;
    } catch (e) {
      AppLoader.hide();
      errorMessage.value = 'Sign in failed. Please check your credentials.';
    }
  }

  Future<void> signInWithGoogle() async {
    errorMessage.value = '';
    AppLoader.show(message: 'Signing in with Google...');

    try {
      final user = await _repo.signInWithGoogle();
      if (user != null) {
        await Get.find<UserController>().refreshUser();
        AppLoader.hide();
        Get.offAllNamed(MainRoutes.dashboard);
      } else {
        AppLoader.hide();
      }
    } on AppException catch (e) {
      AppLoader.hide();
      AppDialogs.showSnackError(e.message);
    } catch (e) {
      AppLoader.hide();
      AppDialogs.showSnackError('Google sign in failed.');
    }
  }

  void goToForgotPassword() => Get.toNamed(MainRoutes.forgotPassword);
  void togglePasswordVisibility() => obscurePassword.toggle();
  void goToSignUp() => Get.toNamed(MainRoutes.signUp);
}
