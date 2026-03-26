import 'enum.dart';

// 📁 lib/Template/Utils/Constant/list.dart
//
// Static lists and maps used for dropdowns, pickers, and display logic.

class AppLists {
  AppLists._();

  // ─── Document upload sources ──────────────────────────────────────────────

  static const List<Map<String, String>> uploadSources = [
    {'label': 'Scan', 'icon': 'scan'},
    {'label': 'Library', 'icon': 'photo_library'},
    {'label': 'Gallery', 'icon': 'image'},
    {'label': 'Drive', 'icon': 'drive'},
    {'label': 'Photos', 'icon': 'photo'},
    {'label': 'Media picker', 'icon': 'perm_media'},
    {'label': 'Files', 'icon': 'folder'},
  ];

  // ─── Document sort options ────────────────────────────────────────────────

  static const List<Map<String, dynamic>> sortOptions = [
    {'label': 'Name (A–Z)', 'value': SortOrder.nameAsc},
    {'label': 'Name (Z–A)', 'value': SortOrder.nameDesc},
    {'label': 'Newest first', 'value': SortOrder.dateNewest},
    {'label': 'Oldest first', 'value': SortOrder.dateOldest},
    {'label': 'Size (smallest)', 'value': SortOrder.sizeAsc},
    {'label': 'Size (largest)', 'value': SortOrder.sizeDesc},
  ];

  // ─── Document action menu items ───────────────────────────────────────────

  static const List<String> documentActions = [
    'Copy',
    'Move',
    'Rename',
    'Delete',
    'Share',
    'Request Signature',
  ];

  // ─── Folder action menu items ─────────────────────────────────────────────

  static const List<String> folderActions = ['Rename', 'Delete', 'Move'];

  // ─── Folder colors ────────────────────────────────────────────────────────

  static const List<Map<String, dynamic>> folderColors = [
    {'label': 'Blue', 'value': FolderColor.blue, 'hex': 0xFF378ADD},
    {'label': 'Green', 'value': FolderColor.green, 'hex': 0xFF1D9E75},
    {'label': 'Red', 'value': FolderColor.red, 'hex': 0xFFE24B4A},
    {'label': 'Yellow', 'value': FolderColor.yellow, 'hex': 0xFFBA7517},
    {'label': 'Purple', 'value': FolderColor.purple, 'hex': 0xFF534AB7},
    {'label': 'Orange', 'value': FolderColor.orange, 'hex': 0xFFD85A30},
  ];

  // ─── Signature type options ───────────────────────────────────────────────

  static const List<Map<String, dynamic>> signatureTypes = [
    {'label': 'Draw', 'value': SignatureType.drawn, 'icon': 'draw'},
    {'label': 'Type', 'value': SignatureType.typed, 'icon': 'keyboard'},
    {'label': 'Upload', 'value': SignatureType.uploaded, 'icon': 'upload'},
  ];

  // ─── Allowed document file extensions ────────────────────────────────────

  static const List<String> allowedExtensions = [
    'pdf',
    'jpg',
    'jpeg',
    'png',
    'doc',
    'docx',
  ];

  // ─── Supported PDF mime types ─────────────────────────────────────────────

  static const List<String> pdfMimeTypes = ['application/pdf'];

  // ─── Supported image mime types ───────────────────────────────────────────

  static const List<String> imageMimeTypes = [
    'image/jpeg',
    'image/png',
    'image/gif',
    'image/webp',
  ];

  // ─── OTP expiry options (minutes) ────────────────────────────────────────

  static const List<int> otpExpiryOptions = [5, 10, 15, 30];

  // ─── Signing link expiry options (hours) ─────────────────────────────────

  static const List<int> signingLinkExpiryOptions = [24, 48, 72];

  // ─── Activity action labels ───────────────────────────────────────────────

  static const Map<ActivityAction, String> activityLabels = {
    ActivityAction.uploaded: 'uploaded',
    ActivityAction.signed: 'signed',
    ActivityAction.requestedSignature: 'requested a signature on',
    ActivityAction.deleted: 'deleted',
    ActivityAction.moved: 'moved',
    ActivityAction.copied: 'copied',
    ActivityAction.renamed: 'renamed',
    ActivityAction.declined: 'declined to sign',
    ActivityAction.folderCreated: 'created a folder',
    ActivityAction.folderDeleted: 'deleted a folder',
    ActivityAction.shared: 'shared',
  };

  // ─── Notification type labels ─────────────────────────────────────────────

  static const Map<NotificationType, String> notificationLabels = {
    NotificationType.signatureRequested: 'Signature requested',
    NotificationType.documentSigned: 'Document signed',
    NotificationType.signatureDeclined: 'Signature declined',
    NotificationType.tokenExpired: 'Signing link expired',
    NotificationType.documentCompleted: 'Document completed',
    NotificationType.documentShared: 'Document shared',
    NotificationType.generalInfo: 'Info',
  };
}
