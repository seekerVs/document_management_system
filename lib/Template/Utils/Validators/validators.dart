import '../Constant/lists.dart';

class Validators {
  Validators._();

  static String? email(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Email is required.';
    }
    final regex = RegExp(r'^[\w.-]+@[\w.-]+\.\w+$');
    if (!regex.hasMatch(value.trim())) {
      return 'Enter a valid email address.';
    }
    return null;
  }

  static String? password(String? value) {
    if (value == null || value.isEmpty) {
      return 'Password is required.';
    }
    if (value.length < 8) {
      return 'Password must be at least 8 characters.';
    }
    if (!value.contains(RegExp(r'[A-Z]'))) {
      return 'Password must contain at least one uppercase letter.';
    }
    if (!value.contains(RegExp(r'[0-9]'))) {
      return 'Password must contain at least one number.';
    }
    return null;
  }

  static String? confirmPassword(String? value, String original) {
    if (value == null || value.isEmpty) {
      return 'Please confirm your password.';
    }
    if (value != original) {
      return 'Passwords do not match.';
    }
    return null;
  }

  static String? name(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Name is required.';
    }
    if (value.trim().length < 2) {
      return 'Name must be at least 2 characters.';
    }
    if (value.trim().length > 50) {
      return 'Name must not exceed 50 characters.';
    }
    return null;
  }

  // ─── OTP ──────────────────────────────────────────────────────────────────

  static String? otpCode(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Verification code is required.';
    }
    if (value.trim().length != 6) {
      return 'Code must be exactly 6 digits.';
    }
    if (!RegExp(r'^\d{6}$').hasMatch(value.trim())) {
      return 'Code must contain digits only.';
    }
    return null;
  }

  // ─── Document ─────────────────────────────────────────────────────────────

  static String? documentName(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Document name is required.';
    }
    if (value.trim().length < 2) {
      return 'Document name must be at least 2 characters.';
    }
    if (value.trim().length > 100) {
      return 'Document name must not exceed 100 characters.';
    }
    final invalidChars = RegExp(r'[<>:"/\\|?*]');
    if (invalidChars.hasMatch(value)) {
      return 'Document name contains invalid characters.';
    }
    return null;
  }

  static String? folderName(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Folder name is required.';
    }
    if (value.trim().length < 2) {
      return 'Folder name must be at least 2 characters.';
    }
    if (value.trim().length > 50) {
      return 'Folder name must not exceed 50 characters.';
    }
    final invalidChars = RegExp(r'[<>:"/\\|?*]');
    if (invalidChars.hasMatch(value)) {
      return 'Folder name contains invalid characters.';
    }
    return null;
  }

  // ─── File ─────────────────────────────────────────────────────────────────

  /// Validates file extension against the allowed list in AppLists.
  static String? fileExtension(String? fileName) {
    if (fileName == null || fileName.isEmpty) {
      return 'No file selected.';
    }
    final ext = fileName.split('.').last.toLowerCase();
    if (!AppLists.allowedExtensions.contains(ext)) {
      return 'File type not supported. Allowed: ${AppLists.allowedExtensions.join(', ')}';
    }
    return null;
  }

  /// Validates file size does not exceed [maxMB].
  static String? fileSize(int? bytes, {double maxMB = 20}) {
    if (bytes == null || bytes <= 0) {
      return 'Invalid file.';
    }
    final sizeMB = bytes / (1024 * 1024);
    if (sizeMB > maxMB) {
      return 'File size must not exceed ${maxMB.toStringAsFixed(0)} MB.';
    }
    return null;
  }

  // ─── Signer ───────────────────────────────────────────────────────────────

  static String? signerEmail(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Signer email is required.';
    }
    final regex = RegExp(r'^[\w.-]+@[\w.-]+\.\w+$');
    if (!regex.hasMatch(value.trim())) {
      return 'Enter a valid email address.';
    }
    return null;
  }

  static String? signerName(String? value) {
    // Optional — only validate if provided
    if (value == null || value.trim().isEmpty) return null;
    if (value.trim().length < 2) {
      return 'Name must be at least 2 characters.';
    }
    if (value.trim().length > 50) {
      return 'Name must not exceed 50 characters.';
    }
    return null;
  }

  // ─── Signing token ────────────────────────────────────────────────────────

  /// Validates that a signing token matches UUID v4 format.
  static String? signingToken(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Signing token is missing.';
    }
    final uuidRegex = RegExp(
      r'^[0-9a-f]{8}-[0-9a-f]{4}-4[0-9a-f]{3}-[89ab][0-9a-f]{3}-[0-9a-f]{12}$',
      caseSensitive: false,
    );
    if (!uuidRegex.hasMatch(value.trim())) {
      return 'Invalid signing token.';
    }
    return null;
  }

  // ─── URL ──────────────────────────────────────────────────────────────────

  static String? url(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'URL is required.';
    }
    final urlRegex = RegExp(
      r'^https?:\/\/(www\.)?[-a-zA-Z0-9@:%._+~#=]{1,256}\.[a-zA-Z0-9()]{1,6}'
      r'\b([-a-zA-Z0-9()@:%_+.~#?&/=]*)$',
    );
    if (!urlRegex.hasMatch(value.trim())) {
      return 'Enter a valid URL.';
    }
    return null;
  }

  // ─── Phone ────────────────────────────────────────────────────────────────

  /// Basic international phone number validation.
  /// Used for future signer identity verification.
  static String? phoneNumber(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Phone number is required.';
    }
    final phoneRegex = RegExp(r'^\+?[0-9]{7,15}$');
    if (!phoneRegex.hasMatch(value.replaceAll(' ', ''))) {
      return 'Enter a valid phone number.';
    }
    return null;
  }

  // ─── Generic ──────────────────────────────────────────────────────────────

  static String? required(String? value, {String label = 'This field'}) {
    if (value == null || value.trim().isEmpty) {
      return '$label is required.';
    }
    return null;
  }

  static String? minLength(
    String? value,
    int min, {
    String label = 'This field',
  }) {
    if (value == null || value.trim().isEmpty) {
      return '$label is required.';
    }
    if (value.trim().length < min) {
      return '$label must be at least $min characters.';
    }
    return null;
  }

  static String? maxLength(
    String? value,
    int max, {
    String label = 'This field',
  }) {
    if (value == null) return null;
    if (value.trim().length > max) {
      return '$label must not exceed $max characters.';
    }
    return null;
  }

  /// Combines multiple validators — returns first error found.
  static String? Function(String?) compose(
    List<String? Function(String?)> validators,
  ) {
    return (value) {
      for (final validator in validators) {
        final result = validator(value);
        if (result != null) return result;
      }
      return null;
    };
  }
}
