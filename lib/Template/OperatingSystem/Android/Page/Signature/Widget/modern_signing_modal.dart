import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:signature/signature.dart';
import '../../../../../Utils/Constant/enum.dart';
import '../Utils/signature_utils.dart';
import 'package:flutter/services.dart';

class ModernSigningModal extends StatefulWidget {
  final SignatureFieldType fieldType;
  final Function(Uint8List? signature) onSave;

  const ModernSigningModal({
    super.key,
    required this.fieldType,
    required this.onSave,
  });

  static void show({
    required SignatureFieldType fieldType,
    required Function(Uint8List? signature) onSave,
  }) {
    // Using Get.to with a full-screen dialog style
    Get.to(
      () => ModernSigningModal(fieldType: fieldType, onSave: onSave),
      fullscreenDialog: true,
      transition: Transition.downToUp,
    );
  }

  @override
  State<ModernSigningModal> createState() => _ModernSigningModalState();
}

class _ModernSigningModalState extends State<ModernSigningModal> {
  late SignatureController _signatureController;
  Color _selectedColor = Colors.black;

  final List<Color> _colors = [
    Colors.black,
    const Color(0xFF0066FF), // Blue
    const Color(0xFFFF0000), // Red
  ];

  @override
  void initState() {
    super.initState();
    // Force Landscape orientation
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.landscapeLeft,
      DeviceOrientation.landscapeRight,
    ]);
    _initSignatureController();
    _signatureController.addListener(() {
      if (mounted) setState(() {});
    });
  }

  void _initSignatureController() {
    _signatureController = SignatureController(
      penStrokeWidth: 4,
      penColor: _selectedColor,
      exportBackgroundColor: Colors.transparent,
      exportPenColor: _selectedColor,
    );
  }

  @override
  void dispose() {
    // Reset to Portrait only or default orientations
    SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
    _signatureController.dispose();
    super.dispose();
  }

  void _changeColor(Color color) {
    if (_selectedColor == color) return;
    setState(() => _selectedColor = color);

    final points = _signatureController.points;
    _signatureController.dispose();
    _signatureController = SignatureController(
      penStrokeWidth: 4,
      penColor: _selectedColor,
      exportBackgroundColor: Colors.transparent,
      exportPenColor: _selectedColor,
      points: points,
    );
  }

  Future<void> _handleSave() async {
    if (_signatureController.isEmpty) return;

    // Ink Normalization: Calculate drawing height to determine optimal stroke width
    final points = _signatureController.points;
    if (points.isNotEmpty) {
      double minY = double.infinity;
      double maxY = double.negativeInfinity;

      for (var point in points) {
        if (point.offset.dy < minY) minY = point.offset.dy;
        if (point.offset.dy > maxY) maxY = point.offset.dy;
      }

      final drawingHeight = maxY - minY;
      if (drawingHeight > 5) {
        // Use 6.5% of height as stroke width for professional weight
        // Clamp to ensure legibility (2.5px to 12px)
        final normalizedStroke = (drawingHeight * 0.065).clamp(2.5, 12.0);

        final exportController = SignatureController(
          penStrokeWidth: normalizedStroke,
          penColor: _selectedColor,
          exportBackgroundColor: Colors.transparent,
          exportPenColor: _selectedColor,
          points: points,
        );

        final bytes = await exportController.toPngBytes();
        exportController.dispose();

        if (bytes != null) {
          final trimmed = await SignatureUtils.trimWhitespace(bytes);
          widget.onSave(trimmed ?? bytes);
          Get.back();
          return;
        }
      }
    }

    // Fallback if normalization fails
    final bytes = await _signatureController.toPngBytes();
    if (bytes != null) {
      final trimmed = await SignatureUtils.trimWhitespace(bytes);
      widget.onSave(trimmed ?? bytes);
    }

    Get.back();
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final size = MediaQuery.of(context).size;

    return Scaffold(
      backgroundColor: cs.surface,
      body: SafeArea(
        child: Column(
          children: [
            // Top Bar - more compact
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  IconButton(
                    iconSize: 24,
                    visualDensity: VisualDensity.compact,
                    icon: Icon(Icons.close, color: cs.onSurfaceVariant),
                    onPressed: () => Get.back(),
                  ),
                  TextButton(
                    onPressed: _handleSave,
                    style: TextButton.styleFrom(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      visualDensity: VisualDensity.compact,
                    ),
                    child: Text(
                      'Save',
                      style: TextStyle(
                        color: _signatureController.isEmpty
                            ? Colors.grey
                            : cs.primary,
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // Drawing Area
            Expanded(
              child: Stack(
                children: [
                  Signature(
                    controller: _signatureController,
                    backgroundColor: Colors
                        .white, // Keep white for consistent drawing experience
                    height: double.infinity,
                    width: double.infinity,
                  ),

                  // Dashed Baseline
                  Positioned(
                    bottom: size.height * 0.25,
                    left: 40,
                    right: 40,
                    child: CustomPaint(
                      painter: DashedLinePainter(
                        color: cs.outlineVariant.withValues(alpha: 0.5),
                      ),
                      size: const Size(double.infinity, 1),
                    ),
                  ),
                ],
              ),
            ),

            // Footer
            Container(
              padding: const EdgeInsets.fromLTRB(24, 16, 24, 24),
              color: cs.surfaceContainerHigh,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'By tapping Save, I agree that the signature I have selected above will be the electronic representation of my signature for all purposes when I (or my agent) use them on documents, including legally binding contracts.',
                    style: TextStyle(
                      fontSize: 11,
                      color: cs.onSurfaceVariant,
                      height: 1.4,
                    ),
                  ),
                  const SizedBox(height: 20),
                  Row(
                    children: [
                      // Color Selection
                      ..._colors.map((color) {
                        final isSelected = _selectedColor == color;
                        return GestureDetector(
                          onTap: () => _changeColor(color),
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 200),
                            margin: const EdgeInsets.only(right: 16),
                            width: 38,
                            height: 38,
                            decoration: BoxDecoration(
                              color: color,
                              shape: BoxShape.circle,
                              border: Border.all(
                                color: isSelected
                                    ? cs.onSurface
                                    : Colors.transparent,
                                width: 2,
                              ),
                              boxShadow: isSelected
                                  ? [
                                      BoxShadow(
                                        color: color.withValues(alpha: 0.3),
                                        blurRadius: 8,
                                        spreadRadius: 2,
                                      ),
                                    ]
                                  : null,
                            ),
                            child: isSelected
                                ? const Icon(
                                    Icons.check,
                                    size: 20,
                                    color: Colors.white,
                                  )
                                : null,
                          ),
                        );
                      }),
                      const SizedBox(width: 8),

                      // Clear Button
                      TextButton(
                        onPressed: () =>
                            setState(() => _signatureController.clear()),
                        child: Text(
                          'Clear',
                          style: TextStyle(
                            color: cs.onSurfaceVariant,
                            fontWeight: FontWeight.w400,
                            fontSize: 15,
                          ),
                        ),
                      ),
                    ],
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

class DashedLinePainter extends CustomPainter {
  final Color color;
  DashedLinePainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = 1.5;

    const double dashWidth = 6;
    const double dashSpace = 4;
    double startX = 0;

    while (startX < size.width) {
      canvas.drawLine(Offset(startX, 0), Offset(startX + dashWidth, 0), paint);
      startX += dashWidth + dashSpace;
    }
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => false;
}
