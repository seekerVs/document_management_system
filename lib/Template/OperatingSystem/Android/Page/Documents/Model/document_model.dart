import 'package:cloud_firestore/cloud_firestore.dart';
import '../../../../../Utils/Constant/enum.dart';

class DocumentModel {
  final String documentId;
  final String ownerUid;
  final String? folderId;
  final String name;
  final String fileUrl;
  final String? storagePath;
  final DocumentFileType fileType;
  final double fileSizeMB;
  final DocumentStatus status;
  final List<String> authorizedEmails;
  final DateTime createdAt;
  final DateTime updatedAt;

  DocumentModel({
    required this.documentId,
    required this.ownerUid,
    this.folderId,
    required this.name,
    required this.fileUrl,
    this.storagePath,
    this.fileType = DocumentFileType.pdf,
    required this.fileSizeMB,
    this.status = DocumentStatus.draft,
    this.authorizedEmails = const [],
    required this.createdAt,
    required this.updatedAt,
  });

  factory DocumentModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    final now = DateTime.now();
    return DocumentModel(
      documentId: doc.id,
      ownerUid: data['ownerUid'] ?? '',
      folderId: data['folderId'],
      name: data['name'] ?? '',
      fileUrl: data['fileUrl'] ?? '',
      storagePath: data['storagePath'],
      fileType: DocumentFileType.values.firstWhere(
        (t) => t.name == (data['fileType'] ?? 'pdf'),
        orElse: () => DocumentFileType.pdf,
      ),
      fileSizeMB: (data['fileSizeMB'] ?? 0).toDouble(),
      status: DocumentStatus.values.firstWhere(
        (s) => s.name == (data['status'] ?? 'draft'),
        orElse: () => DocumentStatus.draft,
      ),
      authorizedEmails: List<String>.from(data['authorizedEmails'] ?? []),
      createdAt: _parseDate(data['createdAt']) ?? now,
      updatedAt: _parseDate(data['updatedAt']) ?? now,
    );
  }

  // Handle both Timestamp and ISO string for backwards compatibility
  static DateTime? _parseDate(dynamic value) {
    if (value == null) return null;
    if (value is Timestamp) return value.toDate();
    if (value is String) return DateTime.tryParse(value);
    return null;
  }

  Map<String, dynamic> toFirestore() {
    return {
      'ownerUid': ownerUid,
      'folderId': folderId,
      'name': name,
      'fileUrl': fileUrl,
      'storagePath': storagePath,
      'fileType': fileType.name,
      'fileSizeMB': fileSizeMB,
      'status': status.name,
      'authorizedEmails': authorizedEmails,
      'createdAt': Timestamp.fromDate(createdAt),
      'updatedAt': Timestamp.fromDate(updatedAt),
    };
  }

  DocumentModel copyWith({
    String? folderId,
    String? name,
    String? fileUrl,
    String? storagePath,
    DocumentFileType? fileType,
    double? fileSizeMB,
    DocumentStatus? status,
    List<String>? authorizedEmails,
    DateTime? updatedAt,
  }) {
    return DocumentModel(
      documentId: documentId,
      ownerUid: ownerUid,
      folderId: folderId ?? this.folderId,
      name: name ?? this.name,
      fileUrl: fileUrl ?? this.fileUrl,
      storagePath: storagePath ?? this.storagePath,
      fileType: fileType ?? this.fileType,
      fileSizeMB: fileSizeMB ?? this.fileSizeMB,
      status: status ?? this.status,
      authorizedEmails: authorizedEmails ?? this.authorizedEmails,
      createdAt: createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  bool get isPdf => fileType == DocumentFileType.pdf;
  bool get isPending => status == DocumentStatus.pending;
  bool get isCompleted => status == DocumentStatus.completed;
}
