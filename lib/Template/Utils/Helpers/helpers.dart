import 'dart:async';
import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';
import '../Constant/colors.dart';
import '../Constant/enum.dart';

class AppHelpers {
  AppHelpers._();

  // Generate UUID v4
  static String generateUuid() => const Uuid().v4();

  // Always returns pdf since only PDFs are supported
  static DocumentFileType detectFileType(String fileName) =>
      DocumentFileType.pdf;

  // Returns the icon color for a document type
  static Color documentTypeColor(DocumentFileType type) => AppColors.red;

  // Returns the surface color for a document icon container
  static Color documentTypeSurface(DocumentFileType type) =>
      AppColors.redLight;

  // Build guest signing URL
  static String buildSigningUrl({
    required String baseUrl,
    required String token,
  }) {
    final cleanBase = baseUrl.endsWith('/')
        ? baseUrl.substring(0, baseUrl.length - 1)
        : baseUrl;
    return '$cleanBase/sign?token=$token';
  }

  // Extract token from signing URL
  static String? extractTokenFromUrl(String url) {
    try {
      return Uri.parse(url).queryParameters['token'];
    } catch (_) {
      return null;
    }
  }

  // Debounce — fires only after delay passes without another call
  static void Function(T) debounce<T>(void Function(T) action, Duration delay) {
    Timer? timer;
    return (T value) {
      timer?.cancel();
      timer = Timer(delay, () => action(value));
    };
  }

  // Safely get first element or null
  static T? firstOrNull<T>(List<T> list) => list.isEmpty ? null : list.first;

  // Check OTP expiry
  static bool isOtpValid(DateTime expiresAt) =>
      DateTime.now().isBefore(expiresAt);

  // Check signing token validity
  static bool isTokenValid({required DateTime expiresAt, required bool used}) =>
      !used && DateTime.now().isBefore(expiresAt);

  // Document sort comparator
  static int Function(dynamic, dynamic) documentComparator(SortOrder order) {
    return (a, b) {
      switch (order) {
        case SortOrder.nameAsc:
          return a.name.toString().toLowerCase().compareTo(
                b.name.toString().toLowerCase(),
              );
        case SortOrder.nameDesc:
          return b.name.toString().toLowerCase().compareTo(
                a.name.toString().toLowerCase(),
              );
        case SortOrder.dateNewest:
          final aDate = a.updatedAt as DateTime;
          final bDate = b.updatedAt as DateTime;
          return bDate.compareTo(aDate);
        case SortOrder.dateOldest:
          final aDate = a.updatedAt as DateTime;
          final bDate = b.updatedAt as DateTime;
          return aDate.compareTo(bDate);
        case SortOrder.sizeAsc:
          final aSize = _getSize(a);
          final bSize = _getSize(b);
          return aSize.compareTo(bSize);
        case SortOrder.sizeDesc:
          final aSize = _getSize(a);
          final bSize = _getSize(b);
          return bSize.compareTo(aSize);
        case SortOrder.type:
          return 0;
      }
    };
  }

  static double _getSize(dynamic item) {
    try {
      return (item.fileSizeMB as num).toDouble();
    } catch (_) {
      return 0.0;
    }
  }

  // Validate email format
  static bool isValidEmail(String email) =>
      RegExp(r'^[\w.-]+@[\w.-]+\.\w+$').hasMatch(email.trim());

  // Check file size against max MB limit
  static bool exceedsMaxFileSize(int bytes, {double maxMB = 20}) =>
      bytes > maxMB * 1024 * 1024;

  // Resolve unique name by appending suffix if exists (Professional OS approach)
  static String resolveUniqueName(String name, Iterable<String> existingNames) {
    final existingSet = existingNames.map((e) => e.toLowerCase()).toSet();
    if (!existingSet.contains(name.toLowerCase().trim())) return name.trim();

    final dot = name.lastIndexOf('.');
    // For folders, extension is empty. For files, it preserves it.
    final base = (dot != -1) ? name.substring(0, dot) : name;
    final ext = (dot != -1) ? name.substring(dot) : '';

    var counter = 1;
    while (true) {
      final candidate = '$base ($counter)$ext';
      if (!existingSet.contains(candidate.toLowerCase().trim())) {
        return candidate.trim();
      }
      counter++;
    }
  }

  // Check if name exists in a list (case-insensitive)
  static bool nameExists(String name, Iterable<String> existingNames) {
    final trimmed = name.trim().toLowerCase();
    return existingNames.any((e) => e.toLowerCase().trim() == trimmed);
  }
}
