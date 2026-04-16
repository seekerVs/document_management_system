import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:pdfrx/pdfrx.dart';
import 'package:http/http.dart' as http;
import '../../../../../Commons/Widgets/app_pdf_viewer.dart';
import '../../../../../Commons/Widgets/app_button.dart';
import '../../../../../Utils/Constant/enum.dart';
import '../Controller/in_app_signing_controller.dart';
import '../Model/signature_field_model.dart';
import '../Model/signature_request_model.dart';
import '../Widget/signature_field_overlay.dart';
import '../Widget/in_app_signing_splash_overlay.dart';
import '../../../../../Utils/Services/supabase_service.dart';

class InAppSigningView extends StatefulWidget {
  const InAppSigningView({super.key});

  @override
  State<InAppSigningView> createState() => _InAppSigningViewState();
}

class _InAppSigningViewState extends State<InAppSigningView> {
  final InAppSigningController _controller = Get.find<InAppSigningController>();
  final List<PdfDocument> _documents = [];
  final List<String> _docIds = [];
  // Maps UUID (used as docId key) -> all aliases (name, legacy id) for backward compat
  final Map<String, Set<String>> _docIdAliases = {};
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchDocuments();
  }

  Future<void> _fetchDocuments() async {
    setState(() {
      _isLoading = true;
      _documents.clear();
      _docIds.clear();
    });
    try {
      List<RequestDocumentModel> docs = _controller.request.documents;

      // Legacy Fallback: if 'documents' list is empty, use the single document fields
      if (docs.isEmpty && _controller.request.documentId.isNotEmpty) {
        debugPrint(
          'InAppSigningView: Falling back to legacy single-document fields',
        );
        docs = [
          RequestDocumentModel(
            documentId: _controller.request.documentId,
            documentName: _controller.request.documentName,
            documentUrl: _controller.request.documentUrl,
            storagePath: _controller.request.storagePath,
          ),
        ];
      }

      debugPrint('InAppSigningView: Fetching ${docs.length} documents');

      for (final docObj in docs) {
        String url = docObj.documentUrl;
        if (url.isEmpty) url = docObj.storagePath;

        debugPrint('InAppSigningView: Document ${docObj.documentId} URL: $url');

        if (url.isEmpty) {
          debugPrint('InAppSigningView: Document URL is still empty.');
          continue;
        }

        // If it's a storage path, get a signed URL
        if (!url.startsWith('http')) {
          debugPrint('InAppSigningView: Getting signed URL for $url');
          url = await SupabaseService.getSignedUrl(url);
          debugPrint('InAppSigningView: Signed URL: $url');
        }

        final response = await http.get(Uri.parse(url));
        debugPrint('InAppSigningView: Download status: ${response.statusCode}');

        if (response.statusCode == 200) {
          final doc = await PdfDocument.openData(response.bodyBytes);
          _documents.add(doc);
          _docIds.add(docObj.documentId);
          // Build aliases: the UUID itself + the document name (for legacy field IDs)
          _docIdAliases[docObj.documentId] = {
            docObj.documentId,
            docObj.documentName,
          };
          debugPrint('InAppSigningView: Document loaded into PdfDocument');
        } else {
          debugPrint(
            'InAppSigningView: Failed to download: ${response.statusCode} - ${response.body}',
          );
        }
      }
    } catch (e) {
      debugPrint('InAppSigningView: Critical error fetching PDFs: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error loading documents: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  void dispose() {
    for (var doc in _documents) {
      doc.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      if (_controller.showSplash.value) {
        return const InAppSigningSplashOverlay();
      }

      final request = _controller.request;
      final signer = _controller.signer;

      return PopScope(
        canPop: false,
        onPopInvokedWithResult: (didPop, result) {
          if (didPop) return;
          _controller.onExit();
        },
        child: Scaffold(
          backgroundColor: Theme.of(context).scaffoldBackgroundColor,
          appBar: AppBar(
            title: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'Complete with Scrivener: ${request.documentName}',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                Text(
                  'Now Signing: ${signer.signerName}',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
            leading: IconButton(
              icon: const Icon(Icons.close),
              onPressed: () => _controller.onExit(),
            ),
          ),
          body: Column(
            children: [
              Expanded(
                child: _isLoading
                    ? const Center(child: CircularProgressIndicator())
                    : _documents.isEmpty
                        ? Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                const Icon(
                                  Icons.error_outline,
                                  color: Colors.red,
                                  size: 48,
                                ),
                                const SizedBox(height: 16),
                                const Text('No documents were loaded.'),
                                const SizedBox(height: 8),
                                ElevatedButton(
                                  onPressed: _fetchDocuments,
                                  child: const Text('Retry'),
                                ),
                              ],
                            ),
                          )
                        : AppPdfViewer(
                            documents: _documents,
                            docIds: _docIds,
                            fieldBuilder: (context, docId, pageIndex,
                                displayW, displayH) {
                              return _buildPageFields(
                                docId,
                                pageIndex,
                                displayW,
                                displayH,
                              );
                            },
                          ),
              ),
              _BottomBar(controller: _controller),
            ],
          ),
        ),
      );
    });
  }

  Widget _buildPageFields(
    String documentId,
    int pageIndex,
    double displayW,
    double displayH,
  ) {
    // Collect all known aliases for this document (UUID + legacy filename)
    final aliases = _docIdAliases[documentId] ?? {documentId};

    final fields = _controller.fields
        .where((f) => aliases.contains(f.documentId) && f.page == pageIndex)
        .toList();

    if (fields.isEmpty) return const SizedBox.shrink();

    return Obx(
      () => Stack(
        children: fields.map((f) {
          return SignatureFieldOverlay(
            key: ValueKey(f.fieldId),
            field: f,
            signer: _controller.signer,
            color: _controller.fieldColor(f.fieldId),
            canvasWidth: displayW,
            canvasHeight: displayH,
            isSelected: _controller.selectedFieldId.value == f.fieldId,
            onTap: () => _controller.onFieldTap(f),
            child: _controller.isFieldFilled(f.fieldId)
                ? _FilledFieldContent(
                    field: f,
                    imageBytes: _controller.signatureImages[f.fieldId],
                    textValue: _controller.fieldValues[f.fieldId],
                    color: _controller.fieldColor(f.fieldId),
                  )
                : null,
          );
        }).toList(),
      ),
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
      final isSignatureOrInitial =
          field.type == SignatureFieldType.signature ||
          field.type == SignatureFieldType.initials;

      if (isSignatureOrInitial) {
        final double scale = field.type == SignatureFieldType.signature
            ? 1.6
            : 1.2;
        return Transform.scale(
          scale: scale,
          child: Image.memory(imageBytes!, fit: BoxFit.contain),
        );
      }

      return Image.memory(imageBytes!, fit: BoxFit.contain);
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
        final allFilled = controller.allFieldsFilled;
        final manuallyStarted = controller.hasStartedManual.value;

        return Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            AppButton.primary(
              label: !manuallyStarted
                  ? 'Finish'
                  : (allFilled
                        ? 'Finish'
                        : (controller.signatureImages.isNotEmpty
                              ? 'Continue Signing'
                              : controller.footerLabel.value)),
              onPressed: !manuallyStarted
                  ? () => controller.showSplash.value = true
                  : (controller.allFieldsFilled
                        ? controller.handleFinishAction
                        : (controller.footerLabel.value == 'Finish'
                              ? controller.handleFinishAction
                              : controller.startSigningProcess)),
            ),
          ],
        );
      }),
    );
  }
}
