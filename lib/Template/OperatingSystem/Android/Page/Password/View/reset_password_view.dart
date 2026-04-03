import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../../../Commons/Widgets/app_button.dart';
import '../../../../../Commons/Widgets/app_error_box.dart';
import '../../../../../Commons/Widgets/app_text_field.dart';
import '../Controller/forgot_password_controller.dart';
import '../../../../../Utils/Constant/colors.dart';
import '../../../../../../Template/Utils/Validators/validators.dart';

class NewPasswordView extends GetView<ForgotPasswordController> {
  const NewPasswordView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.chevron_left),
          onPressed: () => Get.back(),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Form(
            key: controller.passwordFormKey,
            child: Column(
              children: [
                const SizedBox(height: 16),

                const Icon(
                  Icons.lock_open_outlined,
                  size: 80,
                  color: AppColors.blue,
                ),

                const SizedBox(height: 24),

                Text(
                  'Set New Password',
                  style: Theme.of(context).textTheme.headlineMedium,
                ),

                const SizedBox(height: 8),

                Text(
                  'Your new password must be\nat least 6 characters.',
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.bodyMedium,
                ),

                const SizedBox(height: 40),

                // New password
                Obx(
                  () => AppTextField(
                    label: 'New Password',
                    hint: 'New Password',
                    controller: controller.newPasswordController,
                    prefixIcon: Icons.lock_outline,
                    obscureText: controller.obscurePassword.value,
                    validator: Validators.password,
                    suffixIcon: IconButton(
                      icon: Icon(
                        controller.obscurePassword.value
                            ? Icons.visibility_off_outlined
                            : Icons.visibility_outlined,
                        size: 20,
                        color: AppColors.textHint,
                      ),
                      onPressed: controller.togglePassword,
                    ),
                  ),
                ),

                const SizedBox(height: 16),

                // Confirm password
                Obx(
                  () => AppTextField(
                    label: 'Confirm Password',
                    hint: 'Confirm Password',
                    controller: controller.confirmPasswordController,
                    prefixIcon: Icons.lock_outline,
                    obscureText: controller.obscureConfirm.value,
                    textInputAction: TextInputAction.done,
                    validator: (v) => Validators.confirmPassword(
                      v,
                      controller.newPasswordController.text,
                    ),
                    onFieldSubmitted: (_) => controller.resetPassword(),
                    suffixIcon: IconButton(
                      icon: Icon(
                        controller.obscureConfirm.value
                            ? Icons.visibility_off_outlined
                            : Icons.visibility_outlined,
                        size: 20,
                        color: AppColors.textHint,
                      ),
                      onPressed: controller.toggleConfirm,
                    ),
                  ),
                ),

                const SizedBox(height: 16),

                Obx(
                  () => controller.errorMessage.value.isNotEmpty
                      ? Padding(
                          padding: const EdgeInsets.only(bottom: 12),
                          child: AppErrorBox(
                            message: controller.errorMessage.value,
                          ),
                        )
                      : const SizedBox.shrink(),
                ),

                const SizedBox(height: 8),

                AppButton.primary(
                  label: 'Reset Password',
                  onPressed: controller.resetPassword,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
