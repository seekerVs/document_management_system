import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../Constant/colors.dart';
import '../Constant/texts.dart';
import '../../Commons/Widgets/app_text_field.dart';

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
      AppDialogBase(
        title: title,
        content: Text(message, textAlign: TextAlign.center),
        actions: [
          AppDialogAction(
            label: cancelLabel ?? AppText.cancel,
            onPressed: () => Get.back(),
            isPrimary: false,
          ),
          AppDialogAction(
            label: confirmLabel ?? AppText.confirm,
            onPressed: () {
              Get.back();
              onConfirm();
            },
            isDangerous: isDangerous,
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
      message:
          'This action cannot be undone and will permanently remove the item.',
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
      AppDialogBase(
        title: title ?? 'Error',
        icon: Icons.error_outline,
        iconColor: AppColors.red,
        content: Text(message, textAlign: TextAlign.center),
        actions: [AppDialogAction(label: 'OK', onPressed: () => Get.back())],
      ),
    );
  }

  static Future<void> showSuccess({
    required String message,
    String? title,
    VoidCallback? onDismiss,
  }) {
    return Get.dialog(
      AppDialogBase(
        title: title ?? 'Success',
        icon: Icons.check_circle_outline,
        iconColor: AppColors.green,
        content: Text(message, textAlign: TextAlign.center),
        actions: [
          AppDialogAction(
            label: 'OK',
            onPressed: () {
              Get.back();
              onDismiss?.call();
            },
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
      AppDialogBase(
        title: title,
        icon: Icons.info_outline,
        iconColor: AppColors.blue,
        content: Text(message, textAlign: TextAlign.center),
        actions: [AppDialogAction(label: 'OK', onPressed: () => Get.back())],
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
    IconData? icon,
    String? label,
  }) {
    final textController = TextEditingController(text: initialValue);
    final formKey = GlobalKey<FormState>();

    return Get.dialog(
      AppDialogBase(
        title: title,
        content: Form(
          key: formKey,
          child: AppTextField(
            controller: textController,
            autofocus: true,
            maxLength: maxLength,
            hint: hint,
            label: label,
            prefixIcon: icon,
            textCapitalization: TextCapitalization.words,
            validator: (v) =>
                v == null || v.trim().isEmpty ? 'Value is required' : null,
          ),
        ),
        actions: [
          AppDialogAction(
            label: AppText.cancel,
            onPressed: () => Get.back(),
            isPrimary: false,
          ),
          AppDialogAction(
            label: confirmLabel ?? AppText.save,
            onPressed: () {
              if (formKey.currentState!.validate()) {
                final value = textController.text.trim();
                Get.back();
                onConfirm(value);
              }
            },
          ),
        ],
      ),
    );
  }

  static Future<T?> showOptions<T>({
    required String title,
    required List<AppDialogOption<T>> options,
  }) {
    final context = Get.context!;
    final colorScheme = Theme.of(context).colorScheme;

    return Get.bottomSheet<T>(
      Container(
        padding: const EdgeInsets.only(top: 12, bottom: 24),
        decoration: BoxDecoration(
          color: colorScheme.surfaceContainer,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 40,
              height: 4,
              margin: const EdgeInsets.only(bottom: 16),
              decoration: BoxDecoration(
                color: colorScheme.onSurfaceVariant.withAlpha(50),
                borderRadius: BorderRadius.circular(4),
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Text(
                title,
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: colorScheme.onSurface,
                ),
                textAlign: TextAlign.center,
              ),
            ),
            const SizedBox(height: 16),
            Divider(height: 1, color: colorScheme.outlineVariant),
            Flexible(
              child: SingleChildScrollView(
                child: Column(
                  children: options
                      .map(
                        (option) => ListTile(
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 24,
                            vertical: 4,
                          ),
                          leading: Icon(
                            option.icon,
                            color: option.isDangerous
                                ? colorScheme.error
                                : colorScheme.onSurfaceVariant,
                            size: 24,
                          ),
                          title: Text(
                            option.label,
                            style: TextStyle(
                              color: option.isDangerous
                                  ? colorScheme.error
                                  : colorScheme.onSurface,
                              fontSize: 16,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          onTap: () => Get.back(result: option.value),
                        ),
                      )
                      .toList(),
                ),
              ),
            ),
          ],
        ),
      ),
      isScrollControlled: true,
      enterBottomSheetDuration: const Duration(milliseconds: 300),
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
      borderRadius: 12,
      icon: const Icon(
        Icons.check_circle_outline,
        color: AppColors.white,
        size: 24,
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
      borderRadius: 12,
      duration: const Duration(seconds: 4),
      icon: const Icon(Icons.error_outline, color: AppColors.white, size: 24),
    );
  }

  static void showSnackInfo(String message) {
    final context = Get.context!;
    final colorScheme = Theme.of(context).colorScheme;

    Get.snackbar(
      '',
      message,
      titleText: const SizedBox.shrink(),
      backgroundColor: colorScheme.surfaceContainerHighest,
      colorText: colorScheme.onSurface,
      snackPosition: SnackPosition.BOTTOM,
      margin: const EdgeInsets.all(16),
      borderRadius: 12,
      icon: Icon(Icons.info_outline, color: colorScheme.onSurface, size: 24),
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

class AppDialogBase extends StatelessWidget {
  final String title;
  final Widget content;
  final List<Widget>? actions;
  final IconData? icon;
  final Color? iconColor;

  const AppDialogBase({
    super.key,
    required this.title,
    required this.content,
    this.actions,
    this.icon,
    this.iconColor,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    // Standardize spacing and alignment
    return AlertDialog(
      titlePadding: const EdgeInsets.fromLTRB(24, 32, 24, 8),
      contentPadding: const EdgeInsets.fromLTRB(24, 16, 24, 24),
      actionsPadding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
      title: SizedBox(
        width: MediaQuery.of(context).size.width,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (icon != null) ...[
              Icon(icon, color: iconColor ?? colorScheme.primary, size: 40),
              const SizedBox(height: 16),
            ],
            Text(
              title,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w700,
                letterSpacing: -0.5,
                color: colorScheme.onSurface,
              ),
            ),
          ],
        ),
      ),
      content: SizedBox(
        width: MediaQuery.of(context).size.width,
        child: SingleChildScrollView(child: content),
      ),
      actions: actions != null
          ? [
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8),
                child: OverflowBar(
                  alignment: MainAxisAlignment.end,
                  overflowAlignment: OverflowBarAlignment.end,
                  spacing: 12,
                  overflowSpacing: 12,
                  children: actions!,
                ),
              ),
            ]
          : null,
    );
  }
}

class AppDialogAction extends StatelessWidget {
  final String label;
  final VoidCallback onPressed;
  final bool isPrimary;
  final bool isDangerous;
  final bool isLoading;

  const AppDialogAction({
    super.key,
    required this.label,
    required this.onPressed,
    this.isPrimary = true,
    this.isDangerous = false,
    this.isLoading = false,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    if (isPrimary) {
      return Padding(
        padding: const EdgeInsets.symmetric(horizontal: 4),
        child: FilledButton(
          onPressed: isLoading ? null : onPressed,
          style: FilledButton.styleFrom(
            backgroundColor: isDangerous ? colorScheme.error : null,
            foregroundColor: colorScheme.onPrimary,
            padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 24),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(14),
            ),
          ),
          child: isLoading
              ? SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: colorScheme.onPrimary,
                  ),
                )
              : Text(
                  label,
                  style: const TextStyle(
                    fontWeight: FontWeight.w600,
                    letterSpacing: 0.2,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
        ),
      );
    }

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 4),
      child: TextButton(
        onPressed: isLoading ? null : onPressed,
        style: TextButton.styleFrom(
          foregroundColor: colorScheme.onSurfaceVariant,
          padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
        ),
        child: isLoading
            ? const SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(strokeWidth: 2),
              )
            : Text(
                label,
                style: const TextStyle(
                  fontWeight: FontWeight.w600,
                  letterSpacing: 0.2,
                ),
              ),
      ),
    );
  }
}
