import 'package:cloud_firestore/cloud_firestore.dart';

enum SignerStatus { pending, signed, declined }

enum SignatureRequestStatus { pending, completed, declined, expired }

// ─── Signer sub-model ────────────────────────────────────────────────────────

class SignerModel {
  final String signerEmail;
  final String? signerUid; // null if guest (no account)
  final String? signerName;
  final int order; // signing order index
  final SignerStatus status;
  final DateTime? signedAt;
  final String? signatureImageUrl;

  // Guest signer token fields
  final String? signingToken; // one-time UUID token
  final DateTime? tokenExpiry;
  final bool tokenUsed;
  final String? ipAddress; // audit trail

  SignerModel({
    required this.signerEmail,
    this.signerUid,
    this.signerName,
    this.order = 0,
    this.status = SignerStatus.pending,
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
      signerName: data['signerName'],
      order: data['order'] ?? 0,
      status: SignerStatus.values.firstWhere(
        (s) => s.name == (data['status'] ?? 'pending'),
        orElse: () => SignerStatus.pending,
      ),
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
      'status': status.name,
      'signedAt': signedAt != null ? Timestamp.fromDate(signedAt!) : null,
      'signatureImageUrl': signatureImageUrl,
      'signingToken': signingToken,
      'tokenExpiry':
          tokenExpiry != null ? Timestamp.fromDate(tokenExpiry!) : null,
      'tokenUsed': tokenUsed,
      'ipAddress': ipAddress,
    };
  }

  bool get isGuest => signerUid == null;
  bool get isTokenValid =>
      signingToken != null &&
      !tokenUsed &&
      tokenExpiry != null &&
      tokenExpiry!.isAfter(DateTime.now());

  SignerModel copyWith({
    String? signerName,
    SignerStatus? status,
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
      order: order,
      status: status ?? this.status,
      signedAt: signedAt ?? this.signedAt,
      signatureImageUrl: signatureImageUrl ?? this.signatureImageUrl,
      signingToken: signingToken ?? this.signingToken,
      tokenExpiry: tokenExpiry ?? this.tokenExpiry,
      tokenUsed: tokenUsed ?? this.tokenUsed,
      ipAddress: ipAddress ?? this.ipAddress,
    );
  }
}

// ─── Signature Request model ─────────────────────────────────────────────────

class SignatureRequestModel {
  final String requestId;
  final String documentId;
  final String requestedByUid;
  final List<SignerModel> signers;
  final SignatureRequestStatus status;
  final DateTime createdAt;
  final DateTime? completedAt;

  SignatureRequestModel({
    required this.requestId,
    required this.documentId,
    required this.requestedByUid,
    required this.signers,
    this.status = SignatureRequestStatus.pending,
    required this.createdAt,
    this.completedAt,
  });

  factory SignatureRequestModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    final signersList = (data['signers'] as List<dynamic>? ?? [])
        .map((s) => SignerModel.fromMap(s as Map<String, dynamic>))
        .toList();

    return SignatureRequestModel(
      requestId: doc.id,
      documentId: data['documentId'] ?? '',
      requestedByUid: data['requestedByUid'] ?? '',
      signers: signersList,
      status: SignatureRequestStatus.values.firstWhere(
        (s) => s.name == (data['status'] ?? 'pending'),
        orElse: () => SignatureRequestStatus.pending,
      ),
      createdAt: (data['createdAt'] as Timestamp).toDate(),
      completedAt: data['completedAt'] != null
          ? (data['completedAt'] as Timestamp).toDate()
          : null,
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'documentId': documentId,
      'requestedByUid': requestedByUid,
      'signers': signers.map((s) => s.toMap()).toList(),
      'status': status.name,
      'createdAt': Timestamp.fromDate(createdAt),
      'completedAt':
          completedAt != null ? Timestamp.fromDate(completedAt!) : null,
    };
  }

  // Helpers
  int get pendingCount =>
      signers.where((s) => s.status == SignerStatus.pending).length;

  int get signedCount =>
      signers.where((s) => s.status == SignerStatus.signed).length;

  bool get allSigned => signers.every((s) => s.status == SignerStatus.signed);

  SignerModel? get nextSigner => signers
      .where((s) => s.status == SignerStatus.pending)
      .toList()
      .firstOrNull;

  SignatureRequestModel copyWith({
    List<SignerModel>? signers,
    SignatureRequestStatus? status,
    DateTime? completedAt,
  }) {
    return SignatureRequestModel(
      requestId: requestId,
      documentId: documentId,
      requestedByUid: requestedByUid,
      signers: signers ?? this.signers,
      status: status ?? this.status,
      createdAt: createdAt,
      completedAt: completedAt ?? this.completedAt,
    );
  }
}
