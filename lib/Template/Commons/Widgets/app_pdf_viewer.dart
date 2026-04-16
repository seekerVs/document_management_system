import 'package:flutter/material.dart';
import 'package:pdfx/pdfx.dart';
import '../../Utils/Services/pdf_renderer_service.dart';

/// A standardized, high-performance PDF viewer widget for the application.
/// Handles rendering, zooming, and interaction consistently across all modules.
class AppPdfViewer extends StatefulWidget {
  final PdfDocument document;
  final String docId;
  final Widget Function(
    BuildContext context,
    int pageIndex,
    double displayW,
    double displayH,
  )
  fieldBuilder;
  final Widget Function(
    BuildContext context,
    int pageIndex,
    double displayW,
    double displayH,
  )?
  pageOverlayBuilder;
  final EdgeInsets padding;
  final double maxWidth;
  final Function(double scrollOffset, double pageHeight)? onScroll;

  const AppPdfViewer({
    super.key,
    required this.document,
    required this.docId,
    required this.fieldBuilder,
    this.pageOverlayBuilder,
    this.padding = const EdgeInsets.all(16.0),
    this.maxWidth = 600.0,
    this.onScroll,
  });

  @override
  State<AppPdfViewer> createState() => _AppPdfViewerState();
}

class _AppPdfViewerState extends State<AppPdfViewer>
    with TickerProviderStateMixin {
  late TransformationController _transformationController;
  late AnimationController _animationController;
  Animation<Matrix4>? _animation;
  final ScrollController _scrollController = ScrollController();
  double _currentScale = 1.0;

  @override
  void initState() {
    super.initState();
    _transformationController = TransformationController();
    _animationController =
        AnimationController(
          vsync: this,
          duration: const Duration(milliseconds: 300),
        )..addListener(() {
          if (_animation != null) {
            _transformationController.value = _animation!.value;
          }
        });

    if (widget.onScroll != null) {
      _scrollController.addListener(_handleScroll);
    }
  }

  @override
  void dispose() {
    _transformationController.dispose();
    _animationController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _handleScroll() {
    if (widget.onScroll != null && _scrollController.hasClients) {
      widget.onScroll!(_scrollController.offset, 0.0); // Simplified for now
    }
  }

  void _onDoubleTapDown(TapDownDetails details) {
    final double currentScale = _transformationController.value
        .getMaxScaleOnAxis();
    const double targetScale = 2.5;

    final Matrix4 endMatrix;

    if (currentScale > 1.1) {
      endMatrix = Matrix4.identity();
    } else {
      final Offset localOffset = details.localPosition;
      final double x = -localOffset.dx * (targetScale - 1);
      final double y = -localOffset.dy * (targetScale - 1);

      endMatrix = Matrix4.translationValues(x, y, 0.0)
        ..scaleByDouble(targetScale, targetScale, 1.0, 1.0);
    }

    _animation =
        Matrix4Tween(
          begin: _transformationController.value,
          end: endMatrix,
        ).animate(
          CurvedAnimation(
            parent: _animationController,
            curve: Curves.easeOutCubic,
          ),
        );

    _animationController.forward(from: 0);
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onDoubleTapDown: _onDoubleTapDown,
      onDoubleTap: () {}, // Required for gesture detection
      child: InteractiveViewer(
        transformationController: _transformationController,
        minScale: 1.0,
        maxScale: 4.0,
        boundaryMargin: const EdgeInsets.symmetric(vertical: 200),
        onInteractionUpdate: (details) {
          setState(() {
            _currentScale = _transformationController.value.getMaxScaleOnAxis();
          });
        },
        child: ListView.builder(
          controller: _scrollController,
          physics: _currentScale > 1.0
              ? const NeverScrollableScrollPhysics()
              : const BouncingScrollPhysics(),
          padding: widget.padding,
          itemCount: widget.document.pagesCount,
          itemBuilder: (context, index) {
            return Center(
              child: _AppPdfPage(
                document: widget.document,
                docId: widget.docId,
                pageIndex: index + 1,
                maxWidth: widget.maxWidth,
                fieldBuilder: widget.fieldBuilder,
                pageOverlayBuilder: widget.pageOverlayBuilder,
              ),
            );
          },
        ),
      ),
    );
  }
}

class _AppPdfPage extends StatefulWidget {
  final PdfDocument document;
  final String docId;
  final int pageIndex;
  final double maxWidth;
  final Widget Function(
    BuildContext context,
    int pageIndex,
    double displayW,
    double displayH,
  )
  fieldBuilder;
  final Widget Function(
    BuildContext context,
    int pageIndex,
    double displayW,
    double displayH,
  )?
  pageOverlayBuilder;

  const _AppPdfPage({
    required this.document,
    required this.docId,
    required this.pageIndex,
    required this.maxWidth,
    required this.fieldBuilder,
    this.pageOverlayBuilder,
  });

  @override
  State<_AppPdfPage> createState() => _AppPdfPageState();
}

class _AppPdfPageState extends State<_AppPdfPage> {
  PdfPageImage? _image;
  bool _isLoading = true;
  bool _hasError = false;

  @override
  void initState() {
    super.initState();
    _renderPage();
  }

  Future<void> _renderPage() async {
    if (!mounted) return;
    setState(() {
      _isLoading = true;
      _hasError = false;
    });

    try {
      final img = await PdfRendererService.renderPage(
        document: widget.document,
        docId: widget.docId,
        pageIndex: widget.pageIndex,
      );

      if (mounted) {
        setState(() {
          _image = img;
          _isLoading = false;
          _hasError = img == null;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
          _hasError = true;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_hasError) {
      return Container(
        height: 200,
        margin: const EdgeInsets.only(bottom: 12),
        width: widget.maxWidth,
        decoration: BoxDecoration(
          color: Colors.grey[100],
          borderRadius: BorderRadius.circular(8),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline, color: Colors.red, size: 32),
            const SizedBox(height: 8),
            const Text('Failed to load page'),
            TextButton(onPressed: _renderPage, child: const Text('Retry')),
          ],
        ),
      );
    }

    if (_image == null || _isLoading) {
      return Container(
        height: 600,
        margin: const EdgeInsets.only(bottom: 12),
        width: widget.maxWidth,
        decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.05),
              blurRadius: 10,
              offset: const Offset(0, 5),
            ),
          ],
        ),
        child: const Center(child: CircularProgressIndicator()),
      );
    }

    final double pdfW = (_image!.width ?? 1).toDouble();
    final double pdfH = (_image!.height ?? 1).toDouble();

    return LayoutBuilder(
      builder: (context, constraints) {
        final double displayW = constraints.maxWidth.clamp(
          0.0,
          widget.maxWidth,
        );
        final double displayH = displayW * (pdfH / pdfW);

        return Container(
          margin: const EdgeInsets.only(bottom: 12),
          width: displayW,
          height: displayH,
          decoration: BoxDecoration(
            color: Colors.white,
            border: Border.all(
              color: Colors.black.withValues(alpha: 0.05),
              width: 0.5,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.08),
                blurRadius: 16,
                offset: const Offset(0, 8),
              ),
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.04),
                blurRadius: 4,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Stack(
            children: [
              Positioned.fill(
                child: Image.memory(_image!.bytes, fit: BoxFit.fill),
              ),
              if (widget.pageOverlayBuilder != null)
                widget.pageOverlayBuilder!(
                  context,
                  widget.pageIndex - 1,
                  displayW,
                  displayH,
                ),
              widget.fieldBuilder(
                context,
                widget.pageIndex - 1,
                displayW,
                displayH,
              ),
            ],
          ),
        );
      },
    );
  }
}
