import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:pdfx/pdfx.dart';
import 'package:http/http.dart' as http;
import '../../../../../Commons/Widgets/app_button.dart';
import '../../../../../Utils/Constant/enum.dart';
import '../Controller/in_app_signing_controller.dart';
import '../Model/signature_field_model.dart';
import '../Widget/signature_field_overlay.dart';
import '../../../../../Utils/Services/supabase_service.dart';

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
      String url = _controller.request.documentUrl;

      // If documentUrl is a storage path (no host specified), get a signed URL
      if (!url.startsWith('http')) {
        url = await SupabaseService.getSignedUrl(url);
      }

      final response = await http.get(Uri.parse(url));
      if (response.statusCode == 200) {
        final doc = await PdfDocument.openData(response.bodyBytes);
        if (mounted) setState(() => _document = doc);
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
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        title: Text(
          request.documentName,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        leading: IconButton(
          icon: const Icon(Icons.close),
          onPressed: () => Get.offAllNamed('/dashboard'),
        ),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(40),
          child: Column(
            children: [
              Obx(
                () => LinearProgressIndicator(
                  value: _controller.progress,
                  backgroundColor: Theme.of(
                    context,
                  ).colorScheme.surfaceContainer,
                  valueColor: AlwaysStoppedAnimation<Color>(
                    Theme.of(context).colorScheme.primary,
                  ),
                  minHeight: 3,
                ),
              ),
              Container(
                width: double.infinity,
                color: Theme.of(context).colorScheme.surfaceContainer,
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 8,
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.person_outline,
                      size: 14,
                      color: Theme.of(context).colorScheme.primary,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      'Now Signing: ${signer.signerName}',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: Theme.of(context).colorScheme.primary,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
            ],
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

        final fields = widget.controller.fields
            .where((f) => f.page == widget.pageIndex - 1)
            .toList();

        return Container(
          margin: const EdgeInsets.only(bottom: 24),
          width: displayW,
          height: displayH,
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.surface,
            boxShadow: const [
              BoxShadow(
                color: Colors.black12,
                blurRadius: 8,
                offset: Offset(0, 4),
              ),
            ],
          ),
          child: Stack(
            children: [
              Positioned.fill(
                child: Image.memory(_image!.bytes, fit: BoxFit.fill),
              ),
              Obx(() => Stack(
                children: fields.map(
                  (f) => SignatureFieldOverlay(
                    key: ValueKey(f.fieldId),
                    field: f,
                    signer: widget.controller.signer,
                    color: widget.controller.fieldColor(f.fieldId),
                    canvasWidth: displayW,
                    canvasHeight: displayH,
                    onTap: () => widget.controller.onFieldTap(f),
                    child: widget.controller.isFieldFilled(f.fieldId)
                        ? _FilledFieldContent(
                            field: f,
                            imageBytes:
                                widget.controller.signatureImages[f.fieldId],
                            textValue: widget.controller.fieldValues[f.fieldId],
                            color: widget.controller.fieldColor(f.fieldId),
                          )
                        : null,
                  ),
                ).toList(),
              )),
            ],
          ),
        );
      },
    );
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
        padding: const EdgeInsets.all(2.0),
        child: Image.memory(
          imageBytes!,
          fit: BoxFit.contain,
        ),
      );
    }
    return Center(
      child: Text(
        textValue ?? '',
        style: TextStyle(
          fontSize: field.type == SignatureFieldType.dateSigned ? 10 : 12,
          color: Colors.black87,
          fontWeight: FontWeight.w600,
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
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceContainer,
        boxShadow: const [
          BoxShadow(
            color: Color(0x14000000),
            blurRadius: 8,
            offset: Offset(0, -2),
          ),
        ],
      ),
      child: Obx(() {
        return Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            AppButton.primary(
              label: 'Confirm & Sign',
              onPressed: controller.allFieldsFilled
                  ? controller.confirmSigning
                  : null,
            ),
          ],
        );
      }),
    );
  }
}
