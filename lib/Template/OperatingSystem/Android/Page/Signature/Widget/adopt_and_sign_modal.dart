import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:signature/signature.dart';
import '../../../../../Utils/Constant/colors.dart';
import '../../../../../Utils/Constant/enum.dart';
import '../Utils/signature_utils.dart';

class AdoptAndSignModal {
  final String initialName;
  final String initialInitials;
  final SignatureFieldType fieldType;
  final Function(Uint8List? signature, String name, String initials) onAdopt;

  const AdoptAndSignModal._({
    required this.initialName,
    required this.initialInitials,
    required this.fieldType,
    required this.onAdopt,
  });

  static Future<void> show({
    required String initialName,
    required String initialInitials,
    required SignatureFieldType fieldType,
    required Function(Uint8List? signature, String name, String initials)
    onAdopt,
  }) async {
    final target = _SigningInkTarget.fromFieldType(fieldType);

    final flow = AdoptAndSignModal._(
      initialName: initialName,
      initialInitials: initialInitials,
      fieldType: fieldType,
      onAdopt: onAdopt,
    );

    await Get.bottomSheet<void>(
      _SignatureSourceSheet(
        target: target,
        onDrawSignature: () async {
          Get.back<void>();
          await Get.to<void>(
            () => _InAppSignatureCapturePage(
              target: target,
              onSave: (bytes) => flow._adopt(bytes),
            ),
          );
        },
        onTakePhoto: () async {
          final picker = ImagePicker();
          final XFile? image = await picker.pickImage(
            source: ImageSource.camera,
          );
          if (image == null) return;

          Uint8List bytes = await image.readAsBytes();
          final trimmed = await SignatureUtils.trimWhitespace(bytes);
          if (trimmed != null) {
            bytes = trimmed;
          }

          Get.back<void>();
          flow._adopt(bytes);
        },
      ),
      backgroundColor: Colors.transparent,
    );
  }

  void _adopt(Uint8List? signatureBytes) {
    onAdopt(signatureBytes, initialName, initialInitials);
  }
}

class _SignatureSourceSheet extends StatelessWidget {
  final _SigningInkTarget target;
  final Future<void> Function() onDrawSignature;
  final Future<void> Function() onTakePhoto;

  const _SignatureSourceSheet({
    required this.target,
    required this.onDrawSignature,
    required this.onTakePhoto,
  });

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Material(
          color: cs.surface,
          elevation: 8,
          borderRadius: BorderRadius.circular(12),
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 14, 16, 10),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Add ${target.nounLower} to profile',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 8),
                ListTile(
                  dense: true,
                  contentPadding: EdgeInsets.zero,
                  leading: const Icon(Icons.edit_outlined),
                  title: Text('Draw ${target.nounLower}'),
                  onTap: onDrawSignature,
                ),
                ListTile(
                  dense: true,
                  contentPadding: EdgeInsets.zero,
                  leading: const Icon(Icons.photo_camera_outlined),
                  title: const Text('Take photo'),
                  onTap: onTakePhoto,
                ),
                Align(
                  alignment: Alignment.centerRight,
                  child: TextButton(
                    onPressed: () => Get.back<void>(),
                    child: const Text('Cancel'),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _InAppSignatureCapturePage extends StatefulWidget {
  final _SigningInkTarget target;
  final void Function(Uint8List signatureBytes) onSave;

  const _InAppSignatureCapturePage({
    required this.target,
    required this.onSave,
  });

  @override
  State<_InAppSignatureCapturePage> createState() =>
      _InAppSignatureCapturePageState();
}

class _InAppSignatureCapturePageState
    extends State<_InAppSignatureCapturePage> {
  late SignatureController _controller;
  late Color _selectedColor;
  late List<Color> _baseInkColors;

  @override
  void initState() {
    super.initState();
    _baseInkColors = [
      Get.theme.colorScheme.onSurface,
      AppColors.blue,
      AppColors.red,
    ];
    _selectedColor = _baseInkColors[0];
    _rebuildController();
    SystemChrome.setPreferredOrientations(const [
      DeviceOrientation.landscapeLeft,
      DeviceOrientation.landscapeRight,
    ]);
  }

  @override
  void dispose() {
    _controller.dispose();
    SystemChrome.setPreferredOrientations(DeviceOrientation.values);
    super.dispose();
  }

  void _rebuildController({List<Point>? keepPoints}) {
    final oldPoints = keepPoints ?? const <Point>[];
    _controller = SignatureController(
      penStrokeWidth: widget.target.strokeWidth,
      penColor: _selectedColor,
      exportBackgroundColor: Colors.transparent,
      exportPenColor: _selectedColor,
    )..points = oldPoints;
  }

  void _changeColor(Color color) {
    if (_selectedColor == color) return;

    final points = List<Point>.from(_controller.points);
    _controller.dispose();
    setState(() {
      _selectedColor = color;
      _rebuildController(keepPoints: points);
    });
  }

  Future<void> _save() async {
    if (_controller.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Please draw your ${widget.target.nounLower} first.'),
        ),
      );
      return;
    }

    Uint8List? bytes = await _controller.toPngBytes();
    if (bytes == null) return;

    final trimmed = await SignatureUtils.trimWhitespace(bytes);
    if (trimmed != null) {
      bytes = trimmed;
    }

    widget.onSave(bytes);
    if (mounted) {
      Get.back<void>();
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;
    final inkColors = [cs.onSurface, ..._baseInkColors.skip(1)];

    return Scaffold(
      backgroundColor: cs.surface,
      appBar: AppBar(
        backgroundColor: cs.surface,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.close),
          onPressed: () => Get.back<void>(),
        ),
        actions: [TextButton(onPressed: _save, child: const Text('Save'))],
      ),
      body: Column(
        children: [
          Expanded(
            child: Stack(
              children: [
                Positioned.fill(
                  child: Signature(
                    controller: _controller,
                    backgroundColor: cs.surface,
                  ),
                ),
                Positioned.fill(
                  child: IgnorePointer(
                    child: Center(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 24),
                        child: Row(
                          children: List.generate(
                            36,
                            (index) => Expanded(
                              child: Container(
                                height: 2,
                                margin: const EdgeInsets.symmetric(
                                  horizontal: 2,
                                ),
                                color: index.isEven
                                    ? cs.outlineVariant
                                    : Colors.transparent,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 14),
            decoration: BoxDecoration(
              color: cs.surfaceContainerHighest,
              border: Border(top: BorderSide(color: cs.outlineVariant)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'By tapping Save, I agree that the ${widget.target.nounLower} I have selected above will be the electronic representation of my ${widget.target.nounLower} for all purposes when I (or my agent) use them on documents, including legally binding contracts.',
                  style: theme.textTheme.bodySmall?.copyWith(
                    fontSize: 11,
                    color: cs.onSurfaceVariant,
                    height: 1.3,
                  ),
                ),
                const SizedBox(height: 10),
                Row(
                  children: [
                    for (final color in inkColors) ...[
                      GestureDetector(
                        onTap: () => _changeColor(color),
                        child: Container(
                          margin: const EdgeInsets.only(right: 12),
                          width: 36,
                          height: 36,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: color,
                            border: Border.all(
                              color: _selectedColor == color
                                  ? cs.primary
                                  : cs.outlineVariant,
                              width: _selectedColor == color ? 3 : 1,
                            ),
                          ),
                        ),
                      ),
                    ],
                    TextButton(
                      onPressed: _controller.clear,
                      child: Text('Clear', style: theme.textTheme.titleMedium),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

enum _SigningInkTarget {
  signature(nounLower: 'signature', strokeWidth: 3.2),
  initials(nounLower: 'initials', strokeWidth: 2.8);

  final String nounLower;
  final double strokeWidth;

  const _SigningInkTarget({required this.nounLower, required this.strokeWidth});

  static _SigningInkTarget fromFieldType(SignatureFieldType type) {
    return type == SignatureFieldType.initials
        ? _SigningInkTarget.initials
        : _SigningInkTarget.signature;
  }
}
