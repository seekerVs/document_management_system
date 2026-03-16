import 'package:cloud_firestore/cloud_firestore.dart';

enum ActivityAction {
  uploaded,
  signed,
  requestedSignature,
  deleted,
  moved,
  copied,
  declined,
  folderCreated,
}

class ActivityModel {
  final String activityId;
  final String documentId;
  final String? documentName;
  final String actorUid;
  final String actorName;
  final ActivityAction action;
  final DateTime timestamp;

  ActivityModel({
    required this.activityId,
    required this.documentId,
    this.documentName,
    required this.actorUid,
    required this.actorName,
    required this.action,
    required this.timestamp,
  });

  factory ActivityModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return ActivityModel(
      activityId: doc.id,
      documentId: data['documentId'] ?? '',
      documentName: data['documentName'],
      actorUid: data['actorUid'] ?? '',
      actorName: data['actorName'] ?? '',
      action: ActivityAction.values.firstWhere(
        (a) => a.name == (data['action'] ?? 'uploaded'),
        orElse: () => ActivityAction.uploaded,
      ),
      timestamp: (data['timestamp'] as Timestamp).toDate(),
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'documentId': documentId,
      'documentName': documentName,
      'actorUid': actorUid,
      'actorName': actorName,
      'action': action.name,
      'timestamp': Timestamp.fromDate(timestamp),
    };
  }

  // Human-readable description
  String get description {
    switch (action) {
      case ActivityAction.uploaded:
        return '$actorName uploaded ${documentName ?? 'a document'}';
      case ActivityAction.signed:
        return '$actorName signed ${documentName ?? 'a document'}';
      case ActivityAction.requestedSignature:
        return '$actorName requested a signature on ${documentName ?? 'a document'}';
      case ActivityAction.deleted:
        return '$actorName deleted ${documentName ?? 'a document'}';
      case ActivityAction.moved:
        return '$actorName moved ${documentName ?? 'a document'}';
      case ActivityAction.copied:
        return '$actorName copied ${documentName ?? 'a document'}';
      case ActivityAction.declined:
        return '$actorName declined to sign ${documentName ?? 'a document'}';
      case ActivityAction.folderCreated:
        return '$actorName created a new folder';
    }
  }
}
