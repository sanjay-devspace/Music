import 'package:flutter/material.dart';
import 'device_type.dart';
import 'dart:ui';

/// Responsive breakpoints and analysis helpers.
///
/// Never compare against raw width values in views — use the functions here
/// or the high level [Responsive] facade.
abstract class ResponsiveBreakpoints {
  static const double phoneSmallMax = 360;
  static const double phoneMax = 600;
  static const double tabletMax = 1024;
  static const double desktopMax = 1440;

  /// Classify a box of [shortestSide], [width] and [height].
  static DeviceType fromSize(Size size) {
    final shortest = size.shortestSide;
    final width = size.width;
    if (shortest < phoneSmallMax || width < phoneSmallMax) {
      return DeviceType.phoneSmall;
    }
    if (shortest < phoneMax) return DeviceType.phone;
    if (width < tabletMax && shortest < tabletMax) return DeviceType.tablet;
    if (width < desktopMax) return DeviceType.desktop;
    return DeviceType.largeDesktop;
  }

  /// Orientation-aware classification (used by landscape layouts).
  static DeviceType fromOriented(Size size) =>
      size.width > size.height && size.shortestSide < phoneSmallMax
          ? DeviceType.phone
          : fromSize(size);
}

/// Angular aware adjustments for very small phones.
const double shortestSideMin = 320;