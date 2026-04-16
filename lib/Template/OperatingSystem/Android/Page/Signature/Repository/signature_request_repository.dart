import 'package:flutter/foundation.dart';
import '../../../../../Utils/Api/api_service.dart';
import '../../../../../Utils/Exceptions/exceptions.dart';
import '../../../../../Utils/Firebase/firebase_utils.dart';
import '../Model/signature_request_model.dart';
import '../../../../../Utils/Constant/enum.dart';
import '../../Activity/Repository/activity_repository.dart';

class SignatureRequestRepository {
  // Submit signature request to Express — creates Firestore doc + sends emails
  Future<String> createRequest(
    SignatureRequestModel request,
    String requesterName, {
    String? requesterEmail,
    String? message,
  }) async {
    final result = await ApiService.post('/signing/create-request', {
      'requestedByUid': request.requestedByUid,
      'requesterName': requesterName,
      'documents': request.documents.map((d) => d.toMap()).toList(),
      'documentId': request.documentId,
      'documentName': request.documentName,
      'documentUrl': request.documentUrl,
      'storagePath': request.storagePath,
      'signingOrderEnabled': request.signingOrderEnabled,
      'signers': request.signers.map((s) => s.toMap()).toList(),
      'requesterEmail': requesterEmail,
      if (message != null && message.isNotEmpty) 'message': message,
    });

    if (!result.success) throw ApiException(result.message);

    final reqId = result.data['requestId'] as String;

    await ActivityRepository().logActivity(
      documentId: request.documentId,
      documentName: request.documentName,
      action: ActivityAction.requestedSignature,
    );

    return reqId;
  }

  // Fetch all requests where current user is a signer
  Future<List<SignatureRequestModel>> getAssignedRequests() async {
    final email = FirebaseUtils.currentEmail;
    if (email == null) throw const SessionExpiredException();

    final queryEmail = email.trim().toLowerCase();
    debugPrint('Fetching tasks for: $queryEmail');

    final snap = await FirebaseUtils.signatureRequestsRef
        .where('signerEmails', arrayContains: queryEmail)
        .orderBy('createdAt', descending: true)
        .get();

    return snap.docs
        .map((d) => SignatureRequestModel.fromFirestore(d))
        .toList();
  }

  // Fetch all requests created by current user
  Future<List<SignatureRequestModel>> getSentRequests() async {
    final uid = FirebaseUtils.currentUid;
    if (uid == null) throw const SessionExpiredException();

    final snap = await FirebaseUtils.signatureRequestsRef
        .where('requestedByUid', isEqualTo: uid)
        .orderBy('createdAt', descending: true)
        .get();

    return snap.docs
        .map((d) => SignatureRequestModel.fromFirestore(d))
        .toList();
  }
}
