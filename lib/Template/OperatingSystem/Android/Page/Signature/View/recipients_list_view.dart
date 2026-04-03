import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../../../Commons/Styles/style.dart';
import '../../../../../Commons/Widgets/app_button.dart';
import '../../../../../Commons/Widgets/app_avatar.dart';
import '../../../../../Utils/Constant/colors.dart';
import '../../../../../Utils/Constant/enum.dart';
import '../Controller/signature_request_controller.dart';
import '../Model/signature_request_model.dart';

class RecipientsListView extends GetView<SignatureRequestController> {
  const RecipientsListView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Add Recipients'),
        leading: IconButton(
          icon: const Icon(Icons.chevron_left),
          onPressed: Get.back,
        ),
      ),
      body: Obx(() {
        final signers = controller.signers;
        return Column(
          children: [
            Expanded(
              child: ListView(
                padding: const EdgeInsets.all(16),
                children: [
                  _SigningOrderToggle(controller: controller),
                  const SizedBox(height: 16),
                  if (signers.isEmpty)
                    const SizedBox.shrink()
                  else
                    controller.signingOrderEnabled.value
                        ? _ReorderableSignerList(
                            controller: controller,
                            signers: signers,
                          )
                        : _StaticSignerList(
                            controller: controller,
                            signers: signers,
                          ),
                  const SizedBox(height: 8),
                  // Add another recipient row
                  GestureDetector(
                    onTap: controller.goToAddRecipient,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 14,
                      ),
                      decoration: AppStyle.card(),
                      child: Row(
                        children: [
                          const Icon(
                            Icons.add,
                            color: AppColors.primary,
                            size: 20,
                          ),
                          const SizedBox(width: 12),
                          Text(
                            'Add another recipient',
                            style: Theme.of(context).textTheme.titleSmall
                                ?.copyWith(color: AppColors.primary),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
            _BottomActions(controller: controller, signers: signers),
          ],
        );
      }),
    );
  }
}

class _SigningOrderToggle extends StatelessWidget {
  final SignatureRequestController controller;
  const _SigningOrderToggle({required this.controller});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          'Set Signing Order',
          style: Theme.of(context).textTheme.titleSmall,
        ),
        Obx(
          () => Switch(
            value: controller.signingOrderEnabled.value,
            onChanged: controller.toggleSigningOrder,
            activeThumbColor: AppColors.primary,
          ),
        ),
      ],
    );
  }
}

// Static list when signing order is off
class _StaticSignerList extends StatelessWidget {
  final SignatureRequestController controller;
  final List<SignerModel> signers;
  const _StaticSignerList({required this.controller, required this.signers});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: signers
          .map(
            (s) => Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: _SignerTile(
                signer: s,
                controller: controller,
                showOrder: false,
              ),
            ),
          )
          .toList(),
    );
  }
}

// Reorderable list when signing order is on
class _ReorderableSignerList extends StatelessWidget {
  final SignatureRequestController controller;
  final List<SignerModel> signers;
  const _ReorderableSignerList({
    required this.controller,
    required this.signers,
  });

  @override
  Widget build(BuildContext context) {
    return ReorderableListView(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      buildDefaultDragHandles: false,
      onReorder: controller.reorderSigners,
      children: List.generate(
        signers.length,
        (i) => Padding(
          key: ValueKey(signers[i].signerEmail),
          padding: const EdgeInsets.only(bottom: 8),
          child: _SignerTile(
            signer: signers[i],
            controller: controller,
            showOrder: true,
            index: i,
          ),
        ),
      ),
    );
  }
}

class _SignerTile extends StatelessWidget {
  final SignerModel signer;
  final SignatureRequestController controller;
  final bool showOrder;
  final int? index;

  const _SignerTile({
    required this.signer,
    required this.controller,
    required this.showOrder,
    this.index,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: AppStyle.card(),
      child: ListTile(
        contentPadding: const EdgeInsets.only(left: 16),
        leading: AppAvatar(name: signer.signerName),
        title: Text(
          signer.signerEmail == controller.currentUserEmail
              ? '${signer.signerName} (ME)'
              : signer.signerName,
          style: Theme.of(context).textTheme.titleSmall,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              signer.signerEmail,
              style: Theme.of(context).textTheme.bodySmall,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            Text(
              signer.role == SignerRole.needsToSign
                  ? 'Needs to sign'
                  : 'Receives a copy',
              style: Theme.of(
                context,
              ).textTheme.bodySmall?.copyWith(color: AppColors.textHint),
            ),
          ],
        ),
        trailing: showOrder
            ? ReorderableDragStartListener(
                index: index!,
                child: const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 12),
                  child: Icon(Icons.drag_handle, color: AppColors.textHint),
                ),
              )
            : IconButton(
                icon: const Icon(
                  Icons.more_vert,
                  size: 18,
                  color: AppColors.textHint,
                ),
                onPressed: () => controller.showSignerOptions(signer),
              ),
      ),
    );
  }
}

class _BottomActions extends StatelessWidget {
  final SignatureRequestController controller;
  final List<SignerModel> signers;
  const _BottomActions({required this.controller, required this.signers});

  @override
  Widget build(BuildContext context) {
    final hasSigners = signers.any((s) => s.role == SignerRole.needsToSign);
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 32),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          AppButton.primary(
            label: 'Next',
            onPressed: hasSigners ? controller.goToPlaceFields : null,
          ),
          const SizedBox(height: 8),
          AppButton.outlined(
            label: 'Cancel',
            onPressed: controller.cancelRequest,
          ),
        ],
      ),
    );
  }
}
