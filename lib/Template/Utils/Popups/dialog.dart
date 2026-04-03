import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../Constant/colors.dart';
import '../Constant/texts.dart';

class AppDialogs {
  AppDialogs._();

  static Future<void> showConfirm({
    required String title,
    required String message,
    required VoidCallback onConfirm,
    String? confirmLabel,
    String? cancelLabel,
    bool isDangerous = false,
  }) {
    return Get.dialog(
      AlertDialog(
        title: Text(title),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: Text(cancelLabel ?? AppText.cancel),
          ),
          TextButton(
            onPressed: () {
              Get.back();
              onConfirm();
            },
            style: TextButton.styleFrom(
              foregroundColor: isDangerous
                  ? AppColors.red
                  : AppColors.blue,
            ),
            child: Text(confirmLabel ?? AppText.confirm),
          ),
        ],
      ),
      barrierDismissible: false,
    );
  }

  static Future<void> showDeleteConfirm({
    required String itemName,
    required VoidCallback onConfirm,
  }) {
    return showConfirm(
      title: 'Delete $itemName?',
      message: 'This action cannot be undone.',
      confirmLabel: AppText.delete,
      isDangerous: true,
      onConfirm: onConfirm,
    );
  }

  static Future<void> showSignOutConfirm({required VoidCallback onConfirm}) {
    return showConfirm(
      title: AppText.signOut,
      message: AppText.signOutConfirm,
      confirmLabel: AppText.signOut,
      isDangerous: true,
      onConfirm: onConfirm,
    );
  }

  static Future<void> showError({required String message, String? title}) {
    return Get.dialog(
      AlertDialog(
        title: Row(
          children: [
            const Icon(Icons.error_outline, color: AppColors.red, size: 20),
            const SizedBox(width: 8),
            Text(title ?? 'Error'),
          ],
        ),
        content: Text(message),
        actions: [
          TextButton(onPressed: () => Get.back(), child: const Text('OK')),
        ],
      ),
    );
  }

  static Future<void> showSuccess({
    required String message,
    String? title,
    VoidCallback? onDismiss,
  }) {
    return Get.dialog(
      AlertDialog(
        title: Row(
          children: [
            const Icon(
              Icons.check_circle_outline,
              color: AppColors.green,
              size: 20,
            ),
            const SizedBox(width: 8),
            Text(title ?? 'Success'),
          ],
        ),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () {
              Get.back();
              onDismiss?.call();
            },
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  static Future<void> showInfo({
    required String title,
    required String message,
  }) {
    return Get.dialog(
      AlertDialog(
        title: Row(
          children: [
            const Icon(Icons.info_outline, color: AppColors.textSecondary, size: 20),
            const SizedBox(width: 8),
            Text(title),
          ],
        ),
        content: Text(message),
        actions: [
          TextButton(onPressed: () => Get.back(), child: const Text('OK')),
        ],
      ),
    );
  }

  static Future<void> showInput({
    required String title,
    required String hint,
    required void Function(String value) onConfirm,
    String? initialValue,
    String? confirmLabel,
    int maxLength = 50,
  }) {
    final textController = TextEditingController(text: initialValue);

    return Get.dialog(
      AlertDialog(
        title: Text(title),
        content: TextField(
          controller: textController,
          autofocus: true,
          maxLength: maxLength,
          decoration: InputDecoration(hintText: hint),
          textCapitalization: TextCapitalization.words,
        ),
        actions: [
          TextButton(onPressed: () => Get.back(), child: const Text('Cancel')),
          TextButton(
            onPressed: () {
              final value = textController.text.trim();
              if (value.isNotEmpty) {
                Get.back();
                onConfirm(value);
              }
            },
            child: Text(confirmLabel ?? AppText.save),
          ),
        ],
      ),
    );
  }

  static Future<T?> showOptions<T>({
    required String title,
    required List<AppDialogOption<T>> options,
  }) {
    return Get.bottomSheet<T>(
      Container(
        padding: const EdgeInsets.only(top: 12, bottom: 24),
        decoration: const BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: AppColors.grey,
                borderRadius: BorderRadius.circular(4),
              ),
            ),
            const SizedBox(height: 16),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Text(
                title,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textPrimary,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            const SizedBox(height: 8),
            const Divider(),
            ...options.map(
              (option) => ListTile(
                leading: Icon(
                  option.icon,
                  color: option.isDangerous
                      ? AppColors.red
                      : AppColors.textSecondary,
                  size: 22,
                ),
                title: Text(
                  option.label,
                  style: TextStyle(
                    color: option.isDangerous
                        ? AppColors.red
                        : AppColors.textPrimary,
                    fontSize: 15,
                  ),
                ),
                onTap: () => Get.back(result: option.value),
              ),
            ),
          ],
        ),
      ),
      isScrollControlled: true,
    );
  }

  static void showSnackSuccess(String message) {
    Get.snackbar(
      '',
      message,
      titleText: const SizedBox.shrink(),
      backgroundColor: AppColors.green,
      colorText: AppColors.white,
      snackPosition: SnackPosition.BOTTOM,
      margin: const EdgeInsets.all(16),
      borderRadius: 8,
      icon: const Icon(
        Icons.check_circle_outline,
        color: AppColors.white,
        size: 20,
      ),
    );
  }

  static void showSnackError(String message) {
    Get.snackbar(
      '',
      message,
      titleText: const SizedBox.shrink(),
      backgroundColor: AppColors.red,
      colorText: AppColors.white,
      snackPosition: SnackPosition.BOTTOM,
      margin: const EdgeInsets.all(16),
      borderRadius: 8,
      duration: const Duration(seconds: 4),
      icon: const Icon(
        Icons.error_outline,
        color: AppColors.white,
        size: 20,
      ),
    );
  }

  static void showSnackInfo(String message) {
    Get.snackbar(
      '',
      message,
      titleText: const SizedBox.shrink(),
      backgroundColor: AppColors.textSecondary,
      colorText: AppColors.white,
      snackPosition: SnackPosition.BOTTOM,
      margin: const EdgeInsets.all(16),
      borderRadius: 8,
      icon: const Icon(
        Icons.info_outline,
        color: AppColors.white,
        size: 20,
      ),
    );
  }
}

class AppDialogOption<T> {
  final String label;
  final IconData icon;
  final T value;
  final bool isDangerous;

  const AppDialogOption({
    required this.label,
    required this.icon,
    required this.value,
    this.isDangerous = false,
  });
}
