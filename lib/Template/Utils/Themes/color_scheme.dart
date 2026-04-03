import 'package:flutter/material.dart';
import '../Constant/colors.dart';

class AppColorScheme {
  AppColorScheme._();

  static const ColorScheme light = ColorScheme.light(
    primary: AppColors.primary,
    primaryContainer: AppColors.primarySurface,
    secondary: AppColors.primaryLight,
    onSecondary: AppColors.textOnPrimary,
    error: AppColors.error,
    errorContainer: AppColors.errorSurface,
    onSurface: AppColors.textPrimary,
    surfaceContainerLowest: AppColors.backgroundLight,
    surfaceContainerLow: AppColors.backgroundLight,
    surfaceContainer: AppColors.backgroundWhite,
    surfaceContainerHigh: AppColors.backgroundGrey,
    surfaceContainerHighest: AppColors.backgroundInput,
    outline: AppColors.borderLight,
    outlineVariant: AppColors.borderInput,
  );

  static const ColorScheme dark = ColorScheme.dark(
    primary: AppColors.primaryLight,
    onPrimary: AppColors.textOnPrimary,
    primaryContainer: AppColors.primaryDark,
    secondary: AppColors.primary,
    onSecondary: AppColors.textOnPrimary,
    error: AppColors.error,
    errorContainer: AppColors.errorSurface,
    surface: AppColors.darkBackground,
    onSurface: AppColors.backgroundWhite,
    surfaceContainerLowest: AppColors.darkBackground,
    surfaceContainerLow: AppColors.darkBackground,
    surfaceContainer: AppColors.darkSurface,
    surfaceContainerHigh: AppColors.darkSurface,
    surfaceContainerHighest: AppColors.darkBorder,
    outline: AppColors.darkBorder,
    outlineVariant: AppColors.darkSurface,
  );
}
