import 'package:hive_flutter/hive_flutter.dart';

class StorageService {
  static const String _settingsBoxName = 'settings';
  static const String _fieldGuideKey = 'show_field_guide';

  /// Initialize Hive and open necessary boxes
  static Future<void> init() async {
    await Hive.initFlutter();
    await Hive.openBox(_settingsBoxName);
  }

  /// Check if the field placement guide should be shown
  static bool shouldShowFieldGuide() {
    final box = Hive.box(_settingsBoxName);
    return box.get(_fieldGuideKey, defaultValue: true);
  }

  /// Update the preference for showing the field guide
  static Future<void> setFieldGuidePreference(bool show) async {
    final box = Hive.box(_settingsBoxName);
    await box.put(_fieldGuideKey, show);
  }
}
