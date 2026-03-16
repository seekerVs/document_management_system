import 'package:cloud_firestore/cloud_firestore.dart';

enum NotificationType {
  signatureRequested,
  documentSigned,
  signatureDeclined,
  tokenExpired,
  documentCompleted,
}

class NotificationModel {
  final String notificationId;
  final String recipientUid;
  final String title;
  final String message;
  final String? documentId;
  final NotificationType type;
  final bool isRead;
  final DateTime createdAt;

  NotificationModel({
    required this.notificationId,
    required this.recipientUid,
    required this.title,
    required this.message,
    this.documentId,
    required this.type,
    this.isRead = false,
    required this.createdAt,
  });

  factory NotificationModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return NotificationModel(
      notificationId: doc.id,
      recipientUid: data['recipientUid'] ?? '',
      title: data['title'] ?? '',
      message: data['message'] ?? '',
      documentId: data['documentId'],
      type: NotificationType.values.firstWhere(
        (t) => t.name == (data['type'] ?? 'signatureRequested'),
        orElse: () => NotificationType.signatureRequested,
      ),
      isRead: data['isRead'] ?? false,
      createdAt: (data['createdAt'] as Timestamp).toDate(),
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'recipientUid': recipientUid,
      'title': title,
      'message': message,
      'documentId': documentId,
      'type': type.name,
      'isRead': isRead,
      'createdAt': Timestamp.fromDate(createdAt),
    };
  }

  NotificationModel copyWith({bool? isRead}) {
    return NotificationModel(
      notificationId: notificationId,
      recipientUid: recipientUid,
      title: title,
      message: message,
      documentId: documentId,
      type: type,
      isRead: isRead ?? this.isRead,
      createdAt: createdAt,
    );
  }
}
