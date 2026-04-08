import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:pdfx/pdfx.dart';
import '../../../../../Commons/Styles/style.dart';
import '../../../../../Commons/Widgets/app_button.dart';
import '../../../../../Utils/Routes/main_routes.dart';
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
  Size _defaultPageSize = const Size(600, 800);
  final ScrollController _scrollController = ScrollController();
  int _currentPageIndex = 0;

  @override
  void initState() {
    super.initState();
    _initDocument();
  }

  Future<void> _initDocument() async {
    final obj = _requestController.selectedDocument.value;
    if (obj != null) {
      final doc = await PdfDocument.openFile(obj.file.path);
      final firstPage = await doc.getPage(1);
      _defaultPageSize = Size(firstPage.width, firstPage.height);
      await firstPage.close();
      setState(() => _document = doc);
    }

    _scrollController.addListener(_handleScroll);
  }

  void _handleScroll() {
    if (_document == null) return;

    // Calculate display dimensions based on our 600px max-width rule
    final screenW = MediaQuery.of(context).size.width;
    final displayW = (screenW - 48).clamp(
      0.0,
      600.0,
    ); // 48 is horizontal padding (24 * 2)
    final displayH =
        displayW * (_defaultPageSize.height / _defaultPageSize.width);
    final pageStride = displayH + 32; // 32 is bottom margin from PdfPageWidget

    final offset = _scrollController.offset;
    final newIndex = (offset / pageStride).round().clamp(
      0,
      _document!.pagesCount - 1,
    );

    if (newIndex != _currentPageIndex) {
      setState(() => _currentPageIndex = newIndex);
    }
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final docObj = _requestController.selectedDocument.value;

    final cs = Theme.of(context).colorScheme;

    return Scaffold(
      backgroundColor: cs.surface,
      appBar: _buildAppBar(docObj?.name ?? 'Place Fields'),
      body: GestureDetector(
        onTap: _controller.deselectField,
        child: Column(
          children: [
            Obx(() {
              // Hide signer switcher when field is selected for more focus
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
              child: _document == null
                  ? const Center(child: CircularProgressIndicator())
                  : InteractiveViewer(
                      minScale:
                          1.0, // Prevent zooming out beyond document width
                      maxScale: 4.0,
                      child: ListView.builder(
                        controller: _scrollController,
                        padding: const EdgeInsets.symmetric(
                          vertical: 10,
                          horizontal: 5,
                        ),
                        itemCount: _document!.pagesCount,
                        itemBuilder: (context, index) {
                          return Center(
                            child: PdfPageWidget(
                              document: _document!,
                              pageIndex: index + 1,
                              controller: _controller,
                            ),
                          );
                        },
                      ),
                    ),
            ),
            _buildBottomArea(),
          ],
        ),
      ),
    );
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
              // Calculate current display dimensions for correct spawning center
              final screenW = MediaQuery.of(context).size.width;
              final displayW = (screenW - 48).clamp(0.0, 600.0);
              final displayH =
                  displayW * (_defaultPageSize.height / _defaultPageSize.width);

              _controller.addField(type, displayW, displayH, _currentPageIndex);
            },
            onShowReassign: _showReassignMenu,
            onShowChangeType: () {}, // Handled internally by toolbar now
          ),
          Obx(() {
            final isFieldSelected = _controller.selectedFieldId.value != null;

            return Padding(
              padding: EdgeInsets.fromLTRB(
                16,
                0,
                16,
                Get.context!.mediaQueryPadding.bottom + 16,
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
}

class PdfPageWidget extends StatefulWidget {
  final PdfDocument document;
  final int pageIndex;
  final SignaturePlacementController controller;

  const PdfPageWidget({
    super.key,
    required this.document,
    required this.pageIndex,
    required this.controller,
  });

  @override
  State<PdfPageWidget> createState() => _PdfPageWidgetState();
}

class _PdfPageWidgetState extends State<PdfPageWidget> {
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
      return Container(
        height: 600,
        margin: const EdgeInsets.only(bottom: 32),
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
        // DocuSign-like centering: pages don't necessarily take full width
        final double displayW = constraints.maxWidth.clamp(0.0, 600.0);
        final double displayH = displayW * (pdfH / pdfW);

        return Container(
          margin: const EdgeInsets.only(bottom: 32),
          width: displayW,
          height: displayH,
          decoration: BoxDecoration(
            color: Colors.white,
            border: Border.all(
              color: Colors.black.withValues(alpha: 0.05),
              width: 0.5,
            ),
            boxShadow: [
              // Broad, soft shadow
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.08),
                blurRadius: 16,
                offset: const Offset(0, 8),
              ),
              // Sharp, close shadow for depth
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.04),
                blurRadius: 4,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Obx(() {
            final fields = widget.controller.allFields
                .where((e) => e.field.page == widget.pageIndex - 1)
                .toList();

            return Stack(
              children: [
                Positioned.fill(
                  child: Image.memory(_image!.bytes, fit: BoxFit.fill),
                ),
                ...fields.map(
                  (entry) => SignatureFieldOverlay(
                    key: ValueKey(entry.field.fieldId),
                    field: entry.field,
                    signer: entry.signer,
                    color: AppStyle.signerColor(context, entry.signerIndex),
                    controller: widget.controller,
                    canvasWidth: displayW,
                    canvasHeight: displayH,
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
