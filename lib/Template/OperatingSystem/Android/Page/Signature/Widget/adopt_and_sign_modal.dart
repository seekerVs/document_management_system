import 'dart:typed_data';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:get/get.dart';
import 'package:signature/signature.dart';
import '../../../../../Commons/Widgets/app_button.dart';
import '../../../../../Utils/Constant/enum.dart';
import 'AdoptAndSign/draw_signature_tab.dart';
import 'AdoptAndSign/signature_preview_frame.dart';
import 'AdoptAndSign/upload_signature_tab.dart';
import '../Utils/signature_utils.dart';

class AdoptAndSignModal extends StatefulWidget {
  final String initialName;
  final String initialInitials;
  final SignatureFieldType fieldType;
  final Function(Uint8List? signature, String name, String initials) onAdopt;

  const AdoptAndSignModal({
    super.key,
    required this.initialName,
    required this.initialInitials,
    required this.fieldType,
    required this.onAdopt,
  });

  // Helper to show the modal
  static void show({
    required String initialName,
    required String initialInitials,
    required SignatureFieldType fieldType,
    required Function(Uint8List? signature, String name, String initials)
    onAdopt,
  }) {
    Get.dialog(
      AdoptAndSignModal(
        initialName: initialName,
        initialInitials: initialInitials,
        fieldType: fieldType,
        onAdopt: onAdopt,
      ),
      barrierColor: Colors.black54,
    );
  }

  @override
  State<AdoptAndSignModal> createState() => _AdoptAndSignModalState();
}

class _AdoptAndSignModalState extends State<AdoptAndSignModal>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  late TextEditingController _nameController;
  late TextEditingController _initialsController;
  late SignatureController _signatureController;
  final GlobalKey _previewKey = GlobalKey();
  String _selectedFont = 'DancingScript';

  final List<String> _fonts = [
    'DancingScript',
    'GreatVibes',
    'Pacifico',
    'Satisfy',
    'Kameron',
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _nameController = TextEditingController(text: widget.initialName);
    _initialsController = TextEditingController(text: widget.initialInitials);
    _signatureController = SignatureController(
      exportBackgroundColor: Colors.transparent,
    );
  }

  @override
  void dispose() {
    _tabController.dispose();
    _nameController.dispose();
    _initialsController.dispose();
    _signatureController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Dialog(
      insetPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: ConstrainedBox(
        constraints: BoxConstraints(
          maxHeight: MediaQuery.of(context).size.height * 0.85,
          maxWidth: 500,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _buildHeader(colorScheme),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          flex: 3,
                          child: _buildTextField(
                            label: 'Full Name',
                            controller: _nameController,
                            hintText: 'Full Name',
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: _buildTextField(
                            label: 'Initials',
                            controller: _initialsController,
                            hintText: 'Initials',
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),
                    _buildTabs(colorScheme),
                    SizedBox(
                      height: 220,
                      child: TabBarView(
                        controller: _tabController,
                        physics: const NeverScrollableScrollPhysics(),
                        children: [
                          _buildStyleTab(colorScheme),
                          DrawSignatureTab(
                            signatureController: _signatureController,
                          ),
                          UploadSignatureTab(
                            onImageSelected: (bytes) {
                              widget.onAdopt(
                                bytes,
                                _nameController.text,
                                _initialsController.text,
                              );
                              Get.back();
                            },
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'By selecting Adopt and Sign, I agree that the signature and initials extension will be the electronic representation of my signature for all purposes on documents.',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: colorScheme.onSurfaceVariant,
                        fontSize: 10,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            _buildFooter(colorScheme),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(ColorScheme colorScheme) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      decoration: BoxDecoration(
        border: Border(bottom: BorderSide(color: colorScheme.outlineVariant)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            'Adopt Your Signature',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
              color: colorScheme.primary,
            ),
          ),
          IconButton(
            onPressed: () => Get.back(),
            icon: const Icon(Icons.close, size: 20),
            visualDensity: VisualDensity.compact,
          ),
        ],
      ),
    );
  }

  Widget _buildTextField({
    required String label,
    required TextEditingController controller,
    required String hintText,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: Theme.of(context).textTheme.labelSmall?.copyWith(
            fontWeight: FontWeight.bold,
            color: Theme.of(context).colorScheme.onSurface,
          ),
        ),
        const SizedBox(height: 6),
        TextField(
          controller: controller,
          decoration: InputDecoration(
            isDense: true,
            hintText: hintText,
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 12,
              vertical: 12,
            ),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(4)),
          ),
          onChanged: (_) => setState(() {}),
        ),
      ],
    );
  }

  Widget _buildTabs(ColorScheme colorScheme) {
    return TabBar(
      controller: _tabController,
      labelColor: colorScheme.primary,
      unselectedLabelColor: colorScheme.onSurfaceVariant,
      indicatorColor: colorScheme.primary,
      indicatorWeight: 3,
      tabs: const [
        Tab(text: 'STYLE'),
        Tab(text: 'DRAW'),
        Tab(text: 'UPLOAD'),
      ],
    );
  }

  Widget _buildStyleTab(ColorScheme colorScheme) {
    return Column(
      children: [
        const SizedBox(height: 16),
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: colorScheme.surfaceContainerHighest.withValues(alpha: 0.3),
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: colorScheme.outlineVariant),
          ),
          child: SignaturePreviewFrame(
            name: _nameController.text,
            initials: _initialsController.text,
            font: _selectedFont,
            fieldType: widget.fieldType,
            captureKey: _previewKey,
          ),
        ),
        const SizedBox(height: 12),
        SizedBox(
          height: 50,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            itemCount: _fonts.length,
            separatorBuilder: (_, _) => const SizedBox(width: 8),
            itemBuilder: (context, index) {
              final font = _fonts[index];
              final isSelected = _selectedFont == font;
              return ChoiceChip(
                label: Text(font, style: TextStyle(fontFamily: font)),
                selected: isSelected,
                onSelected: (val) {
                  if (val) setState(() => _selectedFont = font);
                },
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildFooter(ColorScheme colorScheme) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        border: Border(top: BorderSide(color: colorScheme.outlineVariant)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          TextButton(onPressed: () => Get.back(), child: const Text('Cancel')),
          const SizedBox(width: 12),
          AppButton.primary(
            label: 'Adopt & Sign',
            width: 140,
            height: 44,
            onPressed: _handleAdopt,
          ),
        ],
      ),
    );
  }

  Future<void> _handleAdopt() async {
    Uint8List? signatureBytes;

    if (_tabController.index == 0) {
      // 1. SELECT STYLE: Capture the RepaintBoundary
      try {
        final RenderRepaintBoundary? boundary =
            _previewKey.currentContext?.findRenderObject()
                as RenderRepaintBoundary?;
        if (boundary != null) {
          final image = await boundary.toImage(pixelRatio: 3.0);
          final byteData = await image.toByteData(format: ImageByteFormat.png);
          signatureBytes = byteData?.buffer.asUint8List();
        }
      } catch (e) {
        debugPrint('Error capturing style signature: $e');
      }
    } else if (_tabController.index == 1) {
      // 2. DRAW: Get bytes from controller
      if (_signatureController.isNotEmpty) {
        signatureBytes = await _signatureController.toPngBytes();
      }
    }

    // Trim whitespace before returning
    if (signatureBytes != null) {
      final trimmed = await SignatureUtils.trimWhitespace(signatureBytes);
      if (trimmed != null) signatureBytes = trimmed;
    }

    widget.onAdopt(
      signatureBytes,
      _nameController.text,
      _initialsController.text,
    );
    Get.back();
  }
}
