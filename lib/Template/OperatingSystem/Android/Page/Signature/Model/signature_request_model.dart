import 'package:cloud_firestore/cloud_firestore.dart';
import '../../../../../Utils/Constant/enum.dart';
import 'signature_field_model.dart';

class SignerModel {
  final String signerEmail;
  final String? signerUid;
  final String signerName;
  final int order;
  final SignerRole role;
  final SignerStatus status;
  final List<SignatureFieldModel> fields;
  final DateTime? signedAt;
  final String? signatureImageUrl;
  final String? signingToken;
  final DateTime? tokenExpiry;
  final bool tokenUsed;
  final String? ipAddress;
  final String? photoUrl;

  SignerModel({
    required this.signerEmail,
    this.signerUid,
    required this.signerName,
    this.order = 0,
    this.role = SignerRole.needsToSign,
    this.status = SignerStatus.pending,
    this.fields = const [],
    this.signedAt,
    this.signatureImageUrl,
    this.signingToken,
    this.tokenExpiry,
    this.tokenUsed = false,
    this.ipAddress,
    this.photoUrl,
  });

  factory SignerModel.fromMap(Map<String, dynamic> data) {
    return SignerModel(
      signerEmail: data['signerEmail'] ?? '',
      signerUid: data['signerUid'],
      signerName: data['signerName'] ?? '',
      order: data['order'] ?? 0,
      role: SignerRole.values.firstWhere(
        (r) => r.name == (data['role'] ?? 'needsToSign'),
        orElse: () => SignerRole.needsToSign,
      ),
      status: SignerStatus.values.firstWhere(
        (s) => s.name == (data['status'] ?? 'pending'),
        orElse: () => SignerStatus.pending,
      ),
      fields: (data['fields'] as List<dynamic>? ?? [])
          .map((f) => SignatureFieldModel.fromMap(f as Map<String, dynamic>))
          .toList(),
      signedAt: data['signedAt'] != null
          ? (data['signedAt'] as Timestamp).toDate()
          : null,
      signatureImageUrl: data['signatureImageUrl'],
      signingToken: data['signingToken'],
      tokenExpiry: data['tokenExpiry'] != null
          ? (data['tokenExpiry'] as Timestamp).toDate()
          : null,
      tokenUsed: data['tokenUsed'] ?? false,
      ipAddress: data['ipAddress'],
      photoUrl: data['photoUrl'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'signerEmail': signerEmail,
      'signerUid': signerUid,
      'signerName': signerName,
      'order': order,
      'role': role.name,
      'status': status.name,
      'fields': fields.map((f) => f.toMap()).toList(),
      'signedAt': signedAt?.toIso8601String(),
      'signatureImageUrl': signatureImageUrl,
      'signingToken': signingToken,
      'tokenExpiry': tokenExpiry?.toIso8601String(),
      'tokenUsed': tokenUsed,
      'ipAddress': ipAddress,
      'photoUrl': photoUrl,
    };
  }

  bool get isGuest => signerUid == null;
  bool get needsToSign => role == SignerRole.needsToSign;
  bool get isTokenValid =>
      signingToken != null &&
      !tokenUsed &&
      tokenExpiry != null &&
      tokenExpiry!.isAfter(DateTime.now());

  SignerModel copyWith({
    String? signerName,
    int? order,
    SignerRole? role,
    SignerStatus? status,
    List<SignatureFieldModel>? fields,
    DateTime? signedAt,
    String? signatureImageUrl,
    String? signingToken,
    DateTime? tokenExpiry,
    bool? tokenUsed,
    String? ipAddress,
    String? photoUrl,
  }) {
    return SignerModel(
      signerEmail: signerEmail,
      signerUid: signerUid,
      signerName: signerName ?? this.signerName,
      order: order ?? this.order,
      role: role ?? this.role,
      status: status ?? this.status,
      fields: fields ?? this.fields,
      signedAt: signedAt ?? this.signedAt,
      signatureImageUrl: signatureImageUrl ?? this.signatureImageUrl,
      signingToken: signingToken ?? this.signingToken,
      tokenExpiry: tokenExpiry ?? this.tokenExpiry,
      tokenUsed: tokenUsed ?? this.tokenUsed,
      ipAddress: ipAddress ?? this.ipAddress,
      photoUrl: photoUrl ?? this.photoUrl,
    );
  }
}

class RequestDocumentModel {
  final String documentId;
  final String documentName;
  final String documentUrl;
  final String storagePath;

  RequestDocumentModel({
    required this.documentId,
    required this.documentName,
    required this.documentUrl,
    required this.storagePath,
  });

  factory RequestDocumentModel.fromMap(Map<String, dynamic> data) {
    return RequestDocumentModel(
      documentId: data['documentId'] ?? '',
      documentName: data['documentName'] ?? '',
      documentUrl: data['documentUrl'] ?? '',
      storagePath: data['storagePath'] ?? '',
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'documentId': documentId,
      'documentName': documentName,
      'documentUrl': documentUrl,
      'storagePath': storagePath,
    };
  }
}

// ─── Signature Request model ──────────────────────────────────────────────────

class SignatureRequestModel {
  final String requestId;
  final List<RequestDocumentModel> documents;
  final String documentId; // Kept for legacy compatibility (points to documents[0])
  final String documentName;
  final String documentUrl;
  final String storagePath;
  final String requestedByUid;
  final String? requesterName;
  final List<SignerModel> signers;
  final SignatureRequestStatus status;
  final bool signingOrderEnabled;
  final List<String> signerEmails;
  final DateTime createdAt;
  final DateTime? completedAt;

  SignatureRequestModel({
    required this.requestId,
    required this.documents,
    required this.documentId,
    required this.documentName,
    required this.documentUrl,
    required this.storagePath,
    required this.requestedByUid,
    this.requesterName,
    required this.signers,
    required this.signerEmails,
    this.status = SignatureRequestStatus.pending,
    this.signingOrderEnabled = false,
    required this.createdAt,
    this.completedAt,
  });

  factory SignatureRequestModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    final List<RequestDocumentModel> docs = (data['documents'] as List<dynamic>? ?? [])
        .map((d) => RequestDocumentModel.fromMap(d as Map<String, dynamic>))
        .toList();

    return SignatureRequestModel(
      requestId: doc.id,
      documents: docs,
      documentId: data['documentId'] ?? (docs.isNotEmpty ? docs[0].documentId : ''),
      documentName: data['documentName'] ?? (docs.isNotEmpty ? docs[0].documentName : ''),
      documentUrl: data['documentUrl'] ?? (docs.isNotEmpty ? docs[0].documentUrl : ''),
      storagePath: data['storagePath'] ?? (docs.isNotEmpty ? docs[0].storagePath : ''),
      requestedByUid: data['requestedByUid'] ?? '',
      requesterName: data['requesterName'],
      signers: (data['signers'] as List<dynamic>? ?? [])
          .map((s) => SignerModel.fromMap(s as Map<String, dynamic>))
          .toList(),
      signerEmails: List<String>.from(data['signerEmails'] ?? []),
      status: SignatureRequestStatus.values.firstWhere(
        (s) => s.name == (data['status'] ?? 'pending'),
        orElse: () => SignatureRequestStatus.pending,
      ),
      signingOrderEnabled: data['signingOrderEnabled'] ?? false,
      createdAt: _parseDate(data['createdAt']) ?? DateTime.now(),
      completedAt: _parseDate(data['completedAt']),
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
      'documents': documents.map((d) => d.toMap()).toList(),
      'documentId': documentId,
      'documentName': documentName,
      'documentUrl': documentUrl,
      'storagePath': storagePath,
      'requestedByUid': requestedByUid,
      'requesterName': requesterName,
      'signers': signers.map((s) => s.toMap()).toList(),
      'signerEmails': signerEmails,
      'status': status.name,
      'signingOrderEnabled': signingOrderEnabled,
      'createdAt': Timestamp.fromDate(createdAt),
      'completedAt': completedAt != null
          ? Timestamp.fromDate(completedAt!)
          : null,
    };
  }

  List<SignerModel> get activeSigners =>
      signers.where((s) => s.role == SignerRole.needsToSign).toList();

  List<SignerModel> get copyRecipients =>
      signers.where((s) => s.role == SignerRole.receivesACopy).toList();

  int get pendingCount =>
      activeSigners.where((s) => s.status == SignerStatus.pending).length;

  int get signedCount =>
      activeSigners.where((s) => s.status == SignerStatus.signed).length;

  bool get allSigned =>
      activeSigners.every((s) => s.status == SignerStatus.signed);

  SignerModel? get nextSigner => activeSigners
      .where((s) => s.status == SignerStatus.pending)
      .toList()
      .firstOrNull;

  SignatureRequestModel copyWith({
    List<RequestDocumentModel>? documents,
    String? documentName,
    String? documentUrl,
    String? storagePath,
    String? requesterName,
    List<SignerModel>? signers,
    List<String>? signerEmails,
    SignatureRequestStatus? status,
    bool? signingOrderEnabled,
    DateTime? completedAt,
  }) {
    final nextDocs = documents ?? this.documents;
    return SignatureRequestModel(
      requestId: requestId,
      documents: nextDocs,
      documentId: nextDocs.isNotEmpty ? nextDocs[0].documentId : documentId,
      documentName: documentName ?? (nextDocs.isNotEmpty ? nextDocs[0].documentName : this.documentName),
      documentUrl: documentUrl ?? (nextDocs.isNotEmpty ? nextDocs[0].documentUrl : this.documentUrl),
      storagePath: storagePath ?? (nextDocs.isNotEmpty ? nextDocs[0].storagePath : this.storagePath),
      requestedByUid: requestedByUid,
      requesterName: requesterName ?? this.requesterName,
      signers: signers ?? this.signers,
      signerEmails: signerEmails ?? this.signerEmails,
      status: status ?? this.status,
      signingOrderEnabled: signingOrderEnabled ?? this.signingOrderEnabled,
      createdAt: createdAt,
      completedAt: completedAt ?? this.completedAt,
    );
  }
}
