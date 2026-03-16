import 'package:cloud_firestore/cloud_firestore.dart';

enum DocumentStatus { draft, pending, completed, declined }

enum DocumentFileType { pdf, image, other }

class DocumentModel {
  final String documentId;
  final String ownerUid;
  final String? folderId; // null = root level
  final String name;
  final String fileUrl; // Firebase Storage URL
  final DocumentFileType fileType;
  final double fileSizeMB;
  final DocumentStatus status;
  final DateTime createdAt;
  final DateTime updatedAt;

  DocumentModel({
    required this.documentId,
    required this.ownerUid,
    this.folderId,
    required this.name,
    required this.fileUrl,
    this.fileType = DocumentFileType.pdf,
    required this.fileSizeMB,
    this.status = DocumentStatus.draft,
    required this.createdAt,
    required this.updatedAt,
  });

  factory DocumentModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return DocumentModel(
      documentId: doc.id,
      ownerUid: data['ownerUid'] ?? '',
      folderId: data['folderId'],
      name: data['name'] ?? '',
      fileUrl: data['fileUrl'] ?? '',
      fileType: DocumentFileType.values.firstWhere(
        (t) => t.name == (data['fileType'] ?? 'pdf'),
        orElse: () => DocumentFileType.pdf,
      ),
      fileSizeMB: (data['fileSizeMB'] ?? 0).toDouble(),
      status: DocumentStatus.values.firstWhere(
        (s) => s.name == (data['status'] ?? 'draft'),
        orElse: () => DocumentStatus.draft,
      ),
      createdAt: (data['createdAt'] as Timestamp).toDate(),
      updatedAt: (data['updatedAt'] as Timestamp).toDate(),
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'ownerUid': ownerUid,
      'folderId': folderId,
      'name': name,
      'fileUrl': fileUrl,
      'fileType': fileType.name,
      'fileSizeMB': fileSizeMB,
      'status': status.name,
      'createdAt': Timestamp.fromDate(createdAt),
      'updatedAt': Timestamp.fromDate(updatedAt),
    };
  }

  DocumentModel copyWith({
    String? folderId,
    String? name,
    String? fileUrl,
    DocumentFileType? fileType,
    double? fileSizeMB,
    DocumentStatus? status,
    DateTime? updatedAt,
  }) {
    return DocumentModel(
      documentId: documentId,
      ownerUid: ownerUid,
      folderId: folderId ?? this.folderId,
      name: name ?? this.name,
      fileUrl: fileUrl ?? this.fileUrl,
      fileType: fileType ?? this.fileType,
      fileSizeMB: fileSizeMB ?? this.fileSizeMB,
      status: status ?? this.status,
      createdAt: createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  bool get isPdf => fileType == DocumentFileType.pdf;
  bool get isPending => status == DocumentStatus.pending;
  bool get isCompleted => status == DocumentStatus.completed;
}
