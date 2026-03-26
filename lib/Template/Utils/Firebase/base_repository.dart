import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../Exceptions/exceptions.dart';
import 'firebase_utils.dart';

// 📁 lib/Template/Utils/Helpers/base_repository.dart
//
// Abstract base class that all feature repositories extend.
// Provides shared Firestore helpers and standardised error handling
// so each repository only needs to write its own query logic.

abstract class BaseRepository {
  // ─── Shared access ───────────────────────────────────────────────────────
  // FirebaseUtils and FirebaseMethod are static-only classes.
  // Use them directly: FirebaseUtils.currentUid, FirebaseMethod.getDocument()

  String get currentUid {
    final uid = FirebaseUtils.currentUid;
    if (uid == null) throw const SessionExpiredException();
    return uid;
  }

  // Nullable version — use this when you want to guard instead of throw
  String? get currentUidOrNull => FirebaseUtils.currentUid;

  // ─── Error handler ───────────────────────────────────────────────────────

  /// Wrap any async repository call with this to get typed exceptions.
  ///
  /// Usage in a repository:
  /// ```dart
  /// Future<UserModel?> getUser(String uid) =>
  ///     handleRequest(() async {
  ///       final doc = await FirebaseMethod.getDocument(ref: FirebaseUtils.userDoc(uid));
  ///       return doc != null ? UserModel.fromFirestore(doc) : null;
  ///     });
  /// ```
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

  // ─── Pagination helper ───────────────────────────────────────────────────

  /// Returns a paginated query starting after [lastDoc].
  /// Pass null for [lastDoc] to get the first page.
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
