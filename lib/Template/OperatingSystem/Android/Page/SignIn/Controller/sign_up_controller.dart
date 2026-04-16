import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../../../Utils/Exceptions/exceptions.dart';
import '../../../../../../Template/Utils/Routes/main_routes.dart';
import '../../../../../../Template/Utils/Popups/full_screen_loader.dart';
import '../../Profile/Controller/user_controller.dart';
import '../../Documents/Repository/folder_repository.dart';
import '../Repository/auth_repository.dart';

class SignUpController extends GetxController {
  final AuthRepository _repo = AuthRepository();

  final formKey = GlobalKey<FormState>();
  final nameController = TextEditingController();
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  final confirmPasswordController = TextEditingController();

  final RxBool obscurePassword = true.obs;
  final RxBool obscureConfirm = true.obs;
  final RxString errorMessage = ''.obs;

  Future<void> signUp() async {
    if (!formKey.currentState!.validate()) return;
    errorMessage.value = '';
    AppLoader.show(message: 'Creating account...');

    try {
      final user = await _repo.signUpWithEmail(
        name: nameController.text.trim(),
        email: emailController.text.trim(),
        password: passwordController.text,
      );
      if (user != null) {
        await FolderRepository().initializeDefaultFolders(user.uid);
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
      errorMessage.value = 'Account creation failed. Please try again.';
    }
  }

  void togglePasswordVisibility() => obscurePassword.toggle();
  void toggleConfirmVisibility() => obscureConfirm.toggle();
  void goToSignIn() => Get.back();
}
