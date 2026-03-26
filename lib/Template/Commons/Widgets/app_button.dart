import 'package:flutter/material.dart';

enum AppButtonType { primary, outlined, text }

class AppButton extends StatelessWidget {
  final String label;
  final VoidCallback? onPressed;
  final bool isLoading;
  final Widget? icon;
  final double? width;
  final double height;
  final AppButtonType type;

  const AppButton({
    super.key,
    required this.label,
    required this.type,
    this.onPressed,
    this.isLoading = false,
    this.icon,
    this.width,
    this.height = 52,
  });

  // Primary — filled blue pill button

  factory AppButton.primary({
    Key? key,
    required String label,
    VoidCallback? onPressed,
    bool isLoading = false,
    Widget? icon,
    double? width,
    double height = 52,
  }) => AppButton(
    key: key,
    label: label,
    type: AppButtonType.primary,
    onPressed: onPressed,
    isLoading: isLoading,
    icon: icon,
    width: width,
    height: height,
  );

  // Outlined — white bg with border

  factory AppButton.outlined({
    Key? key,
    required String label,
    VoidCallback? onPressed,
    bool isLoading = false,
    Widget? icon,
    double? width,
    double height = 52,
  }) => AppButton(
    key: key,
    label: label,
    type: AppButtonType.outlined,
    onPressed: onPressed,
    isLoading: isLoading,
    icon: icon,
    width: width,
    height: height,
  );

  // Text — minimal, no background

  factory AppButton.text({
    Key? key,
    required String label,
    VoidCallback? onPressed,
    Widget? icon,
  }) => AppButton(
    key: key,
    label: label,
    type: AppButtonType.text,
    onPressed: onPressed,
    icon: icon,
    height: 36,
  );

  @override
  Widget build(BuildContext context) {
    final child = isLoading
        ? const SizedBox(
            width: 20,
            height: 20,
            child: CircularProgressIndicator(
              strokeWidth: 2,
              color: Colors.white,
            ),
          )
        : icon != null
        ? Row(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [icon!, const SizedBox(width: 10), Text(label)],
          )
        : Text(label);

    final buttonWidth = width ?? double.infinity;

    switch (type) {
      case AppButtonType.primary:
        return SizedBox(
          width: buttonWidth,
          height: height,
          child: ElevatedButton(
            onPressed: isLoading ? null : onPressed,
            child: child,
          ),
        );

      case AppButtonType.outlined:
        return SizedBox(
          width: buttonWidth,
          height: height,
          child: OutlinedButton(
            onPressed: isLoading ? null : onPressed,
            child: child,
          ),
        );

      case AppButtonType.text:
        return TextButton(
          onPressed: onPressed,
          child: icon != null
              ? Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [icon!, const SizedBox(width: 6), Text(label)],
                )
              : Text(label),
        );
    }
  }
}
