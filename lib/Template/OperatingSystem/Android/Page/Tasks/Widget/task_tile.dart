import 'package:flutter/material.dart';
import '../../../../../Commons/Styles/style.dart';
import '../../../../../Utils/Constant/colors.dart';
import '../../../../../Utils/Constant/enum.dart';
import '../../Signature/Model/signature_request_model.dart';

class TaskTile extends StatelessWidget {
  final SignatureRequestModel request;
  final SignerModel signer;
  final VoidCallback onTap;
  final VoidCallback onMoreTap;

  const TaskTile({
    super.key,
    required this.request,
    required this.signer,
    required this.onTap,
    required this.onMoreTap,
  });

  @override
  Widget build(BuildContext context) {
    final daysSince = DateTime.now().difference(request.createdAt).inDays;
    final isUrgent = daysSince >= 7;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
        padding: const EdgeInsets.all(16),
        decoration: AppStyle.card(),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Task type icon
            const Padding(
              padding: EdgeInsets.only(top: 2),
              child: Icon(
                Icons.edit_outlined,
                color: AppColors.primary,
                size: 22,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Role label
                  Text(
                    _roleLabel,
                    style: Theme.of(context).textTheme.titleSmall,
                  ),
                  const SizedBox(height: 6),
                  // Age badge
                  _AgeBadge(daysSince: daysSince, isUrgent: isUrgent),
                  const SizedBox(height: 6),
                  // Document name
                  Text(
                    request.documentName,
                    style: Theme.of(context).textTheme.bodySmall,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
            // More button
            IconButton(
              icon: const Icon(
                Icons.more_vert,
                size: 18,
                color: AppColors.textHint,
              ),
              onPressed: onMoreTap,
              padding: EdgeInsets.zero,
              constraints: const BoxConstraints(),
            ),
          ],
        ),
      ),
    );
  }

  String get _roleLabel {
    switch (signer.role) {
      case SignerRole.needsToSign:
        return 'Needs to sign';
      case SignerRole.receivesACopy:
        return 'Receives a copy';
    }
  }
}

class _AgeBadge extends StatelessWidget {
  final int daysSince;
  final bool isUrgent;

  const _AgeBadge({required this.daysSince, required this.isUrgent});

  @override
  Widget build(BuildContext context) {
    final color = isUrgent
        ? AppColors.signatureDeclined
        : AppColors.signaturePending;
    final surface = isUrgent
        ? AppColors.signatureDeclinedSurface
        : AppColors.signaturePendingSurface;

    final label = daysSince == 0
        ? 'Assigned today'
        : daysSince == 1
        ? 'Assigned yesterday'
        : 'Assigned $daysSince days ago';

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: surface,
        borderRadius: BorderRadius.circular(40),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: color,
          fontSize: 11,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}
