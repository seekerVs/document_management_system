import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:scrivener/Template/Commons/Styles/style.dart';
import '../../../../../Commons/Widgets/app_button.dart';
import '../../../../../Utils/Constant/colors.dart';
import '../../../../../Utils/Constant/images.dart';
import '../Controller/in_app_signing_controller.dart';

class InAppSigningSplashOverlay extends StatelessWidget {
  const InAppSigningSplashOverlay({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<InAppSigningController>();
    final requesterName = controller.request.requesterName ?? 'Someone';
    final isSelf = controller.request.requestedByUid == controller.signer.signerUid;

    final cs = Theme.of(context).colorScheme;

    return Scaffold(
      backgroundColor: cs.surface,
      appBar: AppBar(
        backgroundColor: cs.surface,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.close, color: cs.onSurfaceVariant),
          onPressed: () {
            controller.beginSigning();
          },
        ),
        title: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            SvgPicture.asset(
              AppImages.logo,
              height: 24,
              colorFilter: const ColorFilter.mode(
                AppColors.blue,
                BlendMode.srcIn,
              ),
            ),
            const SizedBox(width: 8),
            Text(
              'scrivener',
              style: AppStyle.appName.copyWith(
                fontWeight: FontWeight.bold,
                color: cs.onSurface,
                letterSpacing: -0.5,
              ),
            ),
          ],
        ),
        centerTitle: false,
      ),
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            return SingleChildScrollView(
              padding: const EdgeInsets.symmetric(vertical: 8),
              child: ConstrainedBox(
                constraints: BoxConstraints(
                  minHeight: constraints.maxHeight - 16,
                ),
                child: IntrinsicHeight(
                  child: Column(
                    children: [
                      const SizedBox(height: 16),
                      // Main Text
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 24.0),
                          child: Text(
                            isSelf
                                ? "You've requested your own signature on this document."
                                : '$requesterName has asked for your signature.',
                          textAlign: TextAlign.start,
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: cs.onSurface,
                            height: 1.3,
                          ),
                        ),
                      ),
                      const Spacer(flex: 3),
                      // Bottom Section
                      Padding(
                        padding: const EdgeInsets.all(24.0),
                        child: Column(
                          children: [
                            RichText(
                              textAlign: TextAlign.center,
                              text: TextSpan(
                                style: TextStyle(
                                  fontSize: 12,
                                  color: cs.onSurfaceVariant,
                                  height: 1.5,
                                ),
                                children: [
                                  const TextSpan(
                                    text:
                                        'By selecting Begin Signing, you consent to do business electronically with ',
                                  ),
                                  const TextSpan(
                                    text: 'Scrivener',
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  const TextSpan(text: '.\n'),
                                  TextSpan(
                                    text:
                                        'Read about doing business electronically',
                                    style: TextStyle(
                                      color: cs.primary,
                                      decoration: TextDecoration.underline,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(height: 24),
                            AppButton.primary(
                              label: 'Begin Signing',
                              onPressed: () {
                                controller.beginSigning();
                              },
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
