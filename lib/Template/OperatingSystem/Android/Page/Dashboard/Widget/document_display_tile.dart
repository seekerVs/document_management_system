import 'package:flutter/material.dart';
import '../../../../../Commons/Styles/style.dart';
import '../../../../../Utils/Formatters/formatter.dart';
import '../../Documents/Model/document_model.dart';

class DocumentDisplayTile extends StatelessWidget {
  final DocumentModel document;
  final VoidCallback? onTap;
  final VoidCallback? onOpen;
  final VoidCallback? onDetails;
  final EdgeInsetsGeometry margin;

  const DocumentDisplayTile({
    super.key,
    required this.document,
    this.onTap,
    this.onOpen,
    this.onDetails,
    this.margin = const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
  });

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: margin,
        decoration: AppStyle.cardOf(context),
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 12, 4, 12),
          child: Row(
            children: [
              Container(
                width: 42,
                height: 42,
                decoration: BoxDecoration(
                  color: cs.error,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Center(
                  child: Text(
                    'PDF',
                    style: TextStyle(
                      color: cs.onError,
                      fontWeight: FontWeight.w800,
                      fontSize: 11,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      document.name,
                      style: Theme.of(context).textTheme.titleSmall,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 2),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          AppFormatter.fileSizeFromMB(document.fileSizeMB),
                          style: Theme.of(context).textTheme.bodySmall,
                        ),
                        Text(
                          AppFormatter.dateShort(document.updatedAt),
                          style: Theme.of(context).textTheme.bodySmall,
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              PopupMenuButton<_DocMenuOption>(
                position: PopupMenuPosition.under,
                icon: Icon(
                  Icons.more_vert,
                  size: 18,
                  color: cs.onSurfaceVariant,
                ),
                onSelected: (option) {
                  if (option == _DocMenuOption.open) onOpen?.call();
                  if (option == _DocMenuOption.details) onDetails?.call();
                },
                itemBuilder: (_) => [
                  PopupMenuItem(
                    value: _DocMenuOption.open,
                    child: Row(
                      children: [
                        Icon(Icons.open_in_new_outlined, size: 20, color: cs.onSurface),
                        const SizedBox(width: 12),
                        Text('Open in Documents',
                            style: Theme.of(context).textTheme.bodyMedium),
                      ],
                    ),
                  ),
                  PopupMenuItem(
                    value: _DocMenuOption.details,
                    child: Row(
                      children: [
                        Icon(Icons.info_outline, size: 20, color: cs.onSurface),
                        const SizedBox(width: 12),
                        Text('Details',
                            style: Theme.of(context).textTheme.bodyMedium),
                      ],
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

enum _DocMenuOption { open, details }
