import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../../../Utils/Constant/enum.dart';
import '../../../../../Commons/Styles/style.dart';
import '../Controller/signature_placement_controller.dart';

class SignerSwitcher extends StatelessWidget {
  final SignaturePlacementController controller;

  const SignerSwitcher({super.key, required this.controller});

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final signers = controller.activeSigners;
      if (signers.isEmpty) return const SizedBox.shrink();

      final activeIndex = controller.activeSignerIndex.value.clamp(
        0,
        signers.length - 1,
      );

      return Container(
        padding: const EdgeInsets.symmetric(vertical: 8),
        color: Theme.of(context).colorScheme.surfaceContainer,
        width: double.infinity,
        child: SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: ConstrainedBox(
            constraints: BoxConstraints(
              minWidth: MediaQuery.of(context).size.width,
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              mainAxisSize: MainAxisSize.min,
              children: List.generate(signers.length, (i) {
                final isActive = i == activeIndex;
                final signer = signers[i];
                final signerColor = AppStyle.signerColor(context, i);
                final roleLabel = signer.role == SignerRole.needsToSign
                    ? 'Need to Sign'
                    : 'Receive a Copy';

                return GestureDetector(
                  onTap: () => controller.switchSigner(i),
                  behavior: HitTestBehavior.opaque,
                  child: Container(
                    width: 80,
                    margin: const EdgeInsets.symmetric(horizontal: 4),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        // DocuSign-style Avatar Circle (Compact)
                        Container(
                          width: 36,
                          height: 36,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: isActive ? signerColor : Colors.transparent,
                            border: Border.all(color: signerColor, width: 1.5),
                          ),
                          child: Center(
                            child: Text(
                              _getInitials(signer.signerName),
                              style: TextStyle(
                                color: isActive ? Colors.white : signerColor,
                                fontWeight: FontWeight.bold,
                                fontSize: 13,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 6),
                        // Name (Compact)
                        Text(
                          signer.signerEmail == controller.currentUserEmail
                              ? '${signer.signerName} (ME)'
                              : signer.signerName,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          textAlign: TextAlign.center,
                          style: Theme.of(context).textTheme.bodySmall
                              ?.copyWith(
                                color: Theme.of(context).colorScheme.onSurface,
                                fontWeight: isActive
                                    ? FontWeight.bold
                                    : FontWeight.w500,
                                fontSize: 11,
                              ),
                        ),
                        // Role (Compact)
                        Text(
                          roleLabel,
                          textAlign: TextAlign.center,
                          style: Theme.of(context).textTheme.labelSmall
                              ?.copyWith(
                                color: Theme.of(context).colorScheme.onSurfaceVariant,
                                fontSize: 9,
                                height: 1.1,
                              ),
                        ),
                      ],
                    ),
                  ),
                );
              }),
            ),
          ),
        ),
      );
    });
  }

  String _getInitials(String name) {
    if (name.isEmpty) return '';
    final parts = name.trim().split(' ');
    if (parts.length > 1) {
      return (parts[0][0] + parts[parts.length - 1][0]).toUpperCase();
    }
    return parts[0][0].toUpperCase();
  }
}
