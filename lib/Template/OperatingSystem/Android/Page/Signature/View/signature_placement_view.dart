import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:pdfrx/pdfrx.dart';
import '../../../../../Commons/Styles/style.dart';
import '../../../../../Commons/Widgets/app_button.dart';
import '../../../../../Utils/Routes/main_routes.dart';
import '../../../../../Utils/Services/supabase_service.dart';
import '../../../../../Commons/Widgets/app_pdf_viewer.dart';
import '../Controller/signature_placement_controller.dart';
import '../Controller/signature_request_controller.dart';
import '../Widget/field_toolbar.dart';
import '../Widget/signature_field_guide_dialog.dart';
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

  final List<PdfDocument> _documents = [];
  final List<String> _docIds = [];
  // Key: DocumentId -> PageIndex -> Size
  final Map<String, Map<int, Size>> _pageSizeCache = {};

  bool _isLoading = true;
  int _currentPageIndex = 0;
  String _currentDocId = '';

  @override
  void initState() {
    super.initState();
    _initDocuments();
  }

  @override
  void dispose() {
    for (var doc in _documents) {
      doc.dispose();
    }
    super.dispose();
  }

  Future<void> _initDocuments() async {
    setState(() => _isLoading = true);
    try {
      // Clear existing state for clean load/retry
      _documents.clear();
      _docIds.clear();
      _pageSizeCache.clear();

      for (final docObj in _requestController.selectedDocuments) {
        debugPrint('Opening document: ${docObj.name}');
        PdfDocument doc;

        doc = await (docObj.documentId != null && docObj.storagePath != null
            ? PdfDocument.openData(
                (await http.get(
                  Uri.parse(
                    await SupabaseService.getSignedUrl(docObj.storagePath!),
                  ),
                )).bodyBytes,
              )
            : PdfDocument.openFile(docObj.file.path));

        final page = doc.pages.first;
        _pageSizeCache[docObj.name] = {0: Size(page.width, page.height)};

        _documents.add(doc);
        _docIds.add(docObj.name);
        debugPrint(
          'Document ${docObj.name} opened successfully. Pages: ${doc.pages.length}',
        );
      }
      if (_docIds.isNotEmpty) _currentDocId = _docIds[0];
    } catch (e, stack) {
      debugPrint('Error opening PDFs: $e');
      debugPrint('Stack trace: $stack');
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final screenW = MediaQuery.of(context).size.width;
    final availableW = (screenW - 16).clamp(0.0, 600.0);

    return PopScope(
      onPopInvokedWithResult: (didPop, result) {},
      child: Scaffold(
        backgroundColor: cs.surface,
        appBar: _buildAppBar(
          _docIds.length > 1
              ? 'Place Fields'
              : (_docIds.firstOrNull ?? 'Place Fields'),
        ),
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
                child: _isLoading
                    ? const Center(child: CircularProgressIndicator())
                    : AppPdfViewer(
                        documents: _documents,
                        docIds: _docIds,
                        maxWidth: availableW,
                        onFieldMove: (fieldId, docId, pageIndex, x, y) {
                          _controller.moveFieldToPage(
                            fieldId,
                            docId,
                            pageIndex,
                            x,
                            y,
                          );
                        },
                        onPageChanged: (docId, pageIndex) {
                          setState(() {
                            _currentDocId = docId;
                            _currentPageIndex = pageIndex;
                          });
                        },
                        fieldBuilder: (ctx, docId, pageIndex, displayW, displayH) {
                          // Update page size cache for accurate spawning
                          final docMap = _pageSizeCache[docId] ?? {};
                          docMap[pageIndex] = Size(displayW, displayH);
                          _pageSizeCache[docId] = docMap;

                          return _buildPageFields(
                            ctx,
                            docId,
                            pageIndex,
                            displayW,
                            displayH,
                          );
                        },
                      ),
              ),
              _buildBottomArea(),
            ],
          ),
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
          actions: [
            if (!isFieldSelected)
              IconButton(
                icon: Icon(Icons.help_outline, color: cs.onSurfaceVariant),
                tooltip: 'Guide',
                onPressed: () {
                  Get.dialog(
                    const SignatureFieldGuideDialog(),
                    barrierDismissible: false,
                  );
                },
              ),
            if (!isFieldSelected) const SizedBox(width: 8),
          ],
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
              // Current page dimensions from cache
              final docMap = _pageSizeCache[_currentDocId] ?? {};
              final Size pageSize = docMap[_currentPageIndex] ?? const Size(600, 800);

              // Use the actual rendered dimensions for spawning calculation
              final double actualDisplayW = pageSize.width;
              final double actualDisplayH = pageSize.height;

              _controller.addField(
                type,
                actualDisplayW,
                actualDisplayH,
                _currentDocId,
                _currentPageIndex,
              );
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

  Widget _buildPageFields(
    BuildContext context,
    String documentId,
    int pageIndex,
    double displayW,
    double displayH,
  ) {
    return Obx(() {
      final fields = _controller.allFields
          .where(
            (e) =>
                e.field.documentId == documentId && e.field.page == pageIndex,
          )
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
