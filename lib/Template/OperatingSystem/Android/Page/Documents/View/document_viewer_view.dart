import 'dart:io';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';
import 'package:pdfx/pdfx.dart';
import '../../../../../Utils/Constant/enum.dart';
import '../../../../../Commons/Widgets/app_pdf_viewer.dart';
import '../Model/document_model.dart';
import '../Widget/image_viewer.dart';
import '../Widget/viewer_error_state.dart';
import '../Widget/viewer_loading_state.dart';
import '../../../../../Utils/Services/supabase_service.dart';
import '../../Signature/Model/signature_request_model.dart';
import '../../Signature/Widget/signature_field_overlay.dart';

class DocumentViewerView extends StatefulWidget {
  const DocumentViewerView({super.key});

  @override
  State<DocumentViewerView> createState() => _DocumentViewerViewState();
}

class _DocumentViewerViewState extends State<DocumentViewerView> {
  late final DocumentModel doc;
  SignatureRequestModel? task;

  PdfDocument? _pdfDocument;
  String? _signedImageUrl;
  bool _isLoading = true;
  String? _error;

  bool get _isPdf => doc.fileType == DocumentFileType.pdf;

  @override
  void initState() {
    super.initState();
    final args = Get.arguments;
    if (args is Map) {
      doc = args['doc'] as DocumentModel;
      task = args['task'] as SignatureRequestModel?;
    } else {
      doc = args as DocumentModel;
      task = null;
    }
    _loadDocument();
  }

  @override
  void dispose() {
    _pdfDocument?.close();
    super.dispose();
  }

  Future<void> _loadDocument() async {
    if (mounted) {
      setState(() {
        _isLoading = true;
        _error = null;
      });
    }
    try {
      final signedUrl = await SupabaseService.getSignedUrl(doc.fileUrl);
      if (_isPdf) {
        final response = await http.get(Uri.parse(signedUrl));
        if (response.statusCode != 200) {
          throw Exception('Failed to download PDF');
        }

        final tempDir = await getTemporaryDirectory();
        final tempFile = File('${tempDir.path}/${doc.documentId}.pdf');
        await tempFile.writeAsBytes(response.bodyBytes);

        final pdfDoc = await PdfDocument.openFile(tempFile.path);

        if (mounted) {
          setState(() {
            _pdfDocument = pdfDoc;
            _isLoading = false;
          });
        }
      } else {
        if (mounted) {
          setState(() {
            _signedImageUrl = signedUrl;
            _isLoading = false;
          });
        }
      }
    } catch (_) {
      if (mounted) {
        setState(() {
          _error = 'Failed to load document. Please try again.';
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final bgColor = _isPdf ? cs.surface : Colors.black;
    final fgColor = _isPdf ? cs.onSurface : Colors.white;

    return Scaffold(
      backgroundColor: bgColor,
      appBar: AppBar(
        backgroundColor: bgColor,
        foregroundColor: fgColor,
        scrolledUnderElevation: 0,
        elevation: _isPdf ? 1 : 0,
        title: Text(
          doc.name,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.w600,
            color: fgColor,
          ),
        ),
        leading: IconButton(
          icon: Icon(Icons.chevron_left, color: fgColor),
          onPressed: () => Get.back(),
        ),
      ),
      body: _buildBody(),
    );
  }

  Widget _buildBody() {
    if (_isLoading) return ViewerLoadingState(isDark: !_isPdf);

    if (_error != null) {
      return ViewerErrorState(
        message: _error!,
        onRetry: _loadDocument,
        isDark: !_isPdf,
      );
    }

    if (!_isPdf && _signedImageUrl != null) {
      return ImageViewer(imageUrl: _signedImageUrl!);
    }

    if (_pdfDocument != null) {
      return _buildPdfBody();
    }

    return const SizedBox.shrink();
  }

  Widget _buildPdfBody() {
    return AppPdfViewer(
      document: _pdfDocument!,
      docId: doc.documentId,
      fieldBuilder: (ctx, page, w, h) {
        if (task == null) return const SizedBox.shrink();

        final signedSigners = task!.signers.where(
          (s) => s.status.name == 'signed' || s.status.name == 'completed',
        );
        final List<Widget> overlays = [];

        for (var signer in signedSigners) {
          for (var field in signer.fields) {
            if (field.page == page) {
              Widget? overlayChild;
              final isImage =
                  field.type == SignatureFieldType.signature ||
                  field.type == SignatureFieldType.initials;

              if (isImage && signer.signatureImageUrl != null) {
                overlayChild = Image.network(
                  signer.signatureImageUrl!,
                  fit: BoxFit.contain,
                );
              } else if (!isImage) {
                overlayChild = Center(
                  child: Text(
                    field.value ?? '',
                    style: const TextStyle(
                      color: Colors.black,
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                    ),
                    textAlign: TextAlign.center,
                  ),
                );
              }

              overlays.add(
                SignatureFieldOverlay(
                  field: field,
                  signer: signer,
                  color: Colors.transparent,
                  canvasWidth: w,
                  canvasHeight: h,
                  child: overlayChild,
                ),
              );
            }
          }
        }
        return Stack(children: overlays);
      },
    );
  }
}
