import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../../../../../Commons/Styles/style.dart';
import '../../../../../Utils/Constant/colors.dart';
import '../../../../../Utils/Constant/images.dart';
import '../../../../../Utils/Formatters/formatter.dart';
import '../../Documents/Model/document_model.dart';

class DocumentDisplayTile extends StatelessWidget {
  final DocumentModel document;
  final VoidCallback? onTap;
  final VoidCallback? onMoreTap;
  final EdgeInsetsGeometry margin;

  const DocumentDisplayTile({
    super.key,
    required this.document,
    this.onTap,
    this.onMoreTap,
    this.margin = const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: margin,
        decoration: AppStyle.card(),
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 12, 4, 12),
          child: Row(
            children: [
              SvgPicture.asset(AppImages.iconPdf, width: 40, height: 40),
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
              IconButton(
                icon: const Icon(
                  Icons.more_vert,
                  size: 18,
                  color: AppColors.textHint,
                ),
                onPressed: onMoreTap,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
