import 'package:flutter/material.dart';
import 'package:pdfx/pdfx.dart';

class PdfViewer extends StatefulWidget {
  final String localPath;
  final void Function(int totalPages)? onRender;
  final void Function(int currentPage, int totalPages)? onPageChanged;
  final void Function(String error)? onError;

  const PdfViewer({
    super.key,
    required this.localPath,
    this.onRender,
    this.onPageChanged,
    this.onError,
  });

  @override
  State<PdfViewer> createState() => _PdfViewerState();
}

class _PdfViewerState extends State<PdfViewer> {
  late PdfController _pdfController;
  bool _initialized = false;

  @override
  void initState() {
    super.initState();
    _initController();
  }

  void _initController() async {
    try {
      _pdfController = PdfController(
        document: PdfDocument.openFile(widget.localPath),
      );
      final doc = await _pdfController.document;
      widget.onRender?.call(doc.pagesCount);
      setState(() => _initialized = true);
    } catch (e) {
      widget.onError?.call(e.toString());
    }
  }

  @override
  void dispose() {
    if (_initialized) _pdfController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (!_initialized) {
      return const Center(child: CircularProgressIndicator());
    }

    return PdfView(
      controller: _pdfController,
      onPageChanged: (page) {
        widget.onPageChanged?.call(page, _pdfController.pagesCount ?? 0);
      },
      scrollDirection: Axis.vertical,
      builders: PdfViewBuilders<DefaultBuilderOptions>(
        options: const DefaultBuilderOptions(),
        documentLoaderBuilder: (_) => const Center(child: CircularProgressIndicator()),
        pageLoaderBuilder: (_) => const Center(child: CircularProgressIndicator()),
        errorBuilder: (_, error) => Center(child: Text(error.toString())),
      ),
    );
  }
}
