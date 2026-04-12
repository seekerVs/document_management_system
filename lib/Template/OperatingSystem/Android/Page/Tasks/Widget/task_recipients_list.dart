import 'package:flutter/material.dart';
import '../../../../../Utils/Constant/enum.dart';
import '../../Signature/Model/signature_request_model.dart';
import '../../../../../Commons/Widgets/app_avatar.dart';
import '../../../../../Commons/Widgets/app_badge.dart';
import '../../Profile/Model/user_model.dart';
import '../../Profile/Repository/user_repository.dart';
import '../../../../../Utils/Firebase/firebase_utils.dart';

class TaskRecipientsList extends StatelessWidget {
  final List<SignerModel> signers;

  const TaskRecipientsList({super.key, required this.signers});

  @override
  Widget build(BuildContext context) {
    final currentEmail = FirebaseUtils.currentEmail;

    return ListView.separated(
      padding: const EdgeInsets.symmetric(vertical: 20),
      itemCount: signers.length,
      separatorBuilder: (_, _) => const Divider(),
      itemBuilder: (context, index) {
        final signer = signers[index];
        final isCurrentUser = signer.signerEmail == currentEmail;

        return ListTile(
          contentPadding: const EdgeInsets.symmetric(vertical: 4),
          leading: _RecipientAvatar(signer: signer),
          title: Text(
            signer.signerName,
            style: Theme.of(context).textTheme.titleSmall?.copyWith(
              fontWeight: FontWeight.bold,
              color: Theme.of(context).colorScheme.onSurface,
            ),
          ),
          subtitle: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (isCurrentUser)
                Text(
                  'Assignee',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
                ),
              Text(
                signer.role == SignerRole.needsToSign
                    ? 'Needs to sign'
                    : 'Receives a copy',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
              ),
            ],
          ),
          trailing: AppBadge.signerStatus(status: signer.status),
        );
      },
    );
  }
}

class _RecipientAvatar extends StatelessWidget {
  final SignerModel signer;

  const _RecipientAvatar({required this.signer});

  @override
  Widget build(BuildContext context) {
    if (signer.photoUrl != null && signer.photoUrl!.isNotEmpty) {
      return AppAvatar(
        name: signer.signerName,
        photoUrl: signer.photoUrl,
        radius: 22,
      );
    }

    return FutureBuilder<UserModel?>(
      future: UserRepository().getByEmail(signer.signerEmail),
      builder: (context, snapshot) {
        final photoUrl = snapshot.data?.photoUrl;
        return AppAvatar(
          name: signer.signerName,
          photoUrl: photoUrl,
          radius: 22,
        );
      },
    );
  }
}
