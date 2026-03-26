import 'dart:io';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';
import '../../../../../Utils/Constant/colors.dart';
import '../../../../../Utils/Constant/enum.dart';
import '../Model/document_model.dart';
import '../Widget/image_viewer.dart';
import '../Widget/pdf_viewer.dart';
import '../Widget/viewer_error_state.dart';
import '../Widget/viewer_loading_state.dart';
import '../../../../../../Template/Utils/Services/supabase_service.dart';

class DocumentViewerView extends StatefulWidget {
  const DocumentViewerView({super.key});

  @override
  State<DocumentViewerView> createState() => _DocumentViewerViewState();
}

class _DocumentViewerViewState extends State<DocumentViewerView> {
  late final DocumentModel doc;

  String? _localPdfPath;
  String? _signedImageUrl;
  bool _isLoading = true;
  String? _error;

  bool get _isPdf => doc.fileType == DocumentFileType.pdf;

  @override
  void initState() {
    super.initState();
    doc = Get.arguments as DocumentModel;
    _loadDocument();
  }

  @override
  void dispose() {
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
        final dir = await getTemporaryDirectory();
        final file = File('${dir.path}/${doc.documentId}.pdf');
        await file.writeAsBytes(response.bodyBytes);
        if (mounted) {
          setState(() {
            _localPdfPath = file.path;
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
    return Scaffold(
      backgroundColor: _isPdf ? AppColors.backgroundLight : Colors.black,
      appBar: AppBar(
        backgroundColor: _isPdf ? AppColors.backgroundLight : Colors.black,
        foregroundColor: _isPdf ? AppColors.textPrimary : Colors.white,
        scrolledUnderElevation: 0,
        elevation: _isPdf ? 1 : 0,
        title: Text(
          doc.name,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.w600,
            color: _isPdf ? AppColors.textPrimary : Colors.white,
          ),
        ),
        leading: IconButton(
          icon: Icon(
            Icons.chevron_left,
            color: _isPdf ? AppColors.textPrimary : Colors.white,
          ),
          onPressed: () => Get.back(),
        ),
      ),
      // Use body + Column instead of bottomNavigationBar
      // to avoid layout rebuild collapsing SfPdfViewer
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

    if (_localPdfPath != null) {
      return _buildPdfBody();
    }

    return const SizedBox.shrink();
  }

  Widget _buildPdfBody() {
    return PdfViewer(
      localPath: _localPdfPath!,
      onRender: (_) {},
      onPageChanged: (_, __) {},
      onError: (e) {
        if (mounted) setState(() => _error = e);
      },
    );
  }
}
