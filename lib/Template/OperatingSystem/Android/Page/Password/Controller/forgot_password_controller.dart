import 'dart:async';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../../../Utils/Exceptions/exceptions.dart';
import '../../../../../../Template/Utils/Popups/dialog.dart';
import '../../../../../../Template/Utils/Popups/full_screen_loader.dart';
import '../../../../../../Template/Utils/Routes/main_routes.dart';
import '../Repository/forgot_password_repository.dart';

class ForgotPasswordController extends GetxController {
  final ForgotPasswordRepository _repo = ForgotPasswordRepository();

  final emailFormKey = GlobalKey<FormState>();
  final passwordFormKey = GlobalKey<FormState>();

  final emailController = TextEditingController();
  final otpControllers = List.generate(6, (_) => TextEditingController());
  final otpFocusNodes = List.generate(6, (_) => FocusNode());
  final newPasswordController = TextEditingController();
  final confirmPasswordController = TextEditingController();

  final RxString errorMessage = ''.obs;
  final RxString verifiedEmail = ''.obs;
  final RxString verifiedCode = ''.obs;
  final RxBool obscurePassword = true.obs;
  final RxBool obscureConfirm = true.obs;
  final RxInt resendSeconds = 0.obs;

  Timer? _resendTimer;
  bool get canResend => resendSeconds.value == 0;

  // Step 1 — Send OTP, navigate to OTP screen
  Future<void> sendOtp() async {
    if (!emailFormKey.currentState!.validate()) return;
    errorMessage.value = '';
    AppLoader.show(message: 'Sending code...');

    try {
      await _repo.sendOtp(emailController.text);
      verifiedEmail.value = emailController.text.trim().toLowerCase();
      _startResendTimer();
      Get.toNamed(MainRoutes.otpVerify);
    } on AppException catch (e) {
      errorMessage.value = e.message;
    } finally {
      AppLoader.hide();
    }
  }

  // Step 2 — Verify OTP, navigate to new password screen
  Future<void> verifyOtp() async {
    final code = otpControllers.map((c) => c.text).join();
    if (code.length < 6) {
      errorMessage.value = 'Please enter the complete 6-digit code.';
      return;
    }
    errorMessage.value = '';
    AppLoader.show(message: 'Verifying code...');

    try {
      await _repo.verifyOtp(verifiedEmail.value, code);
      verifiedCode.value = code;
      Get.toNamed(MainRoutes.newPassword);
    } on AppException catch (e) {
      errorMessage.value = e.message;
      _clearOtp();
    } finally {
      AppLoader.hide();
    }
  }

  // Step 3 — Reset password, navigate back to sign in
  Future<void> resetPassword() async {
    if (!passwordFormKey.currentState!.validate()) return;
    errorMessage.value = '';
    AppLoader.show(message: 'Resetting password...');

    try {
      await _repo.resetPassword(
        email: verifiedEmail.value,
        code: verifiedCode.value,
        newPassword: newPasswordController.text,
      );
      AppDialogs.showSnackSuccess('Password updated. Please sign in.');
      Get.offAllNamed(MainRoutes.signIn);
    } on AppException catch (e) {
      errorMessage.value = e.message;
    } finally {
      AppLoader.hide();
    }
  }

  // Resend OTP — inline loading not needed, timer gives feedback
  Future<void> resendOtp() async {
    if (!canResend) return;
    errorMessage.value = '';
    AppLoader.show(message: 'Resending code...');

    try {
      await _repo.sendOtp(verifiedEmail.value);
      _clearOtp();
      _startResendTimer();
      AppDialogs.showSnackSuccess('A new code has been sent to your email.');
    } on AppException catch (e) {
      errorMessage.value = e.message;
    } finally {
      AppLoader.hide();
    }
  }

  void onOtpChanged(int index, String value) {
    if (value.length == 1 && index < 5) {
      otpFocusNodes[index + 1].requestFocus();
    } else if (value.isEmpty && index > 0) {
      otpFocusNodes[index - 1].requestFocus();
    }
  }

  void _clearOtp() {
    for (final c in otpControllers) {
      c.clear();
    }
    otpFocusNodes[0].requestFocus();
  }

  void _startResendTimer({int seconds = 60}) {
    resendSeconds.value = seconds;
    _resendTimer?.cancel();
    _resendTimer = Timer.periodic(const Duration(seconds: 1), (t) {
      if (resendSeconds.value <= 0) {
        t.cancel();
      } else {
        resendSeconds.value--;
      }
    });
  }

  void togglePassword() => obscurePassword.toggle();
  void toggleConfirm() => obscureConfirm.toggle();

  @override
  void onClose() {
    _resendTimer?.cancel();
    super.onClose();
  }
}
