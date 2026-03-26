import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../Exceptions/exceptions.dart';
import 'firebase_utils.dart';

abstract class BaseRepository {
  String get currentUid {
    final uid = FirebaseUtils.currentUid;
    if (uid == null) throw const SessionExpiredException();
    return uid;
  }

  // Nullable version — use this when you want to guard instead of throw
  String? get currentUidOrNull => FirebaseUtils.currentUid;

  Future<T?> handleRequest<T>(Future<T?> Function() request) async {
    try {
      return await request();
    } on FirebaseAuthException catch (e) {
      throw authExceptionFromCode(e.code);
    } on FirebaseException catch (e) {
      if (e.code == 'permission-denied') {
        throw const PermissionDeniedException();
      }
      if (e.code == 'unavailable') throw const NetworkException();
      throw AppException('Firebase error: ${e.message}');
    } on AppException {
      rethrow;
    } catch (e) {
      throw AppException('Unexpected error: $e');
    }
  }

  Query paginate({
    required Query query,
    required int limit,
    DocumentSnapshot? lastDoc,
  }) {
    Query q = query.limit(limit);
    if (lastDoc != null) q = q.startAfterDocument(lastDoc);
    return q;
  }
}
