import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../../../Utils/Constant/colors.dart';
import '../../../../../Utils/Formatters/formatter.dart';
import '../Controller/signature_request_controller.dart';
import '../Model/signature_request_model.dart';

class RequestReviewView extends GetView<SignatureRequestController> {
  const RequestReviewView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text(
          'Review',
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.w700,
                color: AppColors.textPrimary,
              ),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppColors.textPrimary),
          onPressed: Get.back,
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.more_vert, color: AppColors.textPrimary),
            onPressed: () {},
          ),
        ],
        backgroundColor: Colors.white,
        elevation: 0,
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1),
          child: Container(color: AppColors.borderLight, height: 1),
        ),
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
              Obx(() => Text(
                    '${controller.currentUserName} via DocuSign',
                    style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                          color: AppColors.textPrimary,
                        ),
                  )),
              const SizedBox(height: 16),

              // Email Section
              const _SectionHeader(label: 'Email'),
              const SizedBox(height: 16),
              _buildEmailForm(context),
              const SizedBox(height: 32),

              // Recipients Section
              const _SectionHeader(label: 'Recipients'),
              const SizedBox(height: 16),
              Obx(() => Column(
                    children: controller.signers
                        .map((s) => _ReviewRecipientTile(signer: s))
                        .toList(),
                  )),
              const SizedBox(height: 32),

              // Envelope Type Section
              Row(
                children: [
                  const _SectionHeader(label: 'Envelope Type'),
                  const SizedBox(width: 8),
                  Icon(Icons.info_outline, color: Colors.black.withOpacity(0.8), size: 20),
                ],
              ),
              const SizedBox(height: 12),
              _buildEnvelopeTypePicker(context),
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
        Obx(() => TextFormField(
              controller: controller.subjectController,
              onChanged: (v) => controller.emailSubject.value = v,
              maxLength: 100,
              decoration: InputDecoration(
                labelText: 'Email subject*',
                labelStyle: const TextStyle(fontSize: 14),
                border: const OutlineInputBorder(),
                counterText: '${controller.emailSubject.value.length}/100',
                contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              ),
            )),
        const SizedBox(height: 16),
        Obx(() => TextFormField(
              controller: controller.messageController,
              onChanged: (v) => controller.emailMessage.value = v,
              maxLength: 10000,
              maxLines: 6,
              decoration: InputDecoration(
                labelText: 'Message',
                labelStyle: const TextStyle(fontSize: 14),
                border: const OutlineInputBorder(),
                counterText: '${controller.emailMessage.value.length}/10000',
                alignLabelWithHint: true,
                contentPadding: const EdgeInsets.all(16),
              ),
            )),
      ],
    );
  }

  Widget _buildEnvelopeTypePicker(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(4),
        border: Border.all(color: Colors.grey.shade400),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Select',
                style: Theme.of(context).textTheme.labelSmall?.copyWith(
                    color: Colors.grey.shade600, fontSize: 10),
              ),
              Obx(() => Text(
                    controller.envelopeType.value,
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: Colors.black87),
                  )),
            ],
          ),
          Icon(Icons.arrow_drop_down, color: Colors.grey.shade600),
        ],
      ),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  final String label;
  const _SectionHeader({required this.label});

  @override
  Widget build(BuildContext context) {
    return Text(
      label,
      style: Theme.of(context).textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w700,
            color: const Color(0xFF1E0B4B), // Dark navy/purple from image
          ),
    );
  }
}

class _ReviewRecipientTile extends StatelessWidget {
  final SignerModel signer;
  const _ReviewRecipientTile({required this.signer});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 24),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: const Color(0xFFD1F7FF), // Standard blue avatar bg
            ),
            child: Center(
              child: Text(
                AppFormatter.initials(signer.signerName),
                style: const TextStyle(
                  color: Color(0xFF1E0B4B),
                  fontWeight: FontWeight.w700,
                  fontSize: 16,
                ),
              ),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  signer.signerName,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w700,
                        color: const Color(0xFF1E0B4B),
                      ),
                ),
                Text(
                  signer.signerEmail,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: Colors.grey.shade600,
                      ),
                ),
                const SizedBox(height: 2),
                Text(
                  'Needs to sign',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: Colors.grey.shade600,
                      ),
                ),
              ],
            ),
          ),
        ],
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
        border: Border(top: BorderSide(color: Colors.grey.shade300)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 4,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      padding: const EdgeInsets.fromLTRB(24, 12, 24, 32),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          Obx(() => SizedBox(
                width: 120,
                child: ElevatedButton(
                  onPressed: controller.isSending.value ? null : controller.submitRequest,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF1E0B4B),
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                  child: controller.isSending.value
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Colors.white,
                          ),
                        )
                      : const Text(
                          'Sign',
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                ),
              )),
        ],
      ),
    );
  }
}



