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
  static Color documentTypeColor(DocumentFileType type) => AppColors.pdfColor;

  // Returns the surface color for a document icon container
  static Color documentTypeSurface(DocumentFileType type) =>
      AppColors.pdfSurface;

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
          return a.name.compareTo(b.name);
        case SortOrder.nameDesc:
          return b.name.compareTo(a.name);
        case SortOrder.dateNewest:
          return b.updatedAt.compareTo(a.updatedAt);
        case SortOrder.dateOldest:
          return a.updatedAt.compareTo(b.updatedAt);
        case SortOrder.sizeAsc:
          return a.fileSizeMB.compareTo(b.fileSizeMB);
        case SortOrder.sizeDesc:
          return b.fileSizeMB.compareTo(a.fileSizeMB);
        case SortOrder.type:
          return 0;
      }
    };
  }

  // Validate email format
  static bool isValidEmail(String email) =>
      RegExp(r'^[\w.-]+@[\w.-]+\.\w+$').hasMatch(email.trim());

  // Check file size against max MB limit
  static bool exceedsMaxFileSize(int bytes, {double maxMB = 20}) =>
      bytes > maxMB * 1024 * 1024;
}
