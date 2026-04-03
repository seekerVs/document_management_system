import '../../../../../../Template/Utils/Constant/enum.dart';
import '../../../../../../Template/Utils/Firebase/firebase_method.dart';
import '../../../../../../Template/Utils/Firebase/firebase_utils.dart';
import '../../../../../../Template/Utils/Firebase/base_repository.dart';
import '../../Activity/Model/activity_model.dart';
import '../../Documents/Model/document_model.dart';
import '../../Signature/Model/signature_request_model.dart';

class DashboardRepository extends BaseRepository {
  // Recent documents

  Future<List<DocumentModel>> getRecentDocuments() => handleRequest(() async {
    final uid = currentUidOrNull;
    if (uid == null) return <DocumentModel>[];
    final docs = await FirebaseMethod.getDocuments(
      query: FirebaseUtils.documentsRef
          .where(FirebaseField.ownerUid, isEqualTo: uid)
          .orderBy(FirebaseField.updatedAt, descending: true)
          .limit(5),
    );
    return docs.map((d) => DocumentModel.fromFirestore(d)).toList();
  }).then((v) => v ?? <DocumentModel>[]);

  // ─── Assigned tasks ───────────────────────────────────────────────────────

  Future<List<SignatureRequestModel>> getAssignedTasks() =>
      handleRequest(() async {
        final email = FirebaseUtils.currentEmail;
        if (email == null) return <SignatureRequestModel>[];
        final queryEmail = email.trim().toLowerCase();

        final docs = await FirebaseMethod.getDocuments(
          query: FirebaseUtils.signatureRequestsRef
              .where('signerEmails', arrayContains: queryEmail)
              .orderBy('createdAt', descending: true)
              .limit(10),
        );

        final all =
            docs.map((d) => SignatureRequestModel.fromFirestore(d)).toList();

        return all
            .where(
              (req) => req.status != SignatureRequestStatus.completed && req.signers.any(
                (s) => s.signerEmail.toLowerCase() == queryEmail && s.status == SignerStatus.pending,
              ),
            )
            .toList();
      }).then((v) => v ?? <SignatureRequestModel>[]);

  // ─── Recent activity (last 5) ────────────────────────────────────────────

  Future<List<ActivityModel>> getRecentActivity() => handleRequest(() async {
    final uid = currentUidOrNull;
    if (uid == null) return <ActivityModel>[];
    final docs = await FirebaseMethod.getDocuments(
      query: FirebaseUtils.activitiesRef
          .where('actorUid', isEqualTo: uid)
          .orderBy('timestamp', descending: true)
          .limit(5),
    );
    return docs.map((d) => ActivityModel.fromFirestore(d)).toList();
  }).then((v) => v ?? <ActivityModel>[]);

  // ─── Unread notification count ────────────────────────────────────────────

  Stream<int> unreadNotificationCount() {
    final uid = FirebaseUtils.currentUid;
    if (uid == null) return Stream.value(0);
    return FirebaseUtils.notificationsRef
        .where('recipientUid', isEqualTo: uid)
        .where('isRead', isEqualTo: false)
        .snapshots()
        .map((snap) => snap.docs.length);
  }
}

// Local field name constants used in this repo
class FirebaseField {
  static const ownerUid = 'ownerUid';
  static const updatedAt = 'updatedAt';
}
