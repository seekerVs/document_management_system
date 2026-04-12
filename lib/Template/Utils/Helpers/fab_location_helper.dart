import 'package:flutter/material.dart';

/// A custom FloatingActionButtonLocation that accounts for bottom safe areas (padding).
///
/// This ensures the FAB is positioned relative to the safe area rather than the
/// absolute bottom of the screen, providing consistent spacing on devices with
/// home indicators (like modern iPhones and Android gesture navigation).
class SafeEndFloatFabLocation extends FloatingActionButtonLocation {
  final double bottomOffset;

  /// Creates a [SafeEndFloatFabLocation] with a custom [bottomOffset].
  /// Usually, [bottomOffset] is the [MediaQuery.paddingOf(context).bottom].
  const SafeEndFloatFabLocation(this.bottomOffset);

  @override
  Offset getOffset(ScaffoldPrelayoutGeometry scaffoldGeometry) {
    // Get the standard endFloat offset
    final Offset standardOffset = FloatingActionButtonLocation.endFloat.getOffset(scaffoldGeometry);
    
    // Shift it upwards by the bottomOffset
    return Offset(standardOffset.dx, standardOffset.dy - bottomOffset);
  }

  @override
  String toString() => 'SafeEndFloatFabLocation(offset: $bottomOffset)';
}
