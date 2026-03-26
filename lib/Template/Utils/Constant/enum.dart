enum UserRole { owner, signer, viewer }

// ─── Document ─────────────────────────────────────────────────────────────────

enum DocumentStatus { draft, pending, completed, declined }

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

// ─── Folder ───────────────────────────────────────────────────────────────────

enum FolderColor { blue, green, red, yellow, purple, orange }

// ─── Signature ────────────────────────────────────────────────────────────────

enum SignatureRequestStatus {
  pending,
  inProgress,
  completed,
  declined,
  expired,
}

enum SignerStatus { pending, signed, declined }

enum SignerRole { needsToSign, receivesACopy }

enum SignatureFieldType { signature, initials, dateSigned, textbox }

enum SignatureType { drawn, typed, uploaded }

enum TokenStatus { valid, expired, used, invalid }

// ─── Activity ─────────────────────────────────────────────────────────────────

enum ActivityAction {
  uploaded,
  signed,
  requestedSignature,
  deleted,
  moved,
  copied,
  renamed,
  declined,
  folderCreated,
  folderDeleted,
  shared,
}

// ─── Notification ─────────────────────────────────────────────────────────────

enum NotificationType {
  signatureRequested,
  documentSigned,
  signatureDeclined,
  tokenExpired,
  documentCompleted,
  documentShared,
  generalInfo,
}

// ─── UI state ─────────────────────────────────────────────────────────────────

enum ViewState { idle, loading, success, error, empty }

// ─── OTP ──────────────────────────────────────────────────────────────────────

enum OtpVerifyResult { valid, notFound, expired, alreadyUsed, wrongCode }
