import 'package:cloud_firestore/cloud_firestore.dart';
import '../../../../../Utils/Constant/enum.dart';
import '../../../../../Utils/Exceptions/exceptions.dart';
import '../../../../../Utils/Firebase/firebase_utils.dart';
import '../Model/notification_model.dart';

class NotificationRepository {
  // Write a notification doc for the owner
  Future<void> createNotification({
    required String recipientUid,
    required NotificationType type,
    required String title,
    required String body,
    String? requestId,
    String? documentName,
    String? actorName,
  }) async {
    try {
      final ref = FirebaseUtils.notificationsRef.doc();
      await ref.set({
        'recipientUid': recipientUid,
        'type': type.name,
        'title': title,
        'body': body,
        'isRead': false,
        'requestId': requestId,
        'documentName': documentName,
        'actorName': actorName,
        'createdAt': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      // We don't want to block the main process if a notification fails to send
    }
  }

  // Fetch all notifications for current user
  Future<List<NotificationModel>> getNotifications() async {
    try {
      final uid = FirebaseUtils.currentUid;
      if (uid == null) throw const SessionExpiredException();

      final snap = await FirebaseUtils.notificationsRef
          .where('recipientUid', isEqualTo: uid)
          .orderBy('createdAt', descending: true)
          .get();

      return snap.docs.map((d) => NotificationModel.fromFirestore(d)).toList();
    } on FirebaseException catch (e) {
      throw firestoreExceptionFromCode(e.code);
    }
  }

  // Stream unread count for badge
  Stream<int> unreadCountStream() {
    final uid = FirebaseUtils.currentUid;
    if (uid == null) return Stream.value(0);

    return FirebaseUtils.notificationsRef
        .where('recipientUid', isEqualTo: uid)
        .where('isRead', isEqualTo: false)
        .snapshots()
        .map((snap) => snap.docs.length);
  }

  // Mark a single notification as read
  Future<void> markAsRead(String notificationId) async {
    try {
      await FirebaseUtils.notificationDoc(
        notificationId,
      ).update({'isRead': true});
    } on FirebaseException catch (e) {
      throw firestoreExceptionFromCode(e.code);
    }
  }

  // Mark all notifications as read
  Future<void> markAllAsRead() async {
    try {
      final uid = FirebaseUtils.currentUid;
      if (uid == null) throw const SessionExpiredException();

      final snap = await FirebaseUtils.notificationsRef
          .where('recipientUid', isEqualTo: uid)
          .where('isRead', isEqualTo: false)
          .get();

      final batch = FirebaseUtils.firestore.batch();
      for (final doc in snap.docs) {
        batch.update(doc.reference, {'isRead': true});
      }
      await batch.commit();
    } on FirebaseException catch (e) {
      throw firestoreExceptionFromCode(e.code);
    }
  }
}
