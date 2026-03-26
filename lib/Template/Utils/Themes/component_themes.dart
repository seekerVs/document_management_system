import 'package:flutter/material.dart';
import '../Constant/colors.dart';
import 'theme_radius.dart';

class AppComponentThemes {
  AppComponentThemes._();

  // ─── AppBar ───────────────────────────────────────────────────────────────

  static const AppBarTheme lightAppBar = AppBarTheme(
    centerTitle: true,
    elevation: 0,
    scrolledUnderElevation: 0,
    backgroundColor: AppColors.backgroundLight,
    foregroundColor: AppColors.textPrimary,
    titleTextStyle: TextStyle(
      fontSize: 18,
      fontWeight: FontWeight.w600,
      color: AppColors.textPrimary,
    ),
    iconTheme: IconThemeData(color: AppColors.textPrimary, size: 28),
  );

  static const AppBarTheme darkAppBar = AppBarTheme(
    centerTitle: true,
    elevation: 0,
    scrolledUnderElevation: 0,
    backgroundColor: AppColors.darkBackground,
    foregroundColor: AppColors.textOnPrimary,
    titleTextStyle: TextStyle(
      fontSize: 18,
      fontWeight: FontWeight.w600,
      color: AppColors.textOnPrimary,
    ),
    iconTheme: IconThemeData(color: AppColors.textOnPrimary, size: 28),
  );

  // ─── Input decoration ─────────────────────────────────────────────────────

  static InputDecorationTheme lightInput = InputDecorationTheme(
    filled: true,
    fillColor: AppColors.backgroundInput,
    border: OutlineInputBorder(
      borderRadius: BorderRadius.circular(ThemeRadius.md),
      borderSide: const BorderSide(color: AppColors.borderInput),
    ),
    enabledBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(ThemeRadius.md),
      borderSide: const BorderSide(color: AppColors.borderInput),
    ),
    focusedBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(ThemeRadius.md),
      borderSide: const BorderSide(color: AppColors.primary, width: 1.5),
    ),
    errorBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(ThemeRadius.md),
      borderSide: const BorderSide(color: AppColors.error),
    ),
    focusedErrorBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(ThemeRadius.md),
      borderSide: const BorderSide(color: AppColors.error, width: 1.5),
    ),
    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
    hintStyle: const TextStyle(color: AppColors.textHint, fontSize: 14),
    prefixIconColor: AppColors.textHint,
    suffixIconColor: AppColors.textHint,
    errorStyle: const TextStyle(color: AppColors.error, fontSize: 12),
  );

  static InputDecorationTheme darkInput = InputDecorationTheme(
    filled: true,
    fillColor: AppColors.darkSurface,
    border: OutlineInputBorder(
      borderRadius: BorderRadius.circular(ThemeRadius.md),
      borderSide: const BorderSide(color: AppColors.darkBorder),
    ),
    enabledBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(ThemeRadius.md),
      borderSide: const BorderSide(color: AppColors.darkBorder),
    ),
    focusedBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(ThemeRadius.md),
      borderSide: const BorderSide(color: AppColors.primaryLight, width: 1.5),
    ),
    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
    hintStyle: const TextStyle(color: AppColors.textHint, fontSize: 14),
    prefixIconColor: AppColors.textHint,
    suffixIconColor: AppColors.textHint,
  );

  // ─── Elevated button ──────────────────────────────────────────────────────

  static ElevatedButtonThemeData elevatedButton = ElevatedButtonThemeData(
    style: ElevatedButton.styleFrom(
      backgroundColor: AppColors.primary,
      foregroundColor: AppColors.textOnPrimary,
      disabledBackgroundColor: AppColors.borderInput,
      disabledForegroundColor: AppColors.textDisabled,
      elevation: 0,
      shadowColor: Colors.transparent,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(ThemeRadius.round),
      ),
      minimumSize: const Size(double.infinity, 52),
      textStyle: const TextStyle(
        fontSize: 16,
        fontWeight: FontWeight.w600,
        letterSpacing: 0.3,
      ),
    ),
  );

  // ─── Text button ──────────────────────────────────────────────────────────

  static TextButtonThemeData textButton = TextButtonThemeData(
    style: TextButton.styleFrom(
      foregroundColor: AppColors.primary,
      textStyle: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
      padding: const EdgeInsets.symmetric(horizontal: 4),
      minimumSize: Size.zero,
      tapTargetSize: MaterialTapTargetSize.shrinkWrap,
    ),
  );

  // ─── Outlined button ──────────────────────────────────────────────────────

  static OutlinedButtonThemeData outlinedButton = OutlinedButtonThemeData(
    style: OutlinedButton.styleFrom(
      foregroundColor: AppColors.textPrimary,
      backgroundColor: AppColors.backgroundWhite,
      side: const BorderSide(color: AppColors.borderInput),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(ThemeRadius.round),
      ),
      minimumSize: const Size(double.infinity, 52),
      textStyle: const TextStyle(fontSize: 15, fontWeight: FontWeight.w500),
    ),
  );

  // ─── Icon button ──────────────────────────────────────────────────────────

  static IconButtonThemeData iconButton = IconButtonThemeData(
    style: IconButton.styleFrom(foregroundColor: AppColors.textHint),
  );

  // ─── FAB ──────────────────────────────────────────────────────────────────

  static const FloatingActionButtonThemeData fab =
      FloatingActionButtonThemeData(
        backgroundColor: AppColors.primary,
        foregroundColor: AppColors.textOnPrimary,
        elevation: 2,
        shape: CircleBorder(),
      );

  // ─── Card ─────────────────────────────────────────────────────────────────

  static CardThemeData lightCard = CardThemeData(
    elevation: 0,
    color: AppColors.backgroundWhite,
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(ThemeRadius.lg),
      side: const BorderSide(color: AppColors.borderLight),
    ),
    margin: EdgeInsets.zero,
  );

  static CardThemeData darkCard = CardThemeData(
    elevation: 0,
    color: AppColors.darkSurface,
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(ThemeRadius.lg),
      side: const BorderSide(color: AppColors.darkBorder),
    ),
    margin: EdgeInsets.zero,
  );

  // ─── List tile ────────────────────────────────────────────────────────────

  static const ListTileThemeData listTile = ListTileThemeData(
    contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 4),
    iconColor: AppColors.textSecondary,
    titleTextStyle: TextStyle(
      fontSize: 14,
      fontWeight: FontWeight.w500,
      color: AppColors.textPrimary,
    ),
    subtitleTextStyle: TextStyle(fontSize: 12, color: AppColors.textSecondary),
  );

  // ─── Checkbox ────────────────────────────────────────────────────────────

  static CheckboxThemeData checkbox = CheckboxThemeData(
    fillColor: WidgetStateProperty.resolveWith((states) {
      if (states.contains(WidgetState.selected)) return AppColors.primary;
      return Colors.transparent;
    }),
    side: const BorderSide(color: AppColors.borderInput, width: 1.5),
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
  );

  // ─── Divider ─────────────────────────────────────────────────────────────

  static const DividerThemeData lightDivider = DividerThemeData(
    color: AppColors.borderLight,
    thickness: 1,
    space: 1,
  );

  static const DividerThemeData darkDivider = DividerThemeData(
    color: AppColors.darkBorder,
    thickness: 1,
    space: 1,
  );

  // ─── Bottom sheet ─────────────────────────────────────────────────────────

  static const BottomSheetThemeData lightBottomSheet = BottomSheetThemeData(
    backgroundColor: AppColors.backgroundWhite,
    elevation: 0,
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(
        top: Radius.circular(ThemeRadius.bottomSheet),
      ),
    ),
  );

  // ─── Bottom nav bar ───────────────────────────────────────────────────────

  static const BottomNavigationBarThemeData
  lightBottomNav = BottomNavigationBarThemeData(
    backgroundColor: AppColors.backgroundWhite,
    selectedItemColor: AppColors.primary,
    unselectedItemColor: AppColors.textHint,
    showSelectedLabels: true,
    showUnselectedLabels: true,
    elevation: 8,
    type: BottomNavigationBarType.fixed,
    selectedLabelStyle: TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
    unselectedLabelStyle: TextStyle(fontSize: 12, fontWeight: FontWeight.w400),
  );

  static const BottomNavigationBarThemeData darkBottomNav =
      BottomNavigationBarThemeData(
        backgroundColor: AppColors.darkBackground,
        selectedItemColor: AppColors.primaryLight,
        unselectedItemColor: AppColors.darkBorder,
        showSelectedLabels: true,
        showUnselectedLabels: true,
        type: BottomNavigationBarType.fixed,
      );

  // ─── Tab bar ──────────────────────────────────────────────────────────────

  static const TabBarThemeData tabBar = TabBarThemeData(
    labelColor: AppColors.primary,
    unselectedLabelColor: AppColors.textHint,
    indicatorColor: AppColors.primary,
    indicatorSize: TabBarIndicatorSize.tab,
    labelStyle: TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
    unselectedLabelStyle: TextStyle(fontSize: 14, fontWeight: FontWeight.w400),
  );

  // ─── Chip ─────────────────────────────────────────────────────────────────

  static ChipThemeData chip = ChipThemeData(
    backgroundColor: AppColors.backgroundGrey,
    selectedColor: AppColors.primarySurface,
    labelStyle: const TextStyle(fontSize: 13, color: AppColors.textPrimary),
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(ThemeRadius.round),
    ),
    side: BorderSide.none,
    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
  );

  // ─── Dialog ───────────────────────────────────────────────────────────────

  static DialogThemeData dialog = DialogThemeData(
    backgroundColor: AppColors.backgroundWhite,
    elevation: 0,
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(ThemeRadius.xl),
    ),
    titleTextStyle: const TextStyle(
      fontSize: 18,
      fontWeight: FontWeight.w600,
      color: AppColors.textPrimary,
    ),
    contentTextStyle: const TextStyle(
      fontSize: 14,
      color: AppColors.textSecondary,
    ),
  );

  // ─── Snackbar ─────────────────────────────────────────────────────────────

  static SnackBarThemeData lightSnackBar = SnackBarThemeData(
    backgroundColor: AppColors.textPrimary,
    contentTextStyle: const TextStyle(
      color: AppColors.textOnPrimary,
      fontSize: 14,
    ),
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(ThemeRadius.sm),
    ),
    behavior: SnackBarBehavior.floating,
    insetPadding: const EdgeInsets.all(16),
  );

  static SnackBarThemeData darkSnackBar = SnackBarThemeData(
    backgroundColor: AppColors.darkSurface,
    contentTextStyle: const TextStyle(
      color: AppColors.textOnPrimary,
      fontSize: 14,
    ),
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(ThemeRadius.sm),
    ),
    behavior: SnackBarBehavior.floating,
  );

  // ─── Progress indicator ───────────────────────────────────────────────────

  static const ProgressIndicatorThemeData lightProgress =
      ProgressIndicatorThemeData(color: AppColors.primary);

  static const ProgressIndicatorThemeData darkProgress =
      ProgressIndicatorThemeData(color: AppColors.primaryLight);

  // ─── Popup menu ───────────────────────────────────────────────────────────

  static PopupMenuThemeData popupMenu = PopupMenuThemeData(
    color: AppColors.backgroundWhite,
    elevation: 8,
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(ThemeRadius.lg),
    ),
    textStyle: const TextStyle(fontSize: 13, color: AppColors.textPrimary),
  );

  // ─── Menu (MenuAnchor) ────────────────────────────────────────────────────
  // Single source of truth for all MenuAnchor styling.
  // appMenuStyle can be used directly on MenuAnchor.style for consistency.

  static MenuStyle get appMenuStyle => MenuStyle(
    backgroundColor: const WidgetStatePropertyAll(AppColors.backgroundWhite),
    elevation: const WidgetStatePropertyAll(8),
    shadowColor: const WidgetStatePropertyAll(Colors.black26),
    surfaceTintColor: const WidgetStatePropertyAll(Colors.transparent),
    padding: const WidgetStatePropertyAll(EdgeInsets.symmetric(vertical: 4)),
    shape: WidgetStatePropertyAll(
      RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(ThemeRadius.lg),
      ),
    ),
  );

  static MenuThemeData get menuTheme => MenuThemeData(style: appMenuStyle);

  static MenuButtonThemeData menuButtonTheme = const MenuButtonThemeData(
    style: ButtonStyle(
      minimumSize: WidgetStatePropertyAll(Size(160, 36)),
      padding: WidgetStatePropertyAll(EdgeInsets.symmetric(horizontal: 16)),
      tapTargetSize: MaterialTapTargetSize.shrinkWrap,
      foregroundColor: WidgetStatePropertyAll(AppColors.textPrimary),
      iconColor: WidgetStatePropertyAll(AppColors.textSecondary),
      iconSize: WidgetStatePropertyAll(16),
      textStyle: WidgetStatePropertyAll(TextStyle(fontSize: 13)),
    ),
  );
}
