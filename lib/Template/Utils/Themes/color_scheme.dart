import 'package:flutter/material.dart';
import '../Constant/colors.dart';

class AppColorScheme {
  AppColorScheme._();

  static const ColorScheme light = ColorScheme.light(
    primary: AppColors.blue,
    primaryContainer: AppColors.background,
    secondary: AppColors.blueLight,
    onSecondary: AppColors.textOnPrimary,
    error: AppColors.red,
    errorContainer: AppColors.redLight,
    onSurface: AppColors.textPrimary,
    surfaceContainerLowest: AppColors.background,
    surfaceContainerLow: AppColors.background,
    surfaceContainer: AppColors.white,
    surfaceContainerHigh: AppColors.grey,
    surfaceContainerHighest: AppColors.backgroundInput,
    outline: AppColors.grey,
    outlineVariant: AppColors.grey,
  );

  static const ColorScheme dark = ColorScheme.dark(
    primary: AppColors.blueLight,
    onPrimary: AppColors.textOnPrimary,
    primaryContainer: AppColors.blueDark,
    secondary: AppColors.blue,
    onSecondary: AppColors.textOnPrimary,
    error: AppColors.red,
    errorContainer: AppColors.redLight,
    surface: AppColors.textPrimary,
    surfaceContainerLowest: AppColors.textPrimary,
    surfaceContainerLow: AppColors.textPrimary,
    surfaceContainer: AppColors.darkSurface,
    surfaceContainerHigh: AppColors.darkSurface,
    surfaceContainerHighest: AppColors.darkBorder,
    outline: AppColors.darkBorder,
    outlineVariant: AppColors.darkSurface,
  );
}
