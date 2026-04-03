import 'package:flutter/material.dart';

import '../Constant/colors.dart';
import 'color_scheme.dart';
import 'component_themes.dart';
import 'text_theme.dart';

class AppTheme {
  AppTheme._();

  static ThemeData get light => ThemeData(
    useMaterial3: true,
    fontFamily: 'Inter',
    scaffoldBackgroundColor: AppColors.background,
    colorScheme: AppColorScheme.light,
    textTheme: AppTextTheme.light,
    appBarTheme: AppComponentThemes.lightAppBar,
    inputDecorationTheme: AppComponentThemes.lightInput,
    elevatedButtonTheme: AppComponentThemes.elevatedButton,
    textButtonTheme: AppComponentThemes.textButton,
    outlinedButtonTheme: AppComponentThemes.outlinedButton,
    iconButtonTheme: AppComponentThemes.iconButton,
    floatingActionButtonTheme: AppComponentThemes.fab,
    cardTheme: AppComponentThemes.lightCard,
    listTileTheme: AppComponentThemes.listTile,
    checkboxTheme: AppComponentThemes.checkbox,
    dividerTheme: AppComponentThemes.lightDivider,
    bottomSheetTheme: AppComponentThemes.lightBottomSheet,
    bottomNavigationBarTheme: AppComponentThemes.lightBottomNav,
    tabBarTheme: AppComponentThemes.tabBar,
    chipTheme: AppComponentThemes.chip,
    dialogTheme: AppComponentThemes.dialog,
    snackBarTheme: AppComponentThemes.lightSnackBar,
    progressIndicatorTheme: AppComponentThemes.lightProgress,
    popupMenuTheme: AppComponentThemes.popupMenu,
  );

  static ThemeData get dark => ThemeData(
    useMaterial3: true,
    fontFamily: 'Inter',
    scaffoldBackgroundColor: AppColors.textPrimary,
    colorScheme: AppColorScheme.dark,
    textTheme: AppTextTheme.dark,
    appBarTheme: AppComponentThemes.darkAppBar,
    inputDecorationTheme: AppComponentThemes.darkInput,
    elevatedButtonTheme: AppComponentThemes.elevatedButton,
    textButtonTheme: AppComponentThemes.textButton,
    outlinedButtonTheme: AppComponentThemes.darkOutlinedButton,
    iconButtonTheme: AppComponentThemes.darkIconButton,
    floatingActionButtonTheme: AppComponentThemes.fab,
    cardTheme: AppComponentThemes.darkCard,
    listTileTheme: AppComponentThemes.darkListTile,
    checkboxTheme: AppComponentThemes.checkbox,
    dividerTheme: AppComponentThemes.darkDivider,
    bottomSheetTheme: AppComponentThemes.darkBottomSheet,
    bottomNavigationBarTheme: AppComponentThemes.darkBottomNav,
    tabBarTheme: AppComponentThemes.darkTabBar,
    chipTheme: AppComponentThemes.darkChip,
    dialogTheme: AppComponentThemes.darkDialog,
    snackBarTheme: AppComponentThemes.darkSnackBar,
    progressIndicatorTheme: AppComponentThemes.darkProgress,
    popupMenuTheme: AppComponentThemes.darkPopupMenu,
  );
}
