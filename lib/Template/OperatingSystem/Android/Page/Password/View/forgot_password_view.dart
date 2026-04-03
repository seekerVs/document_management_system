import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../../../Commons/Widgets/app_button.dart';
import '../../../../../Commons/Widgets/app_error_box.dart';
import '../../../../../Commons/Widgets/app_text_field.dart';
import '../Controller/forgot_password_controller.dart';
import '../../../../../Utils/Constant/colors.dart';
import '../../../../../../Template/Utils/Validators/validators.dart';

class ForgotEmailView extends GetView<ForgotPasswordController> {
  const ForgotEmailView({super.key});

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
            key: controller.emailFormKey,
            child: Column(
              children: [
                const SizedBox(height: 16),

                const Icon(
                  Icons.lock_reset,
                  size: 80,
                  color: AppColors.blue,
                ),

                const SizedBox(height: 24),

                Text(
                  'Forgot Password',
                  style: Theme.of(context).textTheme.headlineMedium,
                ),

                const SizedBox(height: 8),

                Text(
                  'Enter your registered email address\nand we\'ll send you a verification code.',
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.bodyMedium,
                ),

                const SizedBox(height: 40),

                AppTextField(
                  label: 'Email',
                  hint: 'Email Address',
                  controller: controller.emailController,
                  prefixIcon: Icons.email_outlined,
                  keyboardType: TextInputType.emailAddress,
                  textInputAction: TextInputAction.done,
                  validator: Validators.email,
                  onFieldSubmitted: (_) => controller.sendOtp(),
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
                  label: 'Send Verification Code',
                  onPressed: controller.sendOtp,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
