import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:signature/signature.dart';

class SignatureDrawPad extends StatefulWidget {
  final Future<void> Function(Uint8List) onSave;

  const SignatureDrawPad({super.key, required this.onSave});

  static Future<void> show({required Future<void> Function(Uint8List) onSave}) {
    return Get.dialog(
      SignatureDrawPad(onSave: onSave),
      barrierDismissible: false,
    );
  }

  @override
  State<SignatureDrawPad> createState() => _SignatureDrawPadState();
}

class _SignatureDrawPadState extends State<SignatureDrawPad> {
  late SignatureController _controller;
  late List<Color> _colors;
  late Color _selectedColor;

  @override
  void initState() {
    super.initState();
    _colors = [
      Get.theme.colorScheme.onSurface,
      const Color(0xFF0066FF), // Blue
      const Color(0xFFFF0000), // Red
    ];
    _selectedColor = _colors[0];
    _initController();
  }

  void _initController() {
    _controller = SignatureController(
      penStrokeWidth: 4,
      penColor: _selectedColor,
      exportBackgroundColor: Colors.transparent,
      exportPenColor: _selectedColor,
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _changeColor(Color color) {
    if (_selectedColor == color) return;
    setState(() => _selectedColor = color);
    final points = _controller.points;
    _controller.dispose();
    _initController();
    _controller.points = points;
  }

  Future<void> _handleSave() async {
    if (_controller.isEmpty) {
      Get.snackbar(
        'Empty Signature',
        'Please draw a signature before saving.',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Theme.of(context).colorScheme.errorContainer,
        colorText: Theme.of(context).colorScheme.onErrorContainer,
        margin: const EdgeInsets.all(16),
      );
      return;
    }

    final bytes = await _controller.toPngBytes();
    if (bytes != null) {
      await widget.onSave(bytes);
      Get.back();
    }
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return Dialog(
      backgroundColor: cs.surface,
      surfaceTintColor: Colors.transparent,
      insetPadding: const EdgeInsets.all(16),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: SizedBox(
          height: 400, // Fixed height or responsive
          child: Row(
            children: [
              // Sidebar
              Container(
                width: 80,
                decoration: BoxDecoration(
                  color: cs.surfaceContainerHighest,
                  border: Border(right: BorderSide(color: cs.outlineVariant)),
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    for (final color in _colors)
                      GestureDetector(
                        onTap: () => _changeColor(color),
                        child: Container(
                          margin: const EdgeInsets.only(bottom: 16),
                          width: 32,
                          height: 32,
                          decoration: BoxDecoration(
                            color: color,
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: _selectedColor == color
                                  ? cs.primary
                                  : cs.outline,
                              width: _selectedColor == color ? 3 : 1,
                            ),
                          ),
                        ),
                      ),
                    const SizedBox(height: 24),
                    GestureDetector(
                      onTap: _controller.clear,
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.clear, color: cs.onSurfaceVariant),
                          const SizedBox(height: 4),
                          Text(
                            'Clear',
                            style: TextStyle(
                              color: cs.onSurfaceVariant,
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              // Main Canvas Area
              Expanded(
                child: Stack(
                  children: [
                    // Canvas
                    Positioned.fill(
                      child: Signature(
                        controller: _controller,
                        backgroundColor: cs.surface,
                      ),
                    ),
                    // Dashed line
                    Center(
                      child: Row(
                        children: List.generate(
                          30,
                          (index) => Expanded(
                            child: Container(
                              color: index % 2 == 0
                                  ? cs.outlineVariant
                                  : Colors.transparent,
                              height: 1,
                            ),
                          ),
                        ),
                      ),
                    ),
                    // Close button
                    Positioned(
                      top: 16,
                      right: 16,
                      child: IconButton(
                        icon: const Icon(Icons.close),
                        iconSize: 32,
                        color: cs.onSurface,
                        onPressed: Get.back,
                      ),
                    ),
                    // Save text button
                    Positioned(
                      bottom: 16,
                      right: 24,
                      child: GestureDetector(
                        onTap: _handleSave,
                        child: Text(
                          'Save',
                          style: TextStyle(
                            color: _selectedColor != Colors.black
                                ? _selectedColor
                                : cs.primary,
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
