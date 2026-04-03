import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../../../Commons/Widgets/app_button.dart';
import '../../../../../Commons/Widgets/app_error_box.dart';
import '../../../../../Commons/Widgets/app_text_field.dart';
import '../Controller/sign_up_controller.dart';
import '../../../../../Utils/Constant/colors.dart';
import '../../../../../../Template/Utils/Validators/validators.dart';

class SignUpView extends GetView<SignUpController> {
  const SignUpView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.chevron_left),
          onPressed: controller.goToSignIn,
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
          child: Form(
            key: controller.formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Create account',
                  style: Theme.of(context).textTheme.headlineMedium,
                ),

                const SizedBox(height: 6),

                Text(
                  'Fill in your details to get started',
                  style: Theme.of(context).textTheme.bodyMedium,
                ),

                const SizedBox(height: 32),

                // Full name
                AppTextField(
                  label: 'Full name',
                  hint: 'Full name',
                  controller: controller.nameController,
                  prefixIcon: Icons.person_outline,
                  textCapitalization: TextCapitalization.words,
                  validator: Validators.name,
                ),

                const SizedBox(height: 16),

                // Email
                AppTextField(
                  label: 'Email',
                  hint: 'Email Address',
                  controller: controller.emailController,
                  prefixIcon: Icons.email_outlined,
                  keyboardType: TextInputType.emailAddress,
                  validator: Validators.email,
                ),

                const SizedBox(height: 16),

                // Password
                Obx(
                  () => AppTextField(
                    label: 'Password',
                    hint: 'Password',
                    controller: controller.passwordController,
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
                      onPressed: controller.togglePasswordVisibility,
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
                      controller.passwordController.text,
                    ),
                    onFieldSubmitted: (_) => controller.signUp(),
                    suffixIcon: IconButton(
                      icon: Icon(
                        controller.obscureConfirm.value
                            ? Icons.visibility_off_outlined
                            : Icons.visibility_outlined,
                        size: 20,
                        color: AppColors.textHint,
                      ),
                      onPressed: controller.toggleConfirmVisibility,
                    ),
                  ),
                ),

                const SizedBox(height: 16),

                // Error message
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

                // Create account button
                AppButton.primary(
                  label: 'Create Account',
                  onPressed: controller.signUp,
                ),

                const SizedBox(height: 24),

                // Sign in link
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      'Already have an account? ',
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                    GestureDetector(
                      onTap: controller.goToSignIn,
                      child: Text(
                        'Sign in',
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: AppColors.blue,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 24),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
