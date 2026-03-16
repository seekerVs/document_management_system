import 'package:cloud_firestore/cloud_firestore.dart';

// 📁 lib/Template/Utils/Firebase/firebase_method.dart
//
// Generic reusable Firestore operations.
// All methods return a result type — never throw directly to the UI.
// Repositories call these instead of writing raw Firestore calls everywhere.

class FirebaseMethod {
  FirebaseMethod._();

  // ─── Create ──────────────────────────────────────────────────────────────

  /// Add a document with an auto-generated ID.
  static Future<DocumentReference?> addDocument({
    required CollectionReference collection,
    required Map<String, dynamic> data,
  }) async {
    try {
      return await collection.add(data);
    } catch (e) {
      return null;
    }
  }

  /// Set a document with a specific ID (creates or overwrites).
  static Future<bool> setDocument({
    required DocumentReference ref,
    required Map<String, dynamic> data,
    bool merge = false,
  }) async {
    try {
      await ref.set(data, SetOptions(merge: merge));
      return true;
    } catch (e) {
      return false;
    }
  }

  // ─── Read ────────────────────────────────────────────────────────────────

  /// Fetch a single document by reference.
  static Future<DocumentSnapshot?> getDocument({
    required DocumentReference ref,
  }) async {
    try {
      final snap = await ref.get();
      return snap.exists ? snap : null;
    } catch (e) {
      return null;
    }
  }

  /// Fetch multiple documents from a query.
  static Future<List<DocumentSnapshot>> getDocuments({
    required Query query,
  }) async {
    try {
      final snap = await query.get();
      return snap.docs;
    } catch (e) {
      return [];
    }
  }

  /// Stream a single document for real-time updates.
  static Stream<DocumentSnapshot> streamDocument({
    required DocumentReference ref,
  }) {
    return ref.snapshots();
  }

  /// Stream a collection query for real-time updates.
  static Stream<QuerySnapshot> streamDocuments({
    required Query query,
  }) {
    return query.snapshots();
  }

  // ─── Update ──────────────────────────────────────────────────────────────

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

  // ─── Delete ──────────────────────────────────────────────────────────────

  /// Permanently delete a document.
  static Future<bool> deleteDocument({
    required DocumentReference ref,
  }) async {
    try {
      await ref.delete();
      return true;
    } catch (e) {
      return false;
    }
  }

  // ─── Batch & Transaction ─────────────────────────────────────────────────

  /// Run multiple writes atomically. All succeed or all fail.
  static Future<bool> runBatch({
    required Future<void> Function(WriteBatch batch) operations,
  }) async {
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

  // ─── Helpers ─────────────────────────────────────────────────────────────

  /// Increment a numeric field atomically (e.g. folder itemCount).
  static FieldValue increment(num value) =>
      FieldValue.increment(value);

  /// Server-side timestamp — always use this instead of DateTime.now()
  /// for createdAt / updatedAt fields.
  static FieldValue get serverTimestamp => FieldValue.serverTimestamp();
}
