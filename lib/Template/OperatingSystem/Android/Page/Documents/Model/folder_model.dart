import 'package:cloud_firestore/cloud_firestore.dart';

class FolderModel {
  final String folderId;
  final String ownerUid;
  final String name;
  final int itemCount;
  final DateTime createdAt;
  final DateTime updatedAt;

  FolderModel({
    required this.folderId,
    required this.ownerUid,
    required this.name,
    this.itemCount = 0,
    required this.createdAt,
    required this.updatedAt,
  });

  factory FolderModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return FolderModel(
      folderId: doc.id,
      ownerUid: data['ownerUid'] ?? '',
      name: data['name'] ?? '',
      itemCount: data['itemCount'] ?? 0,
      createdAt: (data['createdAt'] as Timestamp).toDate(),
      updatedAt: (data['updatedAt'] as Timestamp).toDate(),
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'ownerUid': ownerUid,
      'name': name,
      'itemCount': itemCount,
      'createdAt': Timestamp.fromDate(createdAt),
      'updatedAt': Timestamp.fromDate(updatedAt),
    };
  }

  FolderModel copyWith({String? name, int? itemCount, DateTime? updatedAt}) {
    return FolderModel(
      folderId: folderId,
      ownerUid: ownerUid,
      name: name ?? this.name,
      itemCount: itemCount ?? this.itemCount,
      createdAt: createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}
