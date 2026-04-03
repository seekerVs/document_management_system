import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../../../Commons/Styles/style.dart';
import '../../../../../Commons/Widgets/app_avatar.dart';
import '../../../../../Commons/Widgets/app_button.dart';
import '../../../../../Commons/Widgets/app_text_field.dart';
import '../../../../../Utils/Constant/colors.dart';
import '../Controller/signature_request_controller.dart';
import '../Model/signature_request_model.dart';

class RequestReviewView extends GetView<SignatureRequestController> {
  const RequestReviewView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Review'),
        leading: IconButton(
          icon: const Icon(Icons.chevron_left),
          onPressed: Get.back,
        ),
        actions: [
          IconButton(icon: const Icon(Icons.more_vert), onPressed: () {}),
        ],
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // From Section
              const _SectionHeader(label: 'From'),
              const SizedBox(height: 8),
              Obx(
                () => Text(
                  '${controller.currentUserName} via DocuSign',
                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                    color: AppColors.textPrimary,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
              const SizedBox(height: 24),

              // Email Section
              const _SectionHeader(label: 'Email'),
              const SizedBox(height: 16),
              _buildEmailForm(context),
              const SizedBox(height: 32),

              // Recipients Section
              const _SectionHeader(label: 'Recipients'),
              const SizedBox(height: 16),
              Obx(
                () => Column(
                  children: controller.signers
                      .map((s) => _ReviewRecipientTile(
                            signer: s,
                            isMe: s.signerEmail == controller.currentUserEmail,
                          ))
                      .toList(),
                ),
              ),
              const SizedBox(height: 40),
            ],
          ),
        ),
      ),
      bottomNavigationBar: _BottomFooter(controller: controller),
    );
  }

  Widget _buildEmailForm(BuildContext context) {
    return Column(
      children: [
        Obx(
          () => AppTextField(
            label: 'Email subject*',
            hint: 'Enter subject',
            controller: controller.subjectController,
            onChanged: (v) => controller.emailSubject.value = v,
            maxLength: 100,
            counterText: '${controller.emailSubject.value.length}/100',
          ),
        ),
        const SizedBox(height: 16),
        Obx(
          () => AppTextField(
            label: 'Message',
            hint: 'Enter message',
            controller: controller.messageController,
            onChanged: (v) => controller.emailMessage.value = v,
            maxLength: 10000,
            maxLines: 5,
            counterText: '${controller.emailMessage.value.length}/10000',
          ),
        ),
      ],
    );
  }
}

class _SectionHeader extends StatelessWidget {
  final String label;
  const _SectionHeader({required this.label});

  @override
  Widget build(BuildContext context) {
    return Text(
      label.toUpperCase(),
      style: Theme.of(context).textTheme.labelLarge?.copyWith(
        fontWeight: FontWeight.w800,
        letterSpacing: 1.2,
        color: AppColors.navy.withValues(alpha: 0.8),
        fontSize: 12,
      ),
    );
  }
}

class _ReviewRecipientTile extends StatelessWidget {
  final SignerModel signer;
  final bool isMe;
  const _ReviewRecipientTile({required this.signer, required this.isMe});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: AppStyle.card(),
        child: Row(
          children: [
            AppAvatar(name: signer.signerName, radius: 22),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    isMe ? '${signer.signerName} (ME)' : signer.signerName,
                    style: Theme.of(context).textTheme.titleSmall,
                  ),
                  Text(
                    signer.signerEmail,
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                ],
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: AppStyle.statusBadge(AppColors.grey),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(
                    Icons.edit_note,
                    size: 14,
                    color: AppColors.textSecondary,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    'Needs to sign',
                    style: Theme.of(context).textTheme.labelSmall?.copyWith(
                      color: AppColors.textSecondary,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _BottomFooter extends StatelessWidget {
  final SignatureRequestController controller;
  const _BottomFooter({required this.controller});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border(top: BorderSide(color: Colors.grey.shade200)),
      ),
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 32),
      child: Obx(
        () => AppButton.primary(
          label: 'SEND',
          onPressed: controller.isSending.value
              ? null
              : controller.submitRequest,
          isLoading: controller.isSending.value,
        ),
      ),
    );
  }
}
