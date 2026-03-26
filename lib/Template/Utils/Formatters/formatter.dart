import 'package:intl/intl.dart';
import '../Constant/colors.dart';
import '../Constant/enum.dart';
import '../Constant/lists.dart';
import '../Constant/texts.dart';

class AppFormatter {
  AppFormatter._();

  /// "Jan 24, 2026"
  static String date(DateTime dt) => DateFormat('MMM d, yyyy').format(dt);

  /// "01/24/2026"
  static String dateShort(DateTime dt) => DateFormat('MM/dd/yyyy').format(dt);

  /// "Jan 24, 2026  10:56 AM"
  static String dateTime(DateTime dt) =>
      DateFormat('MMM d, yyyy  hh:mm a').format(dt);

  /// "10:56 AM"
  static String timeOnly(DateTime dt) => DateFormat('hh:mm a').format(dt);

  /// "Today", "Yesterday", weekday name, "Jan 24", or "Jan 24, 2026"
  static String relativeDate(DateTime dt) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final target = DateTime(dt.year, dt.month, dt.day);
    final diff = today.difference(target).inDays;

    if (diff == 0) return 'Today';
    if (diff == 1) return 'Yesterday';
    if (diff < 7) return DateFormat('EEEE').format(dt);
    if (dt.year == now.year) return DateFormat('MMM d').format(dt);
    return date(dt);
  }

  /// "just now", "5m ago", "2h ago", "3d ago"
  static String timeAgo(DateTime dt) {
    final diff = DateTime.now().difference(dt);
    if (diff.inSeconds < 60) return AppText.justNow;
    if (diff.inMinutes < 60) return '${diff.inMinutes}${AppText.minutesAgo}';
    if (diff.inHours < 24) return '${diff.inHours}${AppText.hoursAgo}';
    if (diff.inDays < 30) return '${diff.inDays}${AppText.daysAgo}';
    return date(dt);
  }

  /// "Expires in 2h 30m" or "Expired"
  static String tokenExpiry(DateTime expiresAt) {
    final diff = expiresAt.difference(DateTime.now());
    if (diff.isNegative) return 'Expired';
    if (diff.inHours >= 1) {
      final h = diff.inHours;
      final m = diff.inMinutes.remainder(60);
      return 'Expires in ${h}h ${m}m';
    }
    return 'Expires in ${diff.inMinutes}m';
  }

  // ─── File ─────────────────────────────────────────────────────────────────

  /// Converts bytes to human-readable size.
  static String fileSize(int bytes) {
    if (bytes <= 0) return '0 B';
    if (bytes < 1024) return '$bytes B';
    if (bytes < 1024 * 1024) {
      return '${(bytes / 1024).toStringAsFixed(0)} KB';
    }
    if (bytes < 1024 * 1024 * 1024) {
      final mb = bytes / (1024 * 1024);
      return '${mb % 1 == 0 ? mb.toStringAsFixed(0) : mb.toStringAsFixed(1)} MB';
    }
    final gb = bytes / (1024 * 1024 * 1024);
    return '${gb.toStringAsFixed(1)} GB';
  }

  /// Converts double MB to human-readable string.
  static String fileSizeFromMB(double mb) =>
      fileSize((mb * 1024 * 1024).round());

  /// "document.pdf" → "pdf"
  static String fileExtension(String fileName) {
    if (!fileName.contains('.')) return '';
    return fileName.split('.').last.toLowerCase();
  }

  /// "My Document.pdf" → "My Document"
  static String fileNameWithoutExtension(String fileName) {
    final parts = fileName.split('.');
    if (parts.length <= 1) return fileName;
    return parts.sublist(0, parts.length - 1).join('.');
  }

  // ─── Document status ──────────────────────────────────────────────────────

  static String documentStatus(DocumentStatus status) {
    switch (status) {
      case DocumentStatus.draft:
        return AppText.statusDraft;
      case DocumentStatus.pending:
        return AppText.statusPending;
      case DocumentStatus.completed:
        return AppText.statusCompleted;
      case DocumentStatus.declined:
        return AppText.statusDeclined;
    }
  }

  /// Returns color + surface color pair for a document status badge.
  static ({dynamic color, dynamic surface}) documentStatusColors(
    DocumentStatus status,
  ) {
    switch (status) {
      case DocumentStatus.draft:
        return (
          color: AppColors.textSecondary,
          surface: AppColors.backgroundGrey,
        );
      case DocumentStatus.pending:
        return (
          color: AppColors.signaturePending,
          surface: AppColors.signaturePendingSurface,
        );
      case DocumentStatus.completed:
        return (
          color: AppColors.signatureCompleted,
          surface: AppColors.signatureCompletedSurface,
        );
      case DocumentStatus.declined:
        return (
          color: AppColors.signatureDeclined,
          surface: AppColors.signatureDeclinedSurface,
        );
    }
  }

  // ─── Signer & signature status ────────────────────────────────────────────

  static String signerStatus(SignerStatus status) {
    switch (status) {
      case SignerStatus.pending:
        return 'Pending';
      case SignerStatus.signed:
        return 'Signed';
      case SignerStatus.declined:
        return 'Declined';
    }
  }

  static String signatureRequestStatus(SignatureRequestStatus status) {
    switch (status) {
      case SignatureRequestStatus.pending:
        return 'Pending';
      case SignatureRequestStatus.inProgress:
        return 'In Progress';
      case SignatureRequestStatus.completed:
        return 'Completed';
      case SignatureRequestStatus.declined:
        return 'Declined';
      case SignatureRequestStatus.expired:
        return 'Expired';
    }
  }

  // ─── Activity ─────────────────────────────────────────────────────────────

  /// "Juan uploaded My Document.pdf"
  static String activityDescription({
    required String actorName,
    required ActivityAction action,
    String? documentName,
  }) {
    final verb = AppLists.activityLabels[action] ?? action.name;
    final doc = documentName != null ? ' $documentName' : ' a document';
    return '$actorName $verb$doc';
  }

  // ─── Notification ─────────────────────────────────────────────────────────

  static String notificationTitle(NotificationType type) =>
      AppLists.notificationLabels[type] ?? 'Notification';

  // ─── User / name ──────────────────────────────────────────────────────────

  /// "juan dela cruz" → "Juan Dela Cruz"
  static String capitalizeName(String name) {
    if (name.trim().isEmpty) return name;
    return name
        .trim()
        .split(' ')
        .map(
          (w) =>
              w.isEmpty ? w : w[0].toUpperCase() + w.substring(1).toLowerCase(),
        )
        .join(' ');
  }

  /// "Juan dela Cruz" → "JD", "Juan" → "J"
  static String initials(String name) {
    if (name.trim().isEmpty) return '?';
    final parts = name.trim().split(' ').where((p) => p.isNotEmpty).toList();
    if (parts.length == 1) return parts[0][0].toUpperCase();
    return '${parts.first[0]}${parts.last[0]}'.toUpperCase();
  }

  /// "jomartolentino2002@gmail.com" → "jo***@gmail.com"
  static String maskEmail(String email) {
    if (!email.contains('@')) return email;
    final parts = email.split('@');
    final local = parts[0];
    final domain = parts[1];
    if (local.length <= 2) return '${local[0]}***@$domain';
    return '${local.substring(0, 2)}***@$domain';
  }

  // ─── Text ─────────────────────────────────────────────────────────────────

  /// "Very long document name here" → "Very long doc..."
  static String truncate(String text, {int maxLength = 30}) {
    if (text.length <= maxLength) return text;
    return '${text.substring(0, maxLength - 3)}...';
  }

  /// 1 → "1 item", 5 → "5 items"
  static String itemCount(int count) =>
      '$count ${count == 1 ? 'item' : 'items'}';

  /// 1 → "1 signer", 3 → "3 signers"
  static String signerCount(int count) =>
      '$count ${count == 1 ? 'signer' : 'signers'}';

  /// "2 of 3 signed"
  static String signingProgress(int signed, int total) =>
      '$signed of $total signed';

  /// "3 pending", "All signed"
  static String signingPendingSummary(int pending, int total) {
    if (pending == 0) return 'All signed';
    return '$pending of $total pending';
  }
}
