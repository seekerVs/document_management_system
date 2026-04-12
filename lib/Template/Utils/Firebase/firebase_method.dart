import 'package:cloud_firestore/cloud_firestore.dart';

class FirebaseMethod {
  FirebaseMethod._();

  static Future<DocumentReference?> addDocument({
    required CollectionReference collection,
    required Map<String, dynamic> data,
  }) async {
    try {
      return await collection.add(data);
    } catch (e) {
      rethrow;
    }
  }

  static Future<bool> setDocument({
    required DocumentReference ref,
    required Map<String, dynamic> data,
    bool merge = false,
  }) async {
    try {
      await ref.set(data, SetOptions(merge: merge));
      return true;
    } catch (e) {
      rethrow;
    }
  }

  static Future<DocumentSnapshot?> getDocument({
    required DocumentReference ref,
  }) async {
    try {
      final snap = await ref.get();
      return snap.exists ? snap : null;
    } catch (e) {
      rethrow;
    }
  }

  static Future<List<DocumentSnapshot>> getDocuments({
    required Query query,
  }) async {
    try {
      final snap = await query.get();
      return snap.docs;
    } catch (e) {
      rethrow;
    }
  }

  /// Stream a single document for real-time updates.
  static Stream<DocumentSnapshot> streamDocument({
    required DocumentReference ref,
  }) {
    return ref.snapshots();
  }

  /// Stream a collection query for real-time updates.
  static Stream<QuerySnapshot> streamDocuments({required Query query}) {
    return query.snapshots();
  }

  /// Update specific fields without overwriting the whole document.
  static Future<bool> updateDocument({
    required DocumentReference ref,
    required Map<String, dynamic> data,
  }) async {
    try {
      await ref.update(data);
      return true;
    } catch (e) {
      return false;
    }
  }

  /// Permanently delete a document.
  static Future<bool> deleteDocument({required DocumentReference ref}) async {
    try {
      await ref.delete();
      return true;
    } catch (e) {
      return false;
    }
  }

  /// Run multiple writes atomically. All succeed or all fail.
  static Future<bool> runBatch(
    Future<void> Function(WriteBatch batch) operations,
  ) async {
    try {
      final batch = FirebaseFirestore.instance.batch();
      await operations(batch);
      await batch.commit();
      return true;
    } catch (e) {
      return false;
    }
  }

  /// Run a transaction for read-then-write operations.
  static Future<T?> runTransaction<T>({
    required Future<T> Function(Transaction tx) operations,
  }) async {
    try {
      return await FirebaseFirestore.instance.runTransaction(operations);
    } catch (e) {
      return null;
    }
  }

  /// Increment a numeric field atomically (e.g. folder itemCount).
  static FieldValue increment(num value) => FieldValue.increment(value);

  /// Server-side timestamp — always use this instead of DateTime.now()
  /// for createdAt / updatedAt fields.
  static FieldValue get serverTimestamp => FieldValue.serverTimestamp();
}
