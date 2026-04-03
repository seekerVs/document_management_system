import 'package:flutter/material.dart';
import '../../Utils/Constant/colors.dart';

class AppStyle {
  AppStyle._();

  // Theme-aware card — adapts to light/dark automatically
  static BoxDecoration cardOf(BuildContext context, {double radius = 12}) {
    final cs = Theme.of(context).colorScheme;
    return BoxDecoration(
      color: cs.surfaceContainer,
      borderRadius: BorderRadius.circular(radius),
      border: Border.all(color: cs.outline),
    );
  }

  // Static fallback (light-only, for const contexts)
  static BoxDecoration card({double radius = 12}) => BoxDecoration(
    color: AppColors.white,
    borderRadius: BorderRadius.circular(radius),
    border: Border.all(color: AppColors.grey),
  );

  // Document icon container
  static BoxDecoration documentIconContainer(Color color) => BoxDecoration(
    color: color.withValues(alpha: 0.1),
    borderRadius: BorderRadius.circular(8),
  );

  // OTP digit box
  static InputDecoration otpBoxDecoration() => const InputDecoration(
    counterText: '',
    contentPadding: EdgeInsets.zero,
    enabledBorder: OutlineInputBorder(
      borderRadius: BorderRadius.all(Radius.circular(10)),
      borderSide: BorderSide(color: AppColors.grey),
    ),
    focusedBorder: OutlineInputBorder(
      borderRadius: BorderRadius.all(Radius.circular(10)),
      borderSide: BorderSide(color: AppColors.blue, width: 1.5),
    ),
    filled: true,
    fillColor: AppColors.backgroundInput,
  );

  // Theme-aware bottom sheet handle
  static BoxDecoration bottomSheetHandleOf(BuildContext context) {
    return BoxDecoration(
      color: Theme.of(context).colorScheme.outlineVariant,
      borderRadius: const BorderRadius.all(Radius.circular(4)),
    );
  }

  // Theme-aware bottom sheet decoration
  static BoxDecoration bottomSheetDecoration(BuildContext context) {
    return BoxDecoration(
      color: Theme.of(context).colorScheme.surface,
      borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
    );
  }

  // Static fallback (light-only, for const contexts)
  static const BoxDecoration bottomSheetHandle = BoxDecoration(
    color: AppColors.grey,
    borderRadius: BorderRadius.all(Radius.circular(4)),
  );

  // Status badge

  static BoxDecoration statusBadge(Color backgroundColor) => BoxDecoration(
    color: backgroundColor,
    borderRadius: BorderRadius.circular(40),
  );

  static const TextStyle appName = TextStyle(
    fontFamily: 'Kameron',
    fontSize: 22,
    fontWeight: FontWeight.w700,
    color: AppColors.blue,
    letterSpacing: 0.5,
  );

  // Dark variant background for splash text
  static const TextStyle appNameLight = TextStyle(
    fontFamily: 'Kameron',
    fontSize: 22,
    fontWeight: FontWeight.w700,
    color: AppColors.white,
    letterSpacing: 0.5,
  );
}
