import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import '../../../../../Commons/Widgets/app_button.dart';
import '../../../../../Commons/Widgets/app_error_box.dart';
import '../../../../../Commons/Widgets/app_text_field.dart';
import '../../../../../Commons/Widgets/or_divider.dart';
import '../../../../../Utils/Constant/colors.dart';
import '../../../../../Utils/Constant/images.dart';
import '../Controller/sign_in_controller.dart';
import '../../../../../../Template/Utils/Validators/validators.dart';

class SignInView extends GetView<SignInController> {
  const SignInView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Form(
            key: controller.formKey,
            child: Column(
              children: [
                const SizedBox(height: 40),

                // Logo
                SvgPicture.asset(
                  AppImages.logo,
                  width: 80,
                  height: 80,
                  colorFilter: ColorFilter.mode(
                    Theme.of(context).colorScheme.primary,
                    BlendMode.srcIn,
                  ),
                ),

                const SizedBox(height: 20),

                // Title — "Welcome to Scrivener"
                RichText(
                  text: TextSpan(
                    text: 'Welcome to ',
                    style: Theme.of(context).textTheme.headlineMedium,
                    children: [
                      TextSpan(
                        text: 'Scrivener',
                        style: Theme.of(context).textTheme.headlineMedium
                            ?.copyWith(color: AppColors.primary),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 6),

                Text(
                  'Please login in to continue',
                  style: Theme.of(context).textTheme.bodyMedium,
                ),

                const SizedBox(height: 32),

                // Email field
                AppTextField(
                  label: 'Email',
                  hint: 'Email Address',
                  controller: controller.emailController,
                  prefixIcon: Icons.email_outlined,
                  keyboardType: TextInputType.emailAddress,
                  validator: Validators.email,
                ),

                const SizedBox(height: 16),

                // Password field
                Obx(
                  () => AppTextField(
                    label: 'Password',
                    hint: 'Password',
                    controller: controller.passwordController,
                    prefixIcon: Icons.lock_outline,
                    obscureText: controller.obscurePassword.value,
                    textInputAction: TextInputAction.done,
                    validator: Validators.password,
                    onFieldSubmitted: (_) => controller.signIn(),
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

                // Forgot password — centered
                Center(
                  child: AppButton.text(
                    label: 'Forgot Password?',
                    onPressed: controller.goToForgotPassword,
                  ),
                ),

                const SizedBox(height: 32),

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

                // Log in button
                AppButton.primary(
                  label: 'Log In',
                  onPressed: controller.signIn,
                ),

                const SizedBox(height: 24),

                // Or divider
                const OrDivider(),

                const SizedBox(height: 24),

                // Google button
                AppButton.outlined(
                  label: 'Continue with Google',
                  onPressed: controller.signInWithGoogle,
                  icon: Image.asset(
                    AppImages.googleLogo,
                    width: 20,
                    height: 20,
                  ),
                ),

                const SizedBox(height: 32),

                // Sign up link
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      "Don't have an account? ",
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                    GestureDetector(
                      onTap: controller.goToSignUp,
                      child: Text(
                        'Sign up',
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: AppColors.primary,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 30),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
