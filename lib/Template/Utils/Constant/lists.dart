import 'enum.dart';

class AppLists {
  AppLists._();

  static const List<Map<String, String>> uploadSources = [
    {'label': 'Scan', 'icon': 'scan'},
    {'label': 'Library', 'icon': 'photo_library'},
    {'label': 'Gallery', 'icon': 'image'},
    {'label': 'Drive', 'icon': 'drive'},
    {'label': 'Photos', 'icon': 'photo'},
    {'label': 'Media picker', 'icon': 'perm_media'},
    {'label': 'Files', 'icon': 'folder'},
  ];

  static const List<String> defaultFolders = [
    'Identity Documents',
    'Vital Records',
    'Academic Records',
    'Career & Employment',
    'Health & Medical',
    'Financial & Property',
    'Requests',
    'Templates',
  ];

  static const List<Map<String, dynamic>> sortOptions = [
    {'label': 'Name (A–Z)', 'value': SortOrder.nameAsc},
    {'label': 'Name (Z–A)', 'value': SortOrder.nameDesc},
    {'label': 'Newest first', 'value': SortOrder.dateNewest},
    {'label': 'Oldest first', 'value': SortOrder.dateOldest},
    {'label': 'Size (smallest)', 'value': SortOrder.sizeAsc},
    {'label': 'Size (largest)', 'value': SortOrder.sizeDesc},
  ];

  static const List<String> documentActions = [
    'Copy',
    'Move',
    'Rename',
    'Delete',
    'Share',
    'Request Signature',
  ];

  static const List<String> folderActions = ['Rename', 'Delete', 'Move'];

  static const List<Map<String, dynamic>> folderColors = [
    {'label': 'Blue', 'value': FolderColor.blue, 'hex': 0xFF378ADD},
    {'label': 'Green', 'value': FolderColor.green, 'hex': 0xFF1D9E75},
    {'label': 'Red', 'value': FolderColor.red, 'hex': 0xFFE24B4A},
    {'label': 'Yellow', 'value': FolderColor.yellow, 'hex': 0xFFBA7517},
    {'label': 'Purple', 'value': FolderColor.purple, 'hex': 0xFF534AB7},
    {'label': 'Orange', 'value': FolderColor.orange, 'hex': 0xFFD85A30},
  ];

  static const List<Map<String, dynamic>> signatureTypes = [
    {'label': 'Draw', 'value': SignatureType.drawn, 'icon': 'draw'},
    {'label': 'Type', 'value': SignatureType.typed, 'icon': 'keyboard'},
    {'label': 'Upload', 'value': SignatureType.uploaded, 'icon': 'upload'},
  ];

  static const List<String> allowedExtensions = [
    'pdf',
    'jpg',
    'jpeg',
    'png',
    'doc',
    'docx',
  ];

  static const List<String> pdfMimeTypes = ['application/pdf'];

  static const List<String> imageMimeTypes = [
    'image/jpeg',
    'image/png',
    'image/gif',
    'image/webp',
  ];

  static const List<int> otpExpiryOptions = [5, 10, 15, 30];

  static const List<int> signingLinkExpiryOptions = [24, 48, 72];

  static const Map<ActivityAction, String> activityLabels = {
    ActivityAction.uploaded: 'uploaded',
    ActivityAction.signed: 'signed',
    ActivityAction.requestedSignature: 'requested a signature on',
    ActivityAction.deleted: 'deleted',
    ActivityAction.moved: 'moved',
    ActivityAction.copied: 'copied',
    ActivityAction.renamed: 'renamed',
    ActivityAction.folderCreated: 'created a folder',
    ActivityAction.folderDeleted: 'deleted a folder',
    ActivityAction.shared: 'shared',
  };

  static const Map<NotificationType, String> notificationLabels = {
    NotificationType.signatureRequested: 'Signature requested',
    NotificationType.documentSigned: 'Document signed',
    NotificationType.tokenExpired: 'Signing link expired',
    NotificationType.documentCompleted: 'Document completed',
    NotificationType.documentShared: 'Document shared',
    NotificationType.generalInfo: 'Info',
  };

  static const List<Map<String, String>> faqs = [
    {
      'question': 'What is Scrivener?',
      'answer':
          'Scrivener is a digital platform that allows users to securely store, manage, share, and electronically sign documents.',
    },
    {
      'question': 'Who can use the app?',
      'answer':
          'Anyone needing to efficiently organize files, request signatures, or electronically sign documents can use the app.',
    },
    {
      'question': 'Are electronic signatures legally valid?',
      'answer':
          'Yes, electronic signatures performed through our platform are secure, traceable, and legally binding in most jurisdictions.',
    },
    {
      'question': 'What types of documents can I upload?',
      'answer':
          'We support a variety of file formats, including PDF, JPG, JPEG, PNG, DOC, and DOCX.',
    },
    {
      'question': 'How do I request a signature?',
      'answer':
          'Simply open a document, select "Request Signature" from the actions menu, add your signers\' emails, and they will receive a secure signing link.',
    },
    {
      'question': 'What should I do if a signing link expires?',
      'answer':
          'Signing links are configured to expire after a certain period (e.g., 24, 48, or 72 hours) for security. If a link expires, the sender must issue a new signature request.',
    },
    {
      'question': 'How can I sign a document?',
      'answer':
          'When opening a signature request, you can choose to draw your signature, type it using standard fonts, or upload an image of your physical signature.',
    },
  ];
}
