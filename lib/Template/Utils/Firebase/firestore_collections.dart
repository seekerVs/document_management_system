class FirestoreCollections {
  FirestoreCollections._();

  static const String users = 'users';
  static const String folders = 'folders';
  static const String documents = 'documents';
  static const String signatureRequests = 'signature_requests';
  static const String activities = 'activities';
  static const String notifications = 'notifications';
  static const String signingTokens = 'signing_tokens';
}

class FirestoreFields {
  FirestoreFields._();

  // Common
  static const String createdAt = 'createdAt';
  static const String updatedAt = 'updatedAt';

  // User
  static const String uid = 'uid';
  static const String email = 'email';
  static const String name = 'name';
  static const String role = 'role';

  // Document
  static const String ownerUid = 'ownerUid';
  static const String folderId = 'folderId';
  static const String status = 'status';
  static const String fileUrl = 'fileUrl';

  // Signature request
  static const String documentId = 'documentId';
  static const String requestedByUid = 'requestedByUid';
  static const String signers = 'signers';

  // Signer
  static const String signerEmail = 'signerEmail';
  static const String signerUid = 'signerUid';
  static const String signingToken = 'signingToken';
  static const String tokenExpiry = 'tokenExpiry';
  static const String tokenUsed = 'tokenUsed';

  // Notification
  static const String recipientUid = 'recipientUid';
  static const String isRead = 'isRead';

  // Activity
  static const String actorUid = 'actorUid';
  static const String action = 'action';
  static const String timestamp = 'timestamp';
}
