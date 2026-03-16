import '../../../../../../../../Template/Utils/Firebase/firebase_method.dart';
import '../../../../../../../../Template/Utils/Firebase/firebase_utils.dart';
import '../../../../../../../../Template/Utils/Helpers/base_repository.dart';
import '../../Activity/Model/activity_model.dart';
import '../../Documents/Model/document_model.dart';
import '../../Signature/Model/signature_request_model.dart';

// 📁 lib/Template/OperatingSystem/Android/Page/Welcome/Repository/dashboard_repository.dart

class DashboardRepository extends BaseRepository {
  // ─── Recent documents (last 5) ───────────────────────────────────────────

  Future<List<DocumentModel>> getRecentDocuments() => handleRequest(() async {
    final docs = await FirebaseMethod.getDocuments(
      query: FirebaseUtils.documentsRef
          .where(FirebaseField.ownerUid, isEqualTo: currentUid)
          .orderBy(FirebaseField.updatedAt, descending: true)
          .limit(5),
    );
    return docs.map((d) => DocumentModel.fromFirestore(d)).toList();
  }).then((v) => v ?? []);

  // ─── Assigned tasks — docs where user is a pending signer ────────────────

  Future<List<SignatureRequestModel>> getAssignedTasks() =>
      handleRequest(() async {
        final email = FirebaseUtils.currentEmail ?? '';
        final snap = await FirebaseUtils.signatureRequestsRef
            .where('status', isEqualTo: 'pending')
            .orderBy('createdAt', descending: true)
            .limit(10)
            .get();

        final all = snap.docs
            .map((d) => SignatureRequestModel.fromFirestore(d))
            .toList();

        // Filter to requests where this user/email is a pending signer
        return all.where((req) {
          return req.signers.any(
            (s) =>
                (s.signerUid == FirebaseUtils.currentUid ||
                    s.signerEmail == email) &&
                s.status == SignerStatus.pending,
          );
        }).toList();
      }).then((v) => v ?? []);

  // ─── Recent activity (last 5) ────────────────────────────────────────────

  Future<List<ActivityModel>> getRecentActivity() => handleRequest(() async {
    final docs = await FirebaseMethod.getDocuments(
      query: FirebaseUtils.activitiesRef
          .where('actorUid', isEqualTo: currentUid)
          .orderBy('timestamp', descending: true)
          .limit(5),
    );
    return docs.map((d) => ActivityModel.fromFirestore(d)).toList();
  }).then((v) => v ?? []);

  // ─── Unread notification count ────────────────────────────────────────────

  Stream<int> unreadNotificationCount() {
    return FirebaseUtils.notificationsRef
        .where('recipientUid', isEqualTo: currentUid)
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
