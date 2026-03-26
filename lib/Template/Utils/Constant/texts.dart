class AppText {
  AppText._();

  static const String appName = 'Scrivener';

  // ─── Common actions — used across multiple screens ────────────────────────

  static const String cancel = 'Cancel';
  static const String confirm = 'Confirm';
  static const String save = 'Save';
  static const String delete = 'Delete';
  static const String edit = 'Edit';
  static const String copy = 'Copy';
  static const String move = 'Move';
  static const String rename = 'Rename';
  static const String share = 'Share';
  static const String download = 'Download';
  static const String retry = 'Try again';
  static const String close = 'Close';
  static const String next = 'Next';
  static const String back = 'Back';
  static const String done = 'Done';
  static const String seeAll = 'See All';
  static const String more = 'More';
  static const String signOut = 'Sign Out';

  // ─── Document status labels — used in tiles, badges, filters ─────────────

  static const String statusDraft = 'Draft';
  static const String statusPending = 'Pending signature';
  static const String statusCompleted = 'Completed';
  static const String statusDeclined = 'Declined';

  // ─── Empty state messages — used across multiple list screens ─────────────

  static const String noDocuments = 'No documents yet';
  static const String noFolders = 'No folders yet';
  static const String noNotifications = 'No notifications yet';
  static const String noActivity = 'No recent activity';
  static const String noSignatureRequests = 'No signature requests';
  static const String comingSoon = 'Coming soon';

  // ─── Section titles — used in SectionHeader across multiple screens ────────

  static const String myDocuments = 'My Documents';
  static const String activities = 'Activities';
  static const String assignedTasks = 'Assigned Tasks';

  static const String justNow = 'just now';
  static const String minutesAgo = 'm ago';
  static const String hoursAgo = 'h ago';
  static const String daysAgo = 'd ago';

  static const String tokenExpired = 'This signing link has expired.';
  static const String tokenUsed = 'This signing link has already been used.';
  static const String tokenInvalid = 'This signing link is invalid.';

  static const String signOutConfirm = 'Are you sure you want to sign out?';
}
