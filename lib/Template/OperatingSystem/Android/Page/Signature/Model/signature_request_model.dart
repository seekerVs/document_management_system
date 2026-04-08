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
    );
  }
}

// ─── Signature Request model ──────────────────────────────────────────────────

class SignatureRequestModel {
  final String requestId;
  final String documentId;
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
    return SignatureRequestModel(
      requestId: doc.id,
      documentId: data['documentId'] ?? '',
      documentName: data['documentName'] ?? '',
      documentUrl: data['documentUrl'] ?? '',
      storagePath: data['storagePath'] ?? '',
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
    return SignatureRequestModel(
      requestId: requestId,
      documentId: documentId,
      documentName: documentName ?? this.documentName,
      documentUrl: documentUrl ?? this.documentUrl,
      storagePath: storagePath ?? this.storagePath,
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
