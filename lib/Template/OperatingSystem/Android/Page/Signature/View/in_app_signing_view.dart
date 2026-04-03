import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:pdfx/pdfx.dart';
import 'package:http/http.dart' as http;
import '../../../../../Commons/Widgets/app_button.dart';
import '../../../../../Utils/Constant/colors.dart';
import '../../../../../Utils/Constant/enum.dart';
import '../Controller/in_app_signing_controller.dart';
import '../Model/signature_field_model.dart';

class InAppSigningView extends StatefulWidget {
  const InAppSigningView({super.key});

  @override
  State<InAppSigningView> createState() => _InAppSigningViewState();
}

class _InAppSigningViewState extends State<InAppSigningView> {
  final InAppSigningController _controller = Get.find<InAppSigningController>();
  PdfDocument? _document;
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _fetchDocument();
  }

  Future<void> _fetchDocument() async {
    try {
      final response = await http.get(
        Uri.parse(_controller.request.documentUrl),
      );
      if (response.statusCode == 200) {
        final doc = await PdfDocument.openData(response.bodyBytes);
        setState(() => _document = doc);
      }
    } catch (e) {
      debugPrint('Error fetching PDF: $e');
    }
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final request = _controller.request;
    final signer = _controller.signer;

    return Scaffold(
      backgroundColor: AppColors.white,
      appBar: AppBar(
        title: Text(
          request.documentName,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        leading: IconButton(
          icon: const Icon(Icons.chevron_left),
          onPressed: Get.back,
        ),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(32),
          child: Container(
            width: double.infinity,
            color: AppColors.background,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
            child: Text(
              'Signing as ${signer.signerName}',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: AppColors.blue,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ),
      ),
      body: Column(
        children: [
          Expanded(
            child: _document == null
                ? const Center(child: CircularProgressIndicator())
                : InteractiveViewer(
                    minScale: 0.5,
                    maxScale: 3.0,
                    child: ListView.builder(
                      controller: _scrollController,
                      padding: const EdgeInsets.symmetric(
                        vertical: 24,
                        horizontal: 16,
                      ),
                      itemCount: _document!.pagesCount,
                      itemBuilder: (context, index) {
                        return _PdfSigningPage(
                          document: _document!,
                          pageIndex: index + 1,
                          controller: _controller,
                        );
                      },
                    ),
                  ),
          ),
          _BottomBar(controller: _controller),
        ],
      ),
    );
  }
}

class _PdfSigningPage extends StatefulWidget {
  final PdfDocument document;
  final int pageIndex;
  final InAppSigningController controller;

  const _PdfSigningPage({
    required this.document,
    required this.pageIndex,
    required this.controller,
  });

  @override
  State<_PdfSigningPage> createState() => _PdfSigningPageState();
}

class _PdfSigningPageState extends State<_PdfSigningPage> {
  PdfPageImage? _image;

  @override
  void initState() {
    super.initState();
    _renderPage();
  }

  Future<void> _renderPage() async {
    final page = await widget.document.getPage(widget.pageIndex);
    final img = await page.render(
      width: page.width * 2,
      height: page.height * 2,
    );
    if (mounted) setState(() => _image = img);
    await page.close();
  }

  @override
  Widget build(BuildContext context) {
    if (_image == null) {
      return const SizedBox(
        height: 600,
        child: Center(child: CircularProgressIndicator()),
      );
    }

    final double pdfW = (_image!.width ?? 1).toDouble();
    final double pdfH = (_image!.height ?? 1).toDouble();

    return LayoutBuilder(
      builder: (context, constraints) {
        final double displayW = constraints.maxWidth;
        final double displayH = displayW * (pdfH / pdfW);

        return Container(
          margin: const EdgeInsets.only(bottom: 24),
          width: displayW,
          height: displayH,
          decoration: const BoxDecoration(
            color: Colors.white,
            boxShadow: [
              BoxShadow(
                color: Colors.black12,
                blurRadius: 8,
                offset: Offset(0, 4),
              ),
            ],
          ),
          child: Obx(() {
            final fields = widget.controller.fields
                .where((f) => f.page == widget.pageIndex - 1)
                .toList();

            return Stack(
              children: [
                Positioned.fill(
                  child: Image.memory(_image!.bytes, fit: BoxFit.fill),
                ),
                ...fields.map(
                  (f) => _SigningFieldOverlay(
                    key: ValueKey(f.fieldId),
                    field: f,
                    controller: widget.controller,
                    displayW: displayW,
                    displayH: displayH,
                  ),
                ),
              ],
            );
          }),
        );
      },
    );
  }
}

class _SigningFieldOverlay extends StatelessWidget {
  final SignatureFieldModel field;
  final InAppSigningController controller;
  final double displayW;
  final double displayH;

  const _SigningFieldOverlay({
    super.key,
    required this.field,
    required this.controller,
    required this.displayW,
    required this.displayH,
  });

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final isFilled = controller.isFieldFilled(field.fieldId);
      final color = controller.fieldColor(field.fieldId);
      final imageBytes = controller.signatureImages[field.fieldId];
      final textValue = controller.fieldValues[field.fieldId];

      return Positioned(
        left: field.x,
        top: field.y,
        child: GestureDetector(
          onTap: () => controller.onFieldTap(field),
          child: Container(
            width: field.width,
            height: field.height,
            decoration: BoxDecoration(
              color: color.withAlpha(isFilled ? 20 : 30),
              border: Border.all(color: color, width: 1.5),
              borderRadius: BorderRadius.circular(6),
            ),
            child: isFilled
                ? _FilledFieldContent(
                    field: field,
                    imageBytes: imageBytes,
                    textValue: textValue,
                    color: color,
                  )
                : _EmptyFieldContent(field: field, color: color),
          ),
        ),
      );
    });
  }
}

class _EmptyFieldContent extends StatelessWidget {
  final SignatureFieldModel field;
  final Color color;
  const _EmptyFieldContent({required this.field, required this.color});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(_icon, color: color, size: 14),
        const SizedBox(width: 4),
        const Text('*', style: TextStyle(color: Colors.red, fontSize: 14)),
      ],
    );
  }

  IconData get _icon {
    switch (field.type) {
      case SignatureFieldType.signature:
        return Icons.draw_outlined;
      case SignatureFieldType.initials:
        return Icons.text_fields_outlined;
      case SignatureFieldType.dateSigned:
        return Icons.calendar_today_outlined;
      case SignatureFieldType.textbox:
        return Icons.text_snippet_outlined;
    }
  }
}

class _FilledFieldContent extends StatelessWidget {
  final SignatureFieldModel field;
  final Uint8List? imageBytes;
  final String? textValue;
  final Color color;

  const _FilledFieldContent({
    required this.field,
    required this.imageBytes,
    required this.textValue,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    if (imageBytes != null) {
      return Padding(
        padding: const EdgeInsets.all(4),
        child: Image.memory(imageBytes!, fit: BoxFit.contain),
      );
    }
    return Center(
      child: Text(
        textValue ?? '',
        style: TextStyle(
          fontSize: field.type == SignatureFieldType.dateSigned ? 10 : 12,
          color: AppColors.textPrimary,
          fontWeight: FontWeight.w500,
        ),
        maxLines: 2,
        overflow: TextOverflow.ellipsis,
        textAlign: TextAlign.center,
      ),
    );
  }
}

class _BottomBar extends StatelessWidget {
  final InAppSigningController controller;
  const _BottomBar({required this.controller});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.fromLTRB(
        16,
        12,
        16,
        MediaQuery.of(context).padding.bottom + 16,
      ),
      decoration: const BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Color(0x14000000),
            blurRadius: 8,
            offset: Offset(0, -2),
          ),
        ],
      ),
      child: Obx(() {
        final filled = controller.fields
            .where((f) => controller.isFieldFilled(f.fieldId))
            .length;
        final total = controller.fields.length;

        return Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  '$filled of $total fields completed',
                  style: Theme.of(context).textTheme.bodySmall,
                ),
                if (filled == total)
                  const Icon(
                    Icons.check_circle,
                    color: AppColors.green,
                    size: 16,
                  ),
              ],
            ),
            const SizedBox(height: 10),
            AppButton.primary(
              label: 'Confirm & Sign',
              onPressed: controller.allFieldsFilled
                  ? controller.confirmSigning
                  : null,
            ),
            const SizedBox(height: 8),
            AppButton.outlined(
              label: 'Decline to Sign',
              onPressed: controller.declineSigning,
            ),
          ],
        );
      }),
    );
  }
}
