import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../../../Commons/Widgets/app_text_field.dart';
import '../../../../../Utils/Constant/colors.dart';
import '../../../../../Utils/Constant/enum.dart';
import '../Controller/signature_request_controller.dart';

class AddRecipientView extends GetView<SignatureRequestController> {
  const AddRecipientView({super.key});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      child: Scaffold(
        resizeToAvoidBottomInset: false,
        appBar: AppBar(
          title: const Text('Recipient Role'),
          leading: IconButton(
            icon: const Icon(Icons.close),
            onPressed: Get.back,
          ),
          actions: [
            TextButton(
              onPressed: controller.saveRecipient,
              style: TextButton.styleFrom(
                padding: const EdgeInsets.only(right: 16),
              ),
              child: const Text('Save'),
            ),
          ],
        ),
        body: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Role', style: Theme.of(context).textTheme.titleMedium),
              const SizedBox(height: 12),
              _RolePicker(controller: controller),
              const SizedBox(height: 24),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Recipient',
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  TextButton(
                    onPressed: controller.assignToMe,
                    child: const Text('Assign to me'),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              AppTextField(
                hint: 'Recipient name',
                label: 'Recipient name',
                controller: controller.nameController,
                textCapitalization: TextCapitalization.words,
              ),
              const SizedBox(height: 12),
              AppTextField(
                hint: 'Recipient email',
                label: 'Recipient email',
                controller: controller.emailController,
                keyboardType: TextInputType.emailAddress,
                textInputAction: TextInputAction.done,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _RolePicker extends StatelessWidget {
  final SignatureRequestController controller;
  const _RolePicker({required this.controller});

  @override
  Widget build(BuildContext context) {
    return Obx(
      () => Column(
        children: [
          _RoleOption(
            title: 'Needs to sign',
            subtitle: "For anyone who isn't with you",
            value: SignerRole.needsToSign,
            selected: controller.selectedRole.value,
            onTap: () => controller.selectedRole.value = SignerRole.needsToSign,
          ),
          const SizedBox(height: 8),
          _RoleOption(
            title: 'Receives a copy',
            subtitle: 'For anyone who needs a signed copy',
            value: SignerRole.receivesACopy,
            selected: controller.selectedRole.value,
            onTap: () =>
                controller.selectedRole.value = SignerRole.receivesACopy,
          ),
        ],
      ),
    );
  }
}

class _RoleOption extends StatelessWidget {
  final String title;
  final String subtitle;
  final SignerRole value;
  final SignerRole selected;
  final VoidCallback onTap;

  const _RoleOption({
    required this.title,
    required this.subtitle,
    required this.value,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final isSelected = value == selected;
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected ? AppColors.blue : AppColors.grey,
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Row(
          children: [
            Icon(
              isSelected
                  ? Icons.radio_button_checked
                  : Icons.radio_button_unchecked,
              color: isSelected ? AppColors.blue : AppColors.textHint,
              size: 20,
            ),
            const SizedBox(width: 12),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: Theme.of(context).textTheme.titleSmall),
                Text(subtitle, style: Theme.of(context).textTheme.bodySmall),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
