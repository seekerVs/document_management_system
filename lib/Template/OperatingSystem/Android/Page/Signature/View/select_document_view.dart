import 'dart:io';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';
import '../../../../../Commons/Styles/style.dart';
import '../../../../../Commons/Widgets/app_button.dart';
import 'package:pdfrx/pdfrx.dart';
import '../../../../../Commons/Widgets/app_pdf_viewer.dart';
import '../../../../../Utils/Services/supabase_service.dart';
import '../Controller/signature_request_controller.dart';
import '../Model/selected_document.dart';

class SelectDocumentView extends GetView<SignatureRequestController> {
  const SelectDocumentView({super.key});

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) {
        if (didPop) return;
        controller.onBackRequest();
      },
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Add Documents'),
          leading: IconButton(
            icon: const Icon(Icons.chevron_left),
            onPressed: controller.onBackRequest,
          ),
        ),
        body: Obx(() {
          return Column(
            children: [
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    children: [
                      ...controller.selectedDocuments.map(
                        (doc) => Column(
                          children: [
                            _DocumentTile(controller: controller, doc: doc),
                            const SizedBox(height: 8),
                          ],
                        ),
                      ),
                      // Add another document row
                      GestureDetector(
                        onTap: controller.showDocumentSourceSheet,
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 14,
                          ),
                          decoration: AppStyle.cardOf(context),
                          child: Row(
                            children: [
                              Icon(
                                Icons.add,
                                color: Theme.of(context).colorScheme.primary,
                                size: 20,
                              ),
                              const SizedBox(width: 12),
                              Text(
                                controller.selectedDocuments.isEmpty
                                    ? 'Select a document'
                                    : 'Add another document',
                                style: Theme.of(context).textTheme.titleSmall
                                    ?.copyWith(
                                      color: Theme.of(
                                        context,
                                      ).colorScheme.primary,
                                    ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              _BottomActions(controller: controller),
            ],
          );
        }),
      ),
    );
  }
}

class _DocumentTile extends StatelessWidget {
  final SignatureRequestController controller;
  final SelectedDocument doc;
  const _DocumentTile({required this.controller, required this.doc});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: AppStyle.cardOf(context),
      child: ListTile(
        contentPadding: const EdgeInsets.only(left: 16),
        onTap: () {
          Get.to(
            () => Scaffold(
              backgroundColor: Theme.of(context).colorScheme.surface,
              appBar: AppBar(
                backgroundColor: Theme.of(context).colorScheme.surface,
                scrolledUnderElevation: 0,
                elevation: 1,
                title: Text(
                  doc.name,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                    color: Theme.of(context).colorScheme.onSurface,
                  ),
                ),
                leading: IconButton(
                  icon: const Icon(Icons.chevron_left),
                  onPressed: Get.back,
                ),
              ),
              body: FutureBuilder<PdfDocument>(
                future: _loadPdf(doc),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  }
                  if (snapshot.hasError || !snapshot.hasData) {
                    return Center(
                      child: Padding(
                        padding: const EdgeInsets.all(24.0),
                        child: Text(
                          'Failed to load PDF: ${snapshot.error ?? "Unknown error"}',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: Theme.of(context).colorScheme.error,
                          ),
                        ),
                      ),
                    );
                  }
                  return AppPdfViewer(
                    documents: [snapshot.data!],
                    docIds: [doc.name],
                    fieldBuilder: (ctx, docId, page, w, h) =>
                        const SizedBox.shrink(),
                  );
                },
              ),
            ),
          );
        },
        leading: Container(
          width: 42,
          height: 42,
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.error,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Center(
            child: Text(
              'PDF',
              style: TextStyle(
                color: Theme.of(context).colorScheme.onError,
                fontWeight: FontWeight.w800,
                fontSize: 11,
              ),
            ),
          ),
        ),
        title: Text(
          doc.name,
          style: Theme.of(context).textTheme.titleSmall,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        subtitle: Text(
          doc.sizeLabel,
          style: Theme.of(context).textTheme.bodySmall,
        ),
        trailing: IconButton(
          icon: Icon(
            Icons.more_vert,
            size: 18,
            color: Theme.of(context).colorScheme.onSurfaceVariant,
          ),
          onPressed: () => controller.showSelectedDocumentOptions(doc),
        ),
      ),
    );
  }

  Future<PdfDocument> _loadPdf(SelectedDocument doc) async {
    if (await doc.file.exists() && await doc.file.length() > 0) {
      return PdfDocument.openFile(doc.file.path);
    }

    if (doc.storagePath == null || doc.storagePath!.isEmpty) {
      throw Exception('Document path is missing and no storage path provided.');
    }

    // Download from Supabase
    final signedUrl = await SupabaseService.getSignedUrl(doc.storagePath!);
    final response = await http.get(Uri.parse(signedUrl));
    if (response.statusCode != 200) {
      throw Exception('Failed to download document from cloud.');
    }

    final tempDir = await getTemporaryDirectory();
    final tempFile = File('${tempDir.path}/${doc.documentId ?? "temp"}.pdf');
    await tempFile.writeAsBytes(response.bodyBytes);

    return PdfDocument.openFile(tempFile.path);
  }
}

class _BottomActions extends StatelessWidget {
  final SignatureRequestController controller;
  const _BottomActions({required this.controller});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 32),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Obx(
            () => AppButton.primary(
              label: 'Next',
              onPressed: controller.selectedDocuments.isNotEmpty
                  ? controller.goToAddRecipients
                  : null,
            ),
          ),
          const SizedBox(height: 8),
          AppButton.outlined(
            label: 'Cancel',
            onPressed: () => controller.onBackRequest(forceDialog: true),
          ),
        ],
      ),
    );
  }
}
