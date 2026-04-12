import 'package:cloud_firestore/cloud_firestore.dart';
import '../../../../../Utils/Api/api_service.dart';
import '../../../../../Utils/Exceptions/exceptions.dart';
import '../../../../../Utils/Firebase/firebase_utils.dart';
import '../Model/signature_field_model.dart';

class InAppSigningRepository {
  Future<void> submitSigning({
    required String requestId,
    required String signerEmail,
    required String signerName,
    required List<SignatureFieldModel> updatedFields,
    String? signatureImageUrl,
  }) async {
    try {
      final uid = FirebaseUtils.currentUid;

      final result = await ApiService.post('/signing/submit-signature', {
        'requestId': requestId,
        'signerEmail': signerEmail,
        'signerName': signerName,
        'updatedFields': updatedFields.map((f) => f.toMap()).toList(),
        'signatureImageUrl': ?signatureImageUrl,
        'signerUid': ?uid,
      });

      if (!result.success) throw ApiException(result.message);
    } on ApiException {
      rethrow;
    } catch (e) {
      throw const AppException('Failed to submit signature via server.');
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
