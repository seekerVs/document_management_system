import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:pdfx/pdfx.dart';
import '../../../../../Commons/Styles/style.dart';
import '../../../../../Commons/Widgets/app_button.dart';
import '../../../../../Utils/Routes/main_routes.dart';
import '../../../../../Utils/Services/pdf_renderer_service.dart';
import '../../../../../Commons/Widgets/app_pdf_viewer.dart';
import '../Controller/signature_placement_controller.dart';
import '../Controller/signature_request_controller.dart';
import '../Widget/field_toolbar.dart';
import '../Widget/signature_field_overlay.dart';
import '../Widget/signer_switcher.dart';

class SignaturePlacementView extends StatefulWidget {
  const SignaturePlacementView({super.key});

  @override
  State<SignaturePlacementView> createState() => _SignaturePlacementViewState();
}

class _SignaturePlacementViewState extends State<SignaturePlacementView> {
  final SignaturePlacementController _controller =
      Get.find<SignaturePlacementController>();
  final SignatureRequestController _requestController =
      Get.find<SignatureRequestController>();

  PdfDocument? _document;
  String? _docId;
  Size _defaultPageSize = const Size(600, 800);
  int _currentPageIndex = 0;

  @override
  void initState() {
    super.initState();
    _initDocument();
  }

  @override
  void dispose() {
    _document?.close();
    if (_docId != null) PdfRendererService.clearCache(docId: _docId);
    super.dispose();
  }

  Future<void> _initDocument() async {
    final obj = _requestController.selectedDocument.value;
    if (obj != null) {
      _docId = obj.file.path;
      try {
        final doc = await PdfDocument.openFile(obj.file.path);
        final firstPage = await doc.getPage(1);
        _defaultPageSize = Size(firstPage.width, firstPage.height);
        await firstPage.close();
        if (mounted) setState(() => _document = doc);
      } catch (e) {
        debugPrint('Error opening PDF: $e');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final docObj = _requestController.selectedDocument.value;
    final cs = Theme.of(context).colorScheme;
    final screenW = MediaQuery.of(context).size.width;

    // Standard mobile width calculation
    final availableW = (screenW - 32).clamp(0.0, 600.0);

    return PopScope(
      onPopInvokedWithResult: (didPop, result) {},
      child: Scaffold(
        backgroundColor: cs.surface,
        appBar: _buildAppBar(docObj?.name ?? 'Place Fields'),
        body: GestureDetector(
          onTap: _controller.deselectField,
          child: Column(
            children: [
              Obx(() {
                return AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  height: _controller.selectedFieldId.value == null ? null : 0,
                  child: SingleChildScrollView(
                    physics: const NeverScrollableScrollPhysics(),
                    child: SignerSwitcher(controller: _controller),
                  ),
                );
              }),
              Expanded(
                child: Container(
                  color: const Color(0xFFF5F5F5),
                  child: _document == null
                      ? const Center(child: CircularProgressIndicator())
                      : AppPdfViewer(
                          document: _document!,
                          docId: _docId ?? 'default',
                          maxWidth: availableW,
                          onScroll: (offset, _) =>
                              _handleScrollUpdate(offset, availableW),
                          pageOverlayBuilder:
                              (ctx, pageIndex, displayW, displayH) {
                                return _buildPageOverlay(
                                  ctx,
                                  pageIndex,
                                  displayW,
                                  displayH,
                                );
                              },
                          fieldBuilder: (ctx, pageIndex, displayW, displayH) {
                            return _buildPageFields(
                              ctx,
                              pageIndex,
                              displayW,
                              displayH,
                            );
                          },
                        ),
                ),
              ),
              _buildBottomArea(),
            ],
          ),
        ),
      ),
    );
  }

  void _handleScrollUpdate(double offset, double displayW) {
    final displayH =
        displayW * (_defaultPageSize.height / _defaultPageSize.width);
    final pageStride = displayH + 12;

    final newIndex = (offset / pageStride).round().clamp(
      0,
      (_document?.pagesCount ?? 1) - 1,
    );

    if (newIndex != _currentPageIndex) {
      _currentPageIndex = newIndex;
    }
  }

  PreferredSizeWidget _buildAppBar(String title) {
    return PreferredSize(
      preferredSize: const Size.fromHeight(kToolbarHeight),
      child: Obx(() {
        final cs = Theme.of(context).colorScheme;
        final isFieldSelected = _controller.selectedFieldId.value != null;

        return AppBar(
          key: const ValueKey('normal_appbar'),
          elevation: 0,
          backgroundColor: cs.surface,
          title: Text(
            title,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(color: cs.onSurface, fontSize: 16),
          ),
          leading: IconButton(
            icon: Icon(
              isFieldSelected ? Icons.close : Icons.chevron_left,
              color: cs.onSurface,
            ),
            onPressed: isFieldSelected ? _controller.deselectField : Get.back,
          ),
        );
      }),
    );
  }

  Widget _buildBottomArea() {
    final cs = Theme.of(context).colorScheme;
    return Container(
      decoration: BoxDecoration(
        color: cs.surface,
        boxShadow: [
          BoxShadow(
            color: cs.shadow.withValues(alpha: 0.08),
            blurRadius: 12,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          SignatureFieldToolbar(
            controller: _controller,
            onAddField: (type) {
              final screenW = MediaQuery.of(context).size.width;
              final displayW = (screenW - 32).clamp(0.0, 600.0);
              final displayH =
                  displayW * (_defaultPageSize.height / _defaultPageSize.width);

              _controller.addField(type, displayW, displayH, _currentPageIndex);
            },
            onShowReassign: _showReassignMenu,
            onShowChangeType: () {}, // Handled internally
          ),
          Obx(() {
            final isFieldSelected = _controller.selectedFieldId.value != null;

            return Padding(
              padding: EdgeInsets.fromLTRB(
                16,
                0,
                16,
                MediaQuery.of(context).padding.bottom + 16,
              ),
              child: AppButton.primary(
                label: 'Next',
                onPressed: isFieldSelected
                    ? null
                    : () => Get.toNamed(MainRoutes.requestReview),
              ),
            );
          }),
        ],
      ),
    );
  }

  void _showReassignMenu() {
    Get.bottomSheet(
      Container(
        padding: const EdgeInsets.fromLTRB(24, 12, 24, 32),
        decoration: AppStyle.bottomSheetDecoration(context),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 40,
                height: 4,
                decoration: AppStyle.bottomSheetHandleOf(context),
              ),
            ),
            const SizedBox(height: 20),
            Text(
              'Reassign Field To',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 12),
            ..._controller.activeSigners.asMap().entries.map((entry) {
              return ListTile(
                contentPadding: EdgeInsets.zero,
                leading: CircleAvatar(
                  backgroundColor: AppStyle.signerColor(context, entry.key),
                  radius: 12,
                ),
                title: Text(
                  entry.value.signerName,
                  style: Theme.of(context).textTheme.titleSmall,
                ),
                subtitle: Text(
                  entry.value.signerEmail,
                  style: Theme.of(context).textTheme.bodySmall,
                ),
                onTap: () {
                  _controller.reassignField(
                    _controller.selectedFieldId.value!,
                    entry.key,
                  );
                  Get.back();
                },
              );
            }),
          ],
        ),
      ),
    );
  }

  Widget _buildPageOverlay(
    BuildContext context,
    int pageIndex,
    double displayW,
    double displayH,
  ) {
    return Positioned.fill(
      child: DragTarget<String>(
        onWillAcceptWithDetails: (details) => true,
        onAcceptWithDetails: (details) {
          final RenderBox box = context.findRenderObject() as RenderBox;
          final Offset localOffset = box.globalToLocal(details.offset);

          // Normalize the position relative to this page
          // Since we now use pointerDragAnchorStrategy in the overlay,
          // localOffset is already adjusted to center the field under the finger.
          final double normX = (localOffset.dx / displayW).clamp(0.0, 1.0);
          final double normY = (localOffset.dy / displayH).clamp(0.0, 1.0);

          _controller.moveFieldToPage(details.data, pageIndex, normX, normY);
        },
        builder: (context, candidateData, rejectedData) =>
            const SizedBox.expand(),
      ),
    );
  }

  Widget _buildPageFields(
    BuildContext context,
    int pageIndex,
    double displayW,
    double displayH,
  ) {
    return Obx(() {
      final fields = _controller.allFields
          .where((e) => e.field.page == pageIndex)
          .toList();

      return Stack(
        children: fields.map((entry) {
          return SignatureFieldOverlay(
            key: ValueKey(entry.field.fieldId),
            field: entry.field,
            signer: entry.signer,
            color: AppStyle.signerColor(context, entry.signerIndex),
            canvasWidth: displayW,
            canvasHeight: displayH,
            isSelected:
                _controller.selectedFieldId.value == entry.field.fieldId,
            canDrag: true,
            onTap: () => _controller.selectField(entry.field.fieldId),
            onDragStarted: () => _controller.selectField(entry.field.fieldId),
          );
        }).toList(),
      );
    });
  }
}
