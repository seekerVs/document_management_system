import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import '../../../../../Commons/Styles/style.dart';
import '../../../../../Commons/Widgets/app_button.dart';
import '../../../../../Commons/Widgets/app_error_box.dart';
import '../Controller/forgot_password_controller.dart';
import '../../../../../Utils/Constant/colors.dart';

class OtpVerifyView extends GetView<ForgotPasswordController> {
  const OtpVerifyView({super.key});

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
          child: Column(
            children: [
              const SizedBox(height: 16),

              const Icon(
                Icons.mark_email_read_outlined,
                size: 80,
                color: AppColors.primary,
              ),

              const SizedBox(height: 24),

              Text(
                'Enter Verification Code',
                style: Theme.of(context).textTheme.headlineMedium,
              ),

              const SizedBox(height: 8),

              Obx(
                () => Text(
                  'We sent a 6-digit code to\n${controller.verifiedEmail.value}',
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
              ),

              const SizedBox(height: 40),

              // OTP boxes
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: List.generate(
                  6,
                  (i) => _OtpBox(
                    controller: controller.otpControllers[i],
                    focusNode: controller.otpFocusNodes[i],
                    onChanged: (v) => controller.onOtpChanged(i, v),
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

              // Resend timer
              Obx(
                () => controller.resendSeconds.value > 0
                    ? Text(
                        'Resend code in ${controller.resendSeconds.value}s',
                        style: Theme.of(context).textTheme.bodyMedium,
                      )
                    : AppButton.text(
                        label: 'Resend Code',
                        onPressed: controller.resendOtp,
                      ),
              ),

              const SizedBox(height: 40),

              AppButton.primary(
                label: 'Verify Code',
                onPressed: controller.verifyOtp,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _OtpBox extends StatelessWidget {
  final TextEditingController controller;
  final FocusNode focusNode;
  final ValueChanged<String> onChanged;

  const _OtpBox({
    required this.controller,
    required this.focusNode,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 48,
      height: 56,
      child: TextField(
        controller: controller,
        focusNode: focusNode,
        textAlign: TextAlign.center,
        keyboardType: TextInputType.number,
        maxLength: 1,
        onChanged: onChanged,
        inputFormatters: [FilteringTextInputFormatter.digitsOnly],
        style: Theme.of(context).textTheme.titleMedium?.copyWith(
          color: AppColors.primary,
          fontWeight: FontWeight.bold,
        ),
        decoration: AppStyle.otpBoxDecoration(),
      ),
    );
  }
}
