import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../Documents/Model/document_model.dart';
import '../Controller/dashboard_controller.dart';

// 📁 lib/Template/OperatingSystem/Android/Page/Welcome/Widget/recent_documents_section.dart

class RecentDocumentsSection extends GetView<DashboardController> {
  const RecentDocumentsSection({super.key});

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final docs = controller.recentDocuments;

      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'My Documents',
                style: Theme.of(
                  context,
                ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
              ),
              TextButton(
                onPressed: controller.goToDocuments,
                child: const Text('See All'),
              ),
            ],
          ),
          const SizedBox(height: 8),
          if (docs.isEmpty)
            _EmptyDocuments()
          else
            ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: docs.length,
              separatorBuilder: (_, _) => const SizedBox(height: 8),
              itemBuilder: (context, index) =>
                  _DocumentTile(document: docs[index]),
            ),
        ],
      );
    });
  }
}

class _DocumentTile extends StatelessWidget {
  final DocumentModel document;
  const _DocumentTile({required this.document});

  @override
  Widget build(BuildContext context) {
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10),
        side: BorderSide(
          color: Theme.of(context).colorScheme.outline.withOpacity(0.15),
        ),
      ),
      leading: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          color: document.isPdf
              ? Colors.red.withOpacity(0.1)
              : Colors.blue.withOpacity(0.1),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Icon(
          document.isPdf ? Icons.picture_as_pdf : Icons.image_outlined,
          color: document.isPdf ? Colors.red : Colors.blue,
          size: 20,
        ),
      ),
      title: Text(
        document.name,
        style: Theme.of(
          context,
        ).textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w500),
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
      ),
      subtitle: Text(
        '${document.fileSizeMB.toStringAsFixed(1)} MB  ·  ${_statusLabel(document.status)}',
        style: Theme.of(context).textTheme.bodySmall,
      ),
      trailing: Icon(
        Icons.more_vert,
        color: Theme.of(context).colorScheme.outline,
        size: 20,
      ),
      onTap: () {},
    );
  }

  String _statusLabel(DocumentStatus status) {
    switch (status) {
      case DocumentStatus.draft:
        return 'Draft';
      case DocumentStatus.pending:
        return 'Pending signature';
      case DocumentStatus.completed:
        return 'Completed';
      case DocumentStatus.declined:
        return 'Declined';
    }
  }
}

class _EmptyDocuments extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          Icon(
            Icons.folder_open_outlined,
            size: 40,
            color: Theme.of(context).colorScheme.outline,
          ),
          const SizedBox(height: 8),
          Text(
            'No documents yet',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: Theme.of(context).colorScheme.outline,
            ),
          ),
        ],
      ),
    );
  }
}
