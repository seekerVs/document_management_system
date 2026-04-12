enum UserRole { owner, signer, viewer }

enum DocumentStatus { draft, pending, completed }

enum DocumentFileType { pdf }

enum DocumentViewMode { list, grid }

enum SortOrder {
  nameAsc,
  nameDesc,
  dateNewest,
  dateOldest,
  sizeAsc,
  sizeDesc,
  type,
}

enum FolderColor { blue, green, red, yellow, purple, orange }

enum SignatureRequestStatus {
  pending,
  inProgress,
  completed,
  expired,
}

enum SignerStatus { pending, signed }

enum SignerRole { needsToSign, receivesACopy }

enum SignatureFieldType { signature, initials, dateSigned, textbox }

enum SignatureType { drawn, typed, uploaded }

enum TokenStatus { valid, expired, used, invalid }

enum ActivityAction {
  uploaded,
  signed,
  requestedSignature,
  deleted,
  moved,
  copied,
  renamed,
  completed,
  folderCreated,

  folderDeleted,
  shared,
}

enum NotificationType {
  signatureRequested,
  documentSigned,
  tokenExpired,
  documentCompleted,
  documentShared,
  generalInfo,
}

enum ViewState { idle, loading, success, error, empty }

enum OtpVerifyResult { valid, notFound, expired, alreadyUsed, wrongCode }
