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
    scaffoldBackgroundColor: AppColors.backgroundLight,
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
    scaffoldBackgroundColor: AppColors.darkBackground,
    colorScheme: AppColorScheme.dark,
    appBarTheme: AppComponentThemes.darkAppBar,
    inputDecorationTheme: AppComponentThemes.darkInput,
    elevatedButtonTheme: AppComponentThemes.elevatedButton,
    floatingActionButtonTheme: AppComponentThemes.fab,
    cardTheme: AppComponentThemes.darkCard,
    listTileTheme: AppComponentThemes.listTile,
    dividerTheme: AppComponentThemes.darkDivider,
    bottomNavigationBarTheme: AppComponentThemes.darkBottomNav,
    snackBarTheme: AppComponentThemes.darkSnackBar,
    progressIndicatorTheme: AppComponentThemes.darkProgress,
  );
}
