import 'package:flutter/material.dart';
import '../../Utils/Constant/colors.dart';

class AppStyle {
  AppStyle._();

  // White card
  static BoxDecoration card({double radius = 12}) => BoxDecoration(
    color: AppColors.backgroundWhite,
    borderRadius: BorderRadius.circular(radius),
    border: Border.all(color: AppColors.borderLight),
  );

  // Document icon container
  static BoxDecoration documentIconContainer(Color color) => BoxDecoration(
    color: color.withOpacity(0.1),
    borderRadius: BorderRadius.circular(8),
  );

  // OTP digit box
  static InputDecoration otpBoxDecoration() => const InputDecoration(
    counterText: '',
    contentPadding: EdgeInsets.zero,
    enabledBorder: OutlineInputBorder(
      borderRadius: BorderRadius.all(Radius.circular(10)),
      borderSide: BorderSide(color: AppColors.borderInput),
    ),
    focusedBorder: OutlineInputBorder(
      borderRadius: BorderRadius.all(Radius.circular(10)),
      borderSide: BorderSide(color: AppColors.primary, width: 1.5),
    ),
    filled: true,
    fillColor: AppColors.backgroundInput,
  );

  // Bottom sheet handle
  static const BoxDecoration bottomSheetHandle = BoxDecoration(
    color: AppColors.borderLight,
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
    color: AppColors.primary,
    letterSpacing: 0.5,
  );

  // Dark variant background for splash text
  static const TextStyle appNameLight = TextStyle(
    fontFamily: 'Kameron',
    fontSize: 22,
    fontWeight: FontWeight.w700,
    color: AppColors.backgroundWhite,
    letterSpacing: 0.5,
  );
}
