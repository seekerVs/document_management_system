import 'package:flutter/material.dart';
import '../Styles/style.dart';
import '../../OperatingSystem/Android/Page/Documents/Model/document_model.dart';
import '../../OperatingSystem/Android/Page/Documents/Model/folder_model.dart';
import '../../Utils/Formatters/formatter.dart';

class DocumentDetailsSheet extends StatelessWidget {
  final DocumentModel doc;
  const DocumentDetailsSheet({super.key, required this.doc});

  @override
  Widget build(BuildContext context) {
    return _DetailsSheet(
      title: 'Details',
      rows: [
        _DetailRow(label: 'Name', value: doc.name),
        const _DetailRow(label: 'Type', value: 'PDF'),
        _DetailRow(
          label: 'Size',
          value: AppFormatter.fileSizeFromMB(doc.fileSizeMB),
        ),
        _DetailRow(
          label: 'Modified',
          value: AppFormatter.dateShort(doc.updatedAt),
        ),
        _DetailRow(
          label: 'Created',
          value: AppFormatter.dateShort(doc.createdAt),
        ),
      ],
    );
  }
}

class FolderDetailsSheet extends StatelessWidget {
  final FolderModel folder;
  const FolderDetailsSheet({super.key, required this.folder});

  @override
  Widget build(BuildContext context) {
    return _DetailsSheet(
      title: 'Details',
      rows: [
        _DetailRow(label: 'Name', value: folder.name),
        const _DetailRow(label: 'Type', value: 'Folder'),
        _DetailRow(label: 'Items', value: '${folder.itemCount}'),
        _DetailRow(
          label: 'Modified',
          value: AppFormatter.dateShort(folder.updatedAt),
        ),
        _DetailRow(
          label: 'Created',
          value: AppFormatter.dateShort(folder.createdAt),
        ),
      ],
    );
  }
}

class MultiSelectionDetailsSheet extends StatelessWidget {
  final int count;
  final double totalSizeMB;
  const MultiSelectionDetailsSheet({
    super.key,
    required this.count,
    required this.totalSizeMB,
  });

  @override
  Widget build(BuildContext context) {
    return _DetailsSheet(
      title: 'Selection',
      rows: [
        _DetailRow(label: 'Selected', value: '$count items'),
        _DetailRow(
          label: 'Total size',
          value: AppFormatter.fileSizeFromMB(totalSizeMB),
        ),
      ],
    );
  }
}

class _DetailsSheet extends StatelessWidget {
  final String title;
  final List<_DetailRow> rows;
  const _DetailsSheet({required this.title, required this.rows});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(24, 12, 24, 32),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Center(
            child: Container(
              width: 40,
              height: 4,
              decoration: AppStyle.bottomSheetHandle,
            ),
          ),
          const SizedBox(height: 20),
          Text(title, style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: 16),
          ...rows,
        ],
      ),
    );
  }
}

class _DetailRow extends StatelessWidget {
  final String label;
  final String value;
  const _DetailRow({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        children: [
          SizedBox(
            width: 80,
            child: Text(label, style: Theme.of(context).textTheme.bodySmall),
          ),
          Expanded(
            child: Text(value, style: Theme.of(context).textTheme.titleSmall),
          ),
        ],
      ),
    );
  }
}
