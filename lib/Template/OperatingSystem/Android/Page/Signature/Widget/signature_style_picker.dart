import 'dart:typed_data';
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../../../Commons/Styles/style.dart';
import '../../../../../Commons/Widgets/app_button.dart';
import '../../../../../Utils/Constant/colors.dart';

// Font families for styled signature generation — must be in pubspec.yaml
const List<String> _signatureFonts = [
  'DancingScript',
  'GreatVibes',
  'Pacifico',
  'Satisfy',
];

class SignatureStylePicker extends StatefulWidget {
  final String name;
  final void Function(Uint8List imageBytes) onConfirm;

  const SignatureStylePicker({
    super.key,
    required this.name,
    required this.onConfirm,
  });

  // Show as bottom sheet
  static void show({
    required String name,
    required void Function(Uint8List imageBytes) onConfirm,
  }) {
    Get.bottomSheet(
      SignatureStylePicker(name: name, onConfirm: onConfirm),
      isScrollControlled: true,
    );
  }

  @override
  State<SignatureStylePicker> createState() => _SignatureStylePickerState();
}

class _SignatureStylePickerState extends State<SignatureStylePicker> {
  int _selectedIndex = 0;

  // Render name in given font to PNG bytes
  Future<Uint8List> _renderSignature(String fontFamily) async {
    const width = 320.0;
    const height = 80.0;

    final recorder = ui.PictureRecorder();
    final canvas = Canvas(recorder, const Rect.fromLTWH(0, 0, width, height));

    final textPainter = TextPainter(
      text: TextSpan(
        text: widget.name,
        style: TextStyle(
          fontFamily: fontFamily,
          fontSize: 40,
          color: AppColors.textPrimary,
        ),
      ),
      textDirection: TextDirection.ltr,
    )..layout(maxWidth: width);

    // Center vertically
    final yOffset = (height - textPainter.height) / 2;
    textPainter.paint(canvas, Offset(8, yOffset));

    final picture = recorder.endRecording();
    final image = await picture.toImage(width.toInt(), height.toInt());
    final byteData = await image.toByteData(format: ui.ImageByteFormat.png);
    return byteData!.buffer.asUint8List();
  }

  void _confirm() async {
    final bytes = await _renderSignature(_signatureFonts[_selectedIndex]);
    Get.back();
    widget.onConfirm(bytes);
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(24, 12, 24, 32),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Center(
            child: Container(
              width: 40,
              height: 4,
              decoration: AppStyle.bottomSheetHandle,
            ),
          ),
          const SizedBox(height: 20),
          Text(
            'Select a Style',
            style: Theme.of(context).textTheme.titleMedium,
          ),
          const SizedBox(height: 4),
          Text(
            'Choose how your signature will appear',
            style: Theme.of(context).textTheme.bodySmall,
          ),
          const SizedBox(height: 16),
          ...List.generate(_signatureFonts.length, (i) {
            final isSelected = i == _selectedIndex;
            return GestureDetector(
              onTap: () => setState(() => _selectedIndex = i),
              child: Container(
                margin: const EdgeInsets.only(bottom: 10),
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 12,
                ),
                decoration: BoxDecoration(
                  color: isSelected
                      ? AppColors.primarySurface
                      : AppColors.backgroundWhite,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: isSelected
                        ? AppColors.primary
                        : AppColors.borderLight,
                    width: isSelected ? 2 : 1,
                  ),
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: Text(
                        widget.name,
                        style: TextStyle(
                          fontFamily: _signatureFonts[i],
                          fontSize: 28,
                          color: AppColors.textPrimary,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    if (isSelected)
                      const Icon(
                        Icons.check_circle,
                        color: AppColors.primary,
                        size: 20,
                      ),
                  ],
                ),
              ),
            );
          }),
          const SizedBox(height: 8),
          AppButton.primary(label: 'Confirm', onPressed: _confirm),
        ],
      ),
    );
  }
}
