import 'package:flutter/material.dart';
import '../../../../../Commons/Widgets/loading_shimmer.dart';

class DocumentsShimmer extends StatelessWidget {
  final bool showStorageBanner;
  final bool isGridView;

  const DocumentsShimmer({
    super.key,
    this.showStorageBanner = true,
    this.isGridView = true,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Search bar shimmer
        LoadingShimmer.box(context, height: 52, radius: 12),
        const SizedBox(height: 12),

        // Storage banner shimmer
        if (showStorageBanner) ...[
          LoadingShimmer.storageBanner(context),
          const SizedBox(height: 12),
        ],

        // Toolbar shimmer
        LoadingShimmer.box(context, height: 48),
        const SizedBox(height: 12),

        // Content skeleton matches current view mode
        isGridView
            ? LoadingShimmer.documentGrid(context)
            : LoadingShimmer.documentList(context),
      ],
    );
  }
}
