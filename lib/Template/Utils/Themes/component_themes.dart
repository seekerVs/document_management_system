import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'color_scheme.dart';
import 'theme_radius.dart';

class AppComponentThemes {
  AppComponentThemes._();

  // ─── AppBar ───────────────────────────────────────────────────────────────

  static const AppBarTheme lightAppBar = AppBarTheme(
    systemOverlayStyle: SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.dark,
      systemNavigationBarColor: Colors.transparent,
      systemNavigationBarIconBrightness: Brightness.dark,
      systemNavigationBarDividerColor: Colors.transparent,
    ),
    centerTitle: true,
    elevation: 0,
    scrolledUnderElevation: 0,
    backgroundColor: Color(0xfff0f3fc), // surfaceContainerLow light
    foregroundColor: Color(0xff181c22), // onSurface light
    titleTextStyle: TextStyle(
      fontSize: 18,
      fontWeight: FontWeight.w600,
      color: Color(0xff181c22),
    ),
    iconTheme: IconThemeData(color: Color(0xff181c22), size: 28),
  );

  static const AppBarTheme darkAppBar = AppBarTheme(
    systemOverlayStyle: SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.light,
      systemNavigationBarColor: Colors.transparent,
      systemNavigationBarIconBrightness: Brightness.light,
      systemNavigationBarDividerColor: Colors.transparent,
    ),
    centerTitle: true,
    elevation: 0,
    scrolledUnderElevation: 0,
    backgroundColor: Color(0xff181c22), // surfaceContainerLow dark
    foregroundColor: Color(0xffdfe2eb), // onSurface dark
    titleTextStyle: TextStyle(
      fontSize: 18,
      fontWeight: FontWeight.w600,
      color: Color(0xffdfe2eb),
    ),
    iconTheme: IconThemeData(color: Color(0xffdfe2eb), size: 28),
  );

  // ─── Input decoration ─────────────────────────────────────────────────────

  static InputDecorationTheme lightInput = InputDecorationTheme(
    filled: true,
    fillColor: AppColorScheme.light.surfaceContainerHighest,
    border: OutlineInputBorder(
      borderRadius: BorderRadius.circular(ThemeRadius.md),
      borderSide: BorderSide(color: AppColorScheme.light.outline),
    ),
    enabledBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(ThemeRadius.md),
      borderSide: BorderSide(color: AppColorScheme.light.outline),
    ),
    focusedBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(ThemeRadius.md),
      borderSide: BorderSide(color: AppColorScheme.light.primary, width: 1.5),
    ),
    errorBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(ThemeRadius.md),
      borderSide: BorderSide(color: AppColorScheme.light.error),
    ),
    focusedErrorBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(ThemeRadius.md),
      borderSide: BorderSide(color: AppColorScheme.light.error, width: 1.5),
    ),
    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
    hintStyle: TextStyle(
      color: AppColorScheme.light.onSurfaceVariant,
      fontSize: 14,
    ),
    prefixIconColor: AppColorScheme.light.onSurfaceVariant,
    suffixIconColor: AppColorScheme.light.onSurfaceVariant,
    errorStyle: TextStyle(color: AppColorScheme.light.error, fontSize: 12),
  );

  static InputDecorationTheme darkInput = InputDecorationTheme(
    filled: true,
    fillColor: AppColorScheme.dark.surfaceContainerHighest,
    border: OutlineInputBorder(
      borderRadius: BorderRadius.circular(ThemeRadius.md),
      borderSide: BorderSide(color: AppColorScheme.dark.outline),
    ),
    enabledBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(ThemeRadius.md),
      borderSide: BorderSide(color: AppColorScheme.dark.outline),
    ),
    focusedBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(ThemeRadius.md),
      borderSide: BorderSide(color: AppColorScheme.dark.primary, width: 1.5),
    ),
    errorBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(ThemeRadius.md),
      borderSide: BorderSide(color: AppColorScheme.dark.error),
    ),
    focusedErrorBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(ThemeRadius.md),
      borderSide: BorderSide(color: AppColorScheme.dark.error, width: 1.5),
    ),
    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
    hintStyle: TextStyle(
      color: AppColorScheme.dark.onSurfaceVariant,
      fontSize: 14,
    ),
    labelStyle: TextStyle(
      color: AppColorScheme.dark.onSurfaceVariant,
      fontSize: 14,
    ),
    prefixIconColor: AppColorScheme.dark.onSurfaceVariant,
    suffixIconColor: AppColorScheme.dark.onSurfaceVariant,
    errorStyle: TextStyle(color: AppColorScheme.dark.error, fontSize: 12),
  );

  // ─── Elevated button ──────────────────────────────────────────────────────

  static ElevatedButtonThemeData elevatedButton = ElevatedButtonThemeData(
    style: ElevatedButton.styleFrom(
      backgroundColor: AppColorScheme.light.primary,
      foregroundColor: AppColorScheme.light.onPrimary,
      disabledBackgroundColor: AppColorScheme.light.outline,
      disabledForegroundColor: AppColorScheme.light.outlineVariant,
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
      foregroundColor: AppColorScheme.light.primary,
      textStyle: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
      padding: const EdgeInsets.symmetric(horizontal: 4),
      minimumSize: Size.zero,
      tapTargetSize: MaterialTapTargetSize.shrinkWrap,
    ),
  );

  // ─── Outlined button ──────────────────────────────────────────────────────

  static OutlinedButtonThemeData outlinedButton = OutlinedButtonThemeData(
    style: OutlinedButton.styleFrom(
      foregroundColor: AppColorScheme.light.onSurface,
      backgroundColor: AppColorScheme.light.surface,
      side: BorderSide(color: AppColorScheme.light.outlineVariant),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(ThemeRadius.round),
      ),
      minimumSize: const Size(double.infinity, 52),
      textStyle: const TextStyle(fontSize: 15, fontWeight: FontWeight.w500),
    ),
  );

  static OutlinedButtonThemeData darkOutlinedButton = OutlinedButtonThemeData(
    style: OutlinedButton.styleFrom(
      foregroundColor: AppColorScheme.dark.onSurface,
      backgroundColor: AppColorScheme.dark.surfaceContainer,
      side: BorderSide(color: AppColorScheme.dark.outlineVariant),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(ThemeRadius.round),
      ),
      minimumSize: const Size(double.infinity, 52),
      textStyle: const TextStyle(fontSize: 15, fontWeight: FontWeight.w500),
    ),
  );

  // ─── Icon button ──────────────────────────────────────────────────────────

  static IconButtonThemeData iconButton = IconButtonThemeData(
    style: IconButton.styleFrom(
      foregroundColor: AppColorScheme.light.onSurfaceVariant,
    ),
  );

  static IconButtonThemeData darkIconButton = IconButtonThemeData(
    style: IconButton.styleFrom(
      foregroundColor: AppColorScheme.dark.onSurfaceVariant,
    ),
  );

  // ─── FAB ──────────────────────────────────────────────────────────────────

  static FloatingActionButtonThemeData fab = FloatingActionButtonThemeData(
    backgroundColor: AppColorScheme.light.primary,
    foregroundColor: AppColorScheme.light.onPrimary,
    elevation: 2,
    shape: const CircleBorder(),
  );

  // ─── Card ─────────────────────────────────────────────────────────────────

  static CardThemeData lightCard = CardThemeData(
    elevation: 0,
    color: AppColorScheme.light.surface,
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(ThemeRadius.lg),
      side: BorderSide(color: AppColorScheme.light.outlineVariant),
    ),
    margin: EdgeInsets.zero,
  );

  static CardThemeData darkCard = CardThemeData(
    elevation: 0,
    color: AppColorScheme.dark.surfaceContainer,
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(ThemeRadius.lg),
      side: BorderSide(color: AppColorScheme.dark.outlineVariant),
    ),
    margin: EdgeInsets.zero,
  );

  // ─── List tile ────────────────────────────────────────────────────────────

  static ListTileThemeData listTile = ListTileThemeData(
    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
    iconColor: AppColorScheme.light.onSurfaceVariant,
    titleTextStyle: TextStyle(
      fontSize: 14,
      fontWeight: FontWeight.w500,
      color: AppColorScheme.light.onSurface,
    ),
    subtitleTextStyle: TextStyle(
      fontSize: 12,
      color: AppColorScheme.light.onSurfaceVariant,
    ),
  );

  static ListTileThemeData darkListTile = ListTileThemeData(
    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
    iconColor: AppColorScheme.dark.outlineVariant,
    titleTextStyle: TextStyle(
      fontSize: 14,
      fontWeight: FontWeight.w500,
      color: AppColorScheme.dark.onSurface,
    ),
    subtitleTextStyle: TextStyle(
      fontSize: 12,
      color: AppColorScheme.dark.onSurfaceVariant,
    ),
  );

  // ─── Checkbox ────────────────────────────────────────────────────────────

  static CheckboxThemeData checkbox = CheckboxThemeData(
    fillColor: WidgetStateProperty.resolveWith((states) {
      if (states.contains(WidgetState.selected)) {
        return AppColorScheme.light.primary;
      }
      return Colors.transparent;
    }),
    side: BorderSide(color: AppColorScheme.light.outline, width: 1.5),
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
  );

  // ─── Divider ─────────────────────────────────────────────────────────────

  static DividerThemeData lightDivider = DividerThemeData(
    color: AppColorScheme.light.outlineVariant,
    thickness: 1,
    space: 1,
  );

  static DividerThemeData darkDivider = DividerThemeData(
    color: AppColorScheme.dark.outlineVariant,
    thickness: 1,
    space: 1,
  );

  // ─── Bottom sheet ─────────────────────────────────────────────────────────

  static BottomSheetThemeData lightBottomSheet = BottomSheetThemeData(
    backgroundColor: AppColorScheme.light.surface,
    elevation: 0,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(
        top: Radius.circular(ThemeRadius.bottomSheet),
      ),
    ),
  );

  static BottomSheetThemeData darkBottomSheet = BottomSheetThemeData(
    backgroundColor: AppColorScheme.dark.surfaceContainer,
    elevation: 0,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(
        top: Radius.circular(ThemeRadius.bottomSheet),
      ),
    ),
  );

  // ─── Bottom nav bar ───────────────────────────────────────────────────────

  static BottomNavigationBarThemeData lightBottomNav =
      BottomNavigationBarThemeData(
        backgroundColor: AppColorScheme.light.surface,
        selectedItemColor: AppColorScheme.light.primary,
        unselectedItemColor: AppColorScheme.light.outline,
        showSelectedLabels: true,
        showUnselectedLabels: true,
        elevation: 8,
        type: BottomNavigationBarType.fixed,
        selectedLabelStyle: const TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w600,
        ),
        unselectedLabelStyle: const TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w400,
        ),
      );

  static BottomNavigationBarThemeData darkBottomNav =
      BottomNavigationBarThemeData(
        backgroundColor: AppColorScheme.dark.surface,
        selectedItemColor: AppColorScheme.dark.primary,
        unselectedItemColor: AppColorScheme.dark.outlineVariant,
        showSelectedLabels: true,
        showUnselectedLabels: true,
        type: BottomNavigationBarType.fixed,
      );

  // ─── Tab bar ──────────────────────────────────────────────────────────────

  static TabBarThemeData tabBar = TabBarThemeData(
    labelColor: AppColorScheme.light.primary,
    unselectedLabelColor: AppColorScheme.light.outline,
    indicatorColor: AppColorScheme.light.primary,
    indicatorSize: TabBarIndicatorSize.tab,
    labelStyle: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
    unselectedLabelStyle: const TextStyle(
      fontSize: 14,
      fontWeight: FontWeight.w400,
    ),
  );

  static TabBarThemeData darkTabBar = TabBarThemeData(
    labelColor: AppColorScheme.dark.primary,
    unselectedLabelColor: AppColorScheme.dark.outlineVariant,
    indicatorColor: AppColorScheme.dark.primary,
    indicatorSize: TabBarIndicatorSize.tab,
    labelStyle: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
    unselectedLabelStyle: const TextStyle(
      fontSize: 14,
      fontWeight: FontWeight.w400,
    ),
  );

  // ─── Chip ─────────────────────────────────────────────────────────────────

  static ChipThemeData chip = ChipThemeData(
    backgroundColor: AppColorScheme.light.surfaceContainerHigh,
    selectedColor: AppColorScheme.light.primaryContainer,
    labelStyle: TextStyle(fontSize: 13, color: AppColorScheme.light.onSurface),
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(ThemeRadius.round),
    ),
    side: BorderSide.none,
    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
  );

  static ChipThemeData darkChip = ChipThemeData(
    backgroundColor: AppColorScheme.dark.surfaceContainer,
    selectedColor: AppColorScheme.dark.primaryContainer,
    labelStyle: TextStyle(fontSize: 13, color: AppColorScheme.dark.onSurface),
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(ThemeRadius.round),
      side: BorderSide(color: AppColorScheme.dark.outlineVariant),
    ),
    side: BorderSide(color: AppColorScheme.dark.outlineVariant),
    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
  );

  // ─── Dialog ───────────────────────────────────────────────────────────────

  static DialogThemeData dialog = DialogThemeData(
    backgroundColor: AppColorScheme.light.surface,
    elevation: 0,
    insetPadding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 24.0),
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(ThemeRadius.xl),
    ),
    titleTextStyle: TextStyle(
      fontSize: 18,
      fontWeight: FontWeight.w600,
      color: AppColorScheme.light.onSurface,
    ),
    contentTextStyle: TextStyle(
      fontSize: 14,
      color: AppColorScheme.light.onSurfaceVariant,
    ),
  );

  static DialogThemeData darkDialog = DialogThemeData(
    backgroundColor: AppColorScheme.dark.surfaceContainer,
    elevation: 0,
    insetPadding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 24.0),
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(ThemeRadius.xl),
    ),
    titleTextStyle: TextStyle(
      fontSize: 18,
      fontWeight: FontWeight.w600,
      color: AppColorScheme.dark.onSurface,
    ),
    contentTextStyle: TextStyle(
      fontSize: 14,
      color: AppColorScheme.dark.onSurfaceVariant,
    ),
  );

  // ─── Snackbar ─────────────────────────────────────────────────────────────

  static SnackBarThemeData lightSnackBar = SnackBarThemeData(
    backgroundColor: AppColorScheme.light.onSurface,
    contentTextStyle: TextStyle(
      color: AppColorScheme.light.surface,
      fontSize: 14,
    ),
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(ThemeRadius.sm),
    ),
    behavior: SnackBarBehavior.floating,
    insetPadding: const EdgeInsets.all(16),
  );

  static SnackBarThemeData darkSnackBar = SnackBarThemeData(
    backgroundColor: AppColorScheme.dark.surfaceContainer,
    contentTextStyle: TextStyle(
      color: AppColorScheme.dark.onSurface,
      fontSize: 14,
    ),
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(ThemeRadius.sm),
    ),
    behavior: SnackBarBehavior.floating,
  );

  // ─── Progress indicator ───────────────────────────────────────────────────

  static ProgressIndicatorThemeData lightProgress = ProgressIndicatorThemeData(
    color: AppColorScheme.light.primary,
  );

  static ProgressIndicatorThemeData darkProgress = ProgressIndicatorThemeData(
    color: AppColorScheme.dark.primary,
  );

  // ─── Popup menu ───────────────────────────────────────────────────────────

  static PopupMenuThemeData popupMenu = PopupMenuThemeData(
    color: AppColorScheme.light.surface,
    elevation: 8,
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(ThemeRadius.lg),
    ),
    textStyle: TextStyle(fontSize: 13, color: AppColorScheme.light.onSurface),
  );

  static PopupMenuThemeData darkPopupMenu = PopupMenuThemeData(
    color: AppColorScheme.dark.surfaceContainer,
    elevation: 8,
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(ThemeRadius.lg),
      side: BorderSide(color: AppColorScheme.dark.outlineVariant),
    ),
    textStyle: TextStyle(fontSize: 13, color: AppColorScheme.dark.onSurface),
  );



  static MenuButtonThemeData menuButtonTheme = MenuButtonThemeData(
    style: ButtonStyle(
      minimumSize: const WidgetStatePropertyAll(Size(160, 36)),
      padding: const WidgetStatePropertyAll(
        EdgeInsets.symmetric(horizontal: 16),
      ),
      tapTargetSize: MaterialTapTargetSize.shrinkWrap,
      foregroundColor: WidgetStatePropertyAll(AppColorScheme.light.onSurface),
      iconColor: WidgetStatePropertyAll(AppColorScheme.light.onSurfaceVariant),
      iconSize: const WidgetStatePropertyAll(16),
      textStyle: const WidgetStatePropertyAll(TextStyle(fontSize: 13)),
    ),
  );
}
