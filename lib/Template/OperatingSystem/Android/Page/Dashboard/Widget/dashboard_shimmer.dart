import 'package:flutter/material.dart';
import '../../../../../Commons/Widgets/loading_shimmer.dart';

class DashboardShimmer extends StatelessWidget {
  const DashboardShimmer({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Banner
        LoadingShimmer.box(context, height: 150, radius: 10),
        const SizedBox(height: 24),

        // Assigned Tasks sec
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            LoadingShimmer.box(context, height: 20, width: 140, radius: 4),
            LoadingShimmer.box(context, width: 60, radius: 4),
          ],
        ),
        const SizedBox(height: 12),
        SizedBox(
          height: 80,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: 2,
            separatorBuilder: (_, _) => const SizedBox(width: 8),
            itemBuilder: (_, _) => LoadingShimmer.box(
              context,
              width: 300,
              height: 80,
            ),
          ),
        ),
        const SizedBox(height: 24),

        // Recent Documents sec
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            LoadingShimmer.box(context, height: 20, width: 140, radius: 4),
            LoadingShimmer.box(context, width: 60, radius: 4),
          ],
        ),
        const SizedBox(height: 12),
        ListView.separated(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: 3,
          separatorBuilder: (_, _) => const SizedBox(height: 8),
          itemBuilder: (_, _) => _buildDocumentTileShimmer(context),
        ),
        const SizedBox(height: 24),

        // Activity sec
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            LoadingShimmer.box(context, height: 20, width: 100, radius: 4),
            LoadingShimmer.box(context, width: 60, radius: 4),
          ],
        ),
        const SizedBox(height: 12),
        ListView.separated(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: 3,
          separatorBuilder: (_, _) => const SizedBox(height: 8),
          itemBuilder: (_, _) => LoadingShimmer.listTile(context),
        ),
      ],
    );
  }

  Widget _buildDocumentTileShimmer(BuildContext context) {
    return LoadingShimmer.box(context, height: 72, radius: 12);
  }
}
