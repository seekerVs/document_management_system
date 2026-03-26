import 'package:cloud_firestore/cloud_firestore.dart';
import '../../../../../Utils/Constant/enum.dart';

class NotificationModel {
  final String notificationId;
  final String recipientUid;
  final NotificationType type;
  final String title;
  final String body;
  final bool isRead;
  final String? requestId;
  final String? documentName;
  final String? actorName;
  final DateTime createdAt;

  NotificationModel({
    required this.notificationId,
    required this.recipientUid,
    required this.type,
    required this.title,
    required this.body,
    this.isRead = false,
    this.requestId,
    this.documentName,
    this.actorName,
    required this.createdAt,
  });

  factory NotificationModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return NotificationModel(
      notificationId: doc.id,
      recipientUid: data['recipientUid'] ?? '',
      type: NotificationType.values.firstWhere(
        (t) => t.name == (data['type'] ?? 'generalInfo'),
        orElse: () => NotificationType.generalInfo,
      ),
      title: data['title'] ?? '',
      body: data['body'] ?? '',
      isRead: data['isRead'] ?? false,
      requestId: data['requestId'],
      documentName: data['documentName'],
      actorName: data['actorName'],
      createdAt: (data['createdAt'] as Timestamp).toDate(),
    );
  }

  Map<String, dynamic> toFirestore() => {
    'recipientUid': recipientUid,
    'type': type.name,
    'title': title,
    'body': body,
    'isRead': isRead,
    'requestId': requestId,
    'documentName': documentName,
    'actorName': actorName,
    'createdAt': Timestamp.fromDate(createdAt),
  };
}
