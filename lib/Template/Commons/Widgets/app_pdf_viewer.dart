import 'package:flutter/material.dart';
import 'package:pdfrx/pdfrx.dart';

class AppPdfViewer extends StatefulWidget {
  final List<PdfDocument> documents;
  final List<String> docIds;
  final Widget Function(
    BuildContext context,
    String documentId,
    int pageIndex,
    double displayW,
    double displayH,
  )
  fieldBuilder;
  final Widget Function(
    BuildContext context,
    String documentId,
    int pageIndex,
    double displayW,
    double displayH,
  )?
  pageOverlayBuilder;
  final EdgeInsets padding;
  final double maxWidth;
  final Function(double scrollOffset, double pageHeight)? onScroll;
  final Function(
    String fieldId,
    String documentId,
    int pageIndex,
    double x,
    double y,
  )?
  onFieldMove;
  final Function(String documentId, int pageIndex)? onPageChanged;

  const AppPdfViewer({
    super.key,
    required this.documents,
    required this.docIds,
    required this.fieldBuilder,
    this.pageOverlayBuilder,
    this.padding = const EdgeInsets.all(8.0),
    this.maxWidth = 600.0,
    this.onScroll,
    this.onFieldMove,
    this.onPageChanged,
  });

  @override
  State<AppPdfViewer> createState() => _AppPdfViewerState();
}

class _AppPdfViewerState extends State<AppPdfViewer> {
  final ScrollController _mainScrollController = ScrollController();
  final TransformationController _transformationController =
      TransformationController();
  double _scale = 1.0;

  final Map<int, Map<int, double>> _pageHeights = {};
  String? _lastDocId;
  int? _lastPageIndex;

  @override
  void initState() {
    super.initState();
    _mainScrollController.addListener(_handleScroll);
    _transformationController.addListener(() {
      setState(() {
        _scale = _transformationController.value.row0[0];
      });
    });

    // Initialize page tracking on first frame
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) _handleScroll();
    });

  }

  @override
  void dispose() {
    _mainScrollController.dispose();
    _transformationController.dispose();
    super.dispose();
  }

  void _handleScroll() {
    if (_mainScrollController.hasClients) {
      if (widget.onScroll != null) {
        widget.onScroll!(_mainScrollController.offset, 0.0);
      }

      // Refined page tracking logic
      if (widget.onPageChanged != null) {
        final centerOffset =
            _mainScrollController.offset +
            (_mainScrollController.position.viewportDimension / 2);
        
        double currentTotalHeight = widget.padding.top;
        String? activeDocId;
        int activePageIndex = 0;
        bool found = false;

        for (int i = 0; i < widget.documents.length; i++) {
          final docId = widget.docIds[i];
          final docBody = widget.documents[i];
          final docHeights = _pageHeights[i] ?? {};

          for (int p = 0; p < docBody.pages.length; p++) {
            // Use cached height or estimate (points -> pixels)
            // Note: Horizontal padding is 4.0 on each side (total 8.0)
            final actualPageWidth = widget.maxWidth - 8.0;
            final pHeight = docHeights[p] ??
                (docBody.pages[p].height * (actualPageWidth / docBody.pages[p].width)) +
                8.0; // include vertical padding

            if (centerOffset >= currentTotalHeight &&
                centerOffset < currentTotalHeight + pHeight) {
              activeDocId = docId;
              activePageIndex = p;
              found = true;
              break;
            }
            currentTotalHeight += pHeight;
          }
          if (found) break;
        }

        if (found &&
            (activeDocId != _lastDocId || activePageIndex != _lastPageIndex)) {
          _lastDocId = activeDocId;
          _lastPageIndex = activePageIndex;
          widget.onPageChanged!(activeDocId!, activePageIndex);
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final viewerBg = Theme.of(context).brightness == Brightness.light
        ? const Color(
            0xFFDDE4ED,
          ) // Slightly darker than standard background for contrast
        : const Color(0xFF101820); // Deep dark background

    return Container(
      color: viewerBg,
      child: InteractiveViewer(
        transformationController: _transformationController,
        minScale: 1.0,
        maxScale: 4.0,
        panEnabled:
            _scale > 1.0, // Disable panning at 1.0 to allow normal scrolling
        child: Center(
          child: ConstrainedBox(
            constraints: BoxConstraints(maxWidth: widget.maxWidth),
            child: CustomScrollView(
              controller: _mainScrollController,
              physics: _scale > 1.0
                  ? const NeverScrollableScrollPhysics()
                  : const ClampingScrollPhysics(),
              slivers: [
                SliverPadding(
                  padding: EdgeInsets.only(top: widget.padding.top),
                ),
                ...List.generate(widget.documents.length, (docIndex) {
                  final doc = widget.documents[docIndex];
                  final docId = widget.docIds[docIndex];

                  return SliverList(
                    delegate: SliverChildBuilderDelegate((context, pageIndex) {
                      return Padding(
                        padding: const EdgeInsets.symmetric(
                          vertical: 4.0,
                          horizontal: 4.0, // Reduced from 16.0
                        ),
                        child: Container(
                          decoration: BoxDecoration(
                            color: Colors.white, // Keep page white
                            borderRadius: BorderRadius.circular(2),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withValues(alpha: 0.15),
                                blurRadius: 10,
                                offset: const Offset(0, 4),
                              ),
                            ],
                            border: Border.all(
                              color: cs.outlineVariant.withValues(alpha: 0.5),
                              width: 0.5,
                            ),
                          ),
                          child: PdfPageView(
                            document: doc,
                            pageNumber: pageIndex + 1,
                            decorationBuilder:
                                (context, pageSize, page, pageImage) {
                                  return DragTarget<String>(
                                    onWillAcceptWithDetails: (details) => true,
                                    onAcceptWithDetails: (details) {
                                      if (widget.onFieldMove == null) return;

                                      // Transform global position to local page coordinates
                                      final BoxBox =
                                          context.findRenderObject()
                                              as RenderBox;
                                      final localOffset = BoxBox.globalToLocal(
                                        details.offset,
                                      );

                                      // Normalize coordinates (0.0 to 1.0)
                                      final x =
                                          (localOffset.dx / pageSize.width)
                                              .clamp(0.0, 1.0);
                                      final y =
                                          (localOffset.dy / pageSize.height)
                                              .clamp(0.0, 1.0);

                                      widget.onFieldMove!(
                                        details.data,
                                        docId,
                                        pageIndex,
                                        x,
                                        y,
                                      );
                                    },
                                    builder: (context, candidateData, rejectedData) {
                                      // Cache height for scroll-based page tracking
                                      final totalHeight = pageSize.height + 8.0; // height + 2 * vertical padding
                                      final currentMap = _pageHeights[docIndex] ?? {};
                                      if (currentMap[pageIndex] != totalHeight) {
                                        currentMap[pageIndex] = totalHeight;
                                        _pageHeights[docIndex] = currentMap;
                                      }

                                      return SizedBox.fromSize(
                                        size: pageSize,
                                        child: Stack(
                                          children: [
                                            ClipRRect(
                                              borderRadius:
                                                  BorderRadius.circular(2),
                                              child: pageImage,
                                            ),
                                            if (widget.pageOverlayBuilder !=
                                                null)
                                              Positioned.fill(
                                                child: widget.pageOverlayBuilder!(
                                                  context,
                                                  docId,
                                                  pageIndex,
                                                  pageSize.width,
                                                  pageSize.height,
                                                ),
                                              ),
                                            Positioned.fill(
                                              child: widget.fieldBuilder(
                                                context,
                                                docId,
                                                pageIndex,
                                                pageSize.width,
                                                pageSize.height,
                                              ),
                                            ),
                                          ],
                                        ),
                                      );
                                        },
                                  );
                                },
                          ),
                        ),
                      );
                    }, childCount: doc.pages.length),
                  );
                }),
                SliverPadding(
                  padding: EdgeInsets.only(bottom: widget.padding.bottom + 100),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
