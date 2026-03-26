import 'package:cloud_firestore/cloud_firestore.dart';
import '../../../../../Utils/Constant/enum.dart';
import '../../../../../Utils/Exceptions/exceptions.dart';
import '../../../../../Utils/Firebase/firebase_utils.dart';
import '../Model/signature_field_model.dart';
import '../../Notifications/Repository/notification_repository.dart';

class InAppSigningRepository {
  final NotificationRepository _notifRepo = NotificationRepository();
  Future<void> submitSigning({
    required String requestId,
    required String signerEmail,
    required String signerName,
    required List<SignatureFieldModel> updatedFields,
    String? signatureImageUrl,
  }) async {
    try {
      final ref = FirebaseUtils.signatureRequestDoc(requestId);
      final snap = await ref.get();
      if (!snap.exists) throw const SignatureRequestNotFoundException();

      final data = snap.data() as Map<String, dynamic>;
      final signers = List<Map<String, dynamic>>.from(data['signers'] ?? []);
      final ownerUid = data['requestedByUid'] as String;
      final documentName = data['documentName'] as String;

      // Update matching signer's fields and status
      final updatedSigners = signers.map((s) {
        if (s['signerEmail'] != signerEmail) return s;
        return {
          ...s,
          'status': 'signed',
          'signedAt': Timestamp.fromDate(DateTime.now()),
          'signatureImageUrl': signatureImageUrl,
          'tokenUsed': true,
          'fields': updatedFields.map((f) => f.toMap()).toList(),
        };
      }).toList();

      // Determine new request status
      final allSigned = updatedSigners
          .where((s) => s['role'] == 'needsToSign')
          .every((s) => s['status'] == 'signed');

      await ref.update({
        'signers': updatedSigners,
        'status': allSigned ? 'completed' : 'inProgress',
        'updatedAt': FieldValue.serverTimestamp(),
        if (allSigned) 'completedAt': Timestamp.fromDate(DateTime.now()),
      });

      // Notify owner — all signed or partial
      if (allSigned) {
        await _notifRepo.createNotification(
          recipientUid: ownerUid,
          type: NotificationType.documentCompleted,
          title: 'Document fully signed',
          body: '$documentName has been signed by all parties.',
          requestId: requestId,
          documentName: documentName,
          actorName: signerName,
        );
      } else {
        await _notifRepo.createNotification(
          recipientUid: ownerUid,
          type: NotificationType.documentSigned,
          title: '$signerName signed',
          body: '$signerName has signed $documentName.',
          requestId: requestId,
          documentName: documentName,
          actorName: signerName,
        );
      }
    } on FirebaseException catch (e) {
      throw firestoreExceptionFromCode(e.code);
    } catch (e) {
      if (e is AppException) rethrow;
      throw const AppException('Failed to submit signature.');
    }
  }

  // Update signer to declined and notify owner
  Future<void> submitDecline({
    required String requestId,
    required String signerEmail,
    required String signerName,
  }) async {
    try {
      final ref = FirebaseUtils.signatureRequestDoc(requestId);
      final snap = await ref.get();
      if (!snap.exists) throw const SignatureRequestNotFoundException();

      final data = snap.data() as Map<String, dynamic>;
      final signers = List<Map<String, dynamic>>.from(data['signers'] ?? []);
      final ownerUid = data['requestedByUid'] as String;
      final documentName = data['documentName'] as String;

      final updatedSigners = signers.map((s) {
        if (s['signerEmail'] != signerEmail) return s;
        return {
          ...s,
          'status': 'declined',
          'signedAt': Timestamp.fromDate(DateTime.now()),
          'tokenUsed': true,
        };
      }).toList();

      await ref.update({
        'signers': updatedSigners,
        'status': 'declined',
        'updatedAt': FieldValue.serverTimestamp(),
      });

      // Notify owner of decline
      await _notifRepo.createNotification(
        recipientUid: ownerUid,
        type: NotificationType.signatureDeclined,
        title: '$signerName declined to sign',
        body: '$signerName declined to sign $documentName.',
        requestId: requestId,
        documentName: documentName,
        actorName: signerName,
      );
    } on FirebaseException catch (e) {
      throw firestoreExceptionFromCode(e.code);
    } catch (e) {
      if (e is AppException) rethrow;
      throw const AppException('Failed to submit decline.');
    }
  }

  // Fetch a signature request by ID
  Future<Map<String, dynamic>?> getRequest(String requestId) async {
    try {
      final snap = await FirebaseUtils.signatureRequestDoc(requestId).get();
      if (!snap.exists) return null;
      return snap.data() as Map<String, dynamic>;
    } on FirebaseException catch (e) {
      throw firestoreExceptionFromCode(e.code);
    }
  }
}
