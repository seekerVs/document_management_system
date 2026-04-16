import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../../../Commons/Styles/style.dart';
import '../../../../../Utils/Routes/main_routes.dart';
import '../../Documents/Model/document_model.dart';
import '../../Signature/Model/signature_request_model.dart';
import '../../../../../Utils/Constant/enum.dart';

/// Displays all documents in a signature request as individual tappable tiles.
/// Tapping a tile opens that specific document in the DocumentViewer.
class RequestDocumentsView extends StatelessWidget {
  const RequestDocumentsView({super.key});

  @override
  Widget build(BuildContext context) {
    final args = Get.arguments as Map<String, dynamic>?;
    final task = args?['task'] as SignatureRequestModel?;

    if (task == null) {
      return Scaffold(
        appBar: AppBar(
          title: const Text('Documents'),
          centerTitle: true,
          leading: IconButton(
            icon: const Icon(Icons.chevron_left),
            onPressed: Get.back,
          ),
        ),
        body: const Center(child: Text('No request data found.')),
      );
    }

    // Build a list of documents, falling back to legacy single-doc if needed
    final List<RequestDocumentModel> docs = task.documents.isNotEmpty
        ? task.documents
        : [
            RequestDocumentModel(
              documentId: task.documentId,
              documentName: task.documentName,
              documentUrl: task.documentUrl,
              storagePath: task.storagePath,
            ),
          ];

    final cs = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Documents'),
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.chevron_left),
          onPressed: Get.back,
        ),
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header describing the request
          Container(
            width: double.infinity,
            padding: const EdgeInsets.fromLTRB(20, 16, 20, 16),
            decoration: BoxDecoration(
              color: cs.surface,
              border: Border(
                bottom: BorderSide(
                  color: cs.outlineVariant.withValues(alpha: 0.4),
                ),
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'From: ${task.requesterName ?? 'Unknown'}',
                  style: textTheme.bodySmall?.copyWith(
                    color: cs.onSurfaceVariant,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  '${docs.length} ${docs.length == 1 ? 'Document' : 'Documents'} in this request',
                  style: textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                    color: cs.onSurface,
                  ),
                ),
              ],
            ),
          ),

          // Document list
          Expanded(
            child: ListView.separated(
              padding: const EdgeInsets.all(20),
              itemCount: docs.length,
              separatorBuilder: (_, _) => const SizedBox(height: 12),
              itemBuilder: (context, index) {
                final docObj = docs[index];
                return _DocumentTile(
                  docObj: docObj,
                  index: index,
                  total: docs.length,
                  task: task,
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _DocumentTile extends StatelessWidget {
  final RequestDocumentModel docObj;
  final int index;
  final int total;
  final SignatureRequestModel task;

  const _DocumentTile({
    required this.docObj,
    required this.index,
    required this.total,
    required this.task,
  });

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return GestureDetector(
      onTap: () => _openDocument(context),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: AppStyle.cardOf(context),
        child: Row(
          children: [
            // PDF icon
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: cs.primaryContainer,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Center(
                child: Icon(
                  Icons.picture_as_pdf_outlined,
                  color: cs.primary,
                  size: 26,
                ),
              ),
            ),
            const SizedBox(width: 14),

            // Name and doc index
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    docObj.documentName,
                    style: textTheme.bodyMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                      color: cs.onSurface,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Document ${index + 1} of $total',
                    style: textTheme.bodySmall?.copyWith(
                      color: cs.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            ),

            // Chevron
            Icon(Icons.chevron_right, color: cs.onSurfaceVariant, size: 20),
          ],
        ),
      ),
    );
  }

  void _openDocument(BuildContext context) {
    final doc = DocumentModel(
      documentId: docObj.documentId,
      ownerUid: task.requestedByUid,
      name: docObj.documentName,
      fileUrl: docObj.documentUrl,
      storagePath: docObj.storagePath,
      fileSizeMB: 0,
      createdAt: task.createdAt,
      updatedAt: task.createdAt,
      status: DocumentStatus.pending,
    );

    Get.toNamed(
      MainRoutes.documentViewer,
      arguments: {'doc': doc, 'task': task},
    );
  }
}
