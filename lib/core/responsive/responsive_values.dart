import 'dart:math';
import 'package:flutter/material.dart';
import 'screen_size.dart';
import 'device_type.dart';

/// Interpolated responsive values bound to the current [ScreenSize].
///
/// Every screen can build a `ResponsiveValues` instance from a [ScreenSize]
/// and receive sane defaults for padding, font sizes, icon sizes, radius,
/// artwork size and grid columns — all derived from the actual device.
class ResponsiveValues {
  const ResponsiveValues({
    required this.isLandscape,
    required this.width,
    required this.height,
    required this.textScaleFactor,
    required this.padding,
    required this.fontSize,
    required this.iconSize,
    required this.radius,
    required this.spacing,
    required this.artworkSize,
    required this.gridColumns,
    required this.cardAspectRatio,
  });

  factory ResponsiveValues.fromScreenSize(
    ScreenSize screen, {
    DeviceType? deviceType,
  }) {
    final w = screen.width;
    final h = screen.height;
    final landscape = screen.isLandscape;
    final type = deviceType ?? _classify(screen);
    final phone = type.isMobile;
    final textScale = screen.textScaleFactor;

    final base = 16.0 * (phone ? 1.0 : 1.1);
    final spacingFactor = (w / base).clamp(0.75, 1.5);

    // Comfortable padding scales with width but never exceeds 40 on phones.
    final paddingConstrained = ConstrainedSize(
      phone ? min(20.0, 16 + w * 0.012) : 24.0 + w * 0.02,
      max: 48.0,
    );

    final artworkSize = type == DeviceType.phoneSmall
      ? min(120.0, w * 0.30)
      : type.isPhone
          ? min(140.0, w * 0.30)
      : type == DeviceType.tablet
          ? min(200.0, w * 0.22)
      : type == DeviceType.desktop
          ? min(240.0, w * 0.16)
          : min(300.0, w * 0.15);

    return ResponsiveValues(
      isLandscape: landscape,
      width: w,
      height: h,
      textScaleFactor: textScale,
      padding: EdgeInsets.all(paddingConstrained.px),
      fontSize: FontSizeScale(base * (w / 360).clamp(1.0, 1.6), textScale),
      iconSize: 20.0 + (w / 1000).clamp(0, 4),
      radius: RadiusScale(16.0 + (w > 768 ? 4 : 0), w),
      spacing: base * spacingFactor,
      artworkSize: artworkSize,
      gridColumns: _gridColumns(type, landscape, w),
      cardAspectRatio: _cardAspectRatio(type, landscape, w),
    );
  }

  final bool isLandscape;
  final double width;
  final double height;
  final double textScaleFactor;
  final EdgeInsets padding;
  final FontSizeScale fontSize;
  final double iconSize;
  final RadiusScale radius;
  final double spacing;
  final double artworkSize;
  final int gridColumns;
  final double cardAspectRatio;

  double safe(double value) => value;

  double pad(double base) => base * (width / 360).clamp(0.9, 1.6);

  factory ResponsiveValues.minimal() => ResponsiveValues(
        isLandscape: false,
        width: 390,
        height: 844,
        textScaleFactor: 1.0,
        padding: const EdgeInsets.all(20),
        fontSize: FontSizeScale(16, 1),
        iconSize: 22,
        radius: RadiusScale(16, 390),
        spacing: 16,
        artworkSize: 140,
        gridColumns: 2,
        cardAspectRatio: 1.0,
      );
}

/// Small helper that clamps a value between min..max.
class ConstrainedSize {
  const ConstrainedSize(this.value, {required this.max, this.min = 0});
  final double value;
  final double min;
  final double max;
  double get px => value.clamp(min, max);
}

/// Font scale that also respects OS text scaling for accessibility.
class FontSizeScale {
  const FontSizeScale(this.base, this.textScale);
  final double base;
  final double textScale;

  double get body => (base * textScale).clamp(12, 32);
  double get label => (base * 0.85 * textScale).clamp(10, 26);
  double get title => (base * 1.2 * textScale).clamp(15, 40);
  double get headline => (base * 1.6 * textScale).clamp(20, 56);
}

class RadiusScale {
  const RadiusScale(this.base, this.width);
  final double base;
  final double width;
  double get px => (base + width * 0.004).clamp(8, 32);
}

DeviceType _classify(ScreenSize s) {
  if (s.shortestSide < 360) return DeviceType.phoneSmall;
  if (s.shortestSide < 600) return DeviceType.phone;
  if (s.width < 1024 && s.shortestSide < 1024) return DeviceType.tablet;
  if (s.width < 1440) return DeviceType.desktop;
  return DeviceType.largeDesktop;
}

int _gridColumns(DeviceType type, bool landscape, double w) {
  switch (type) {
    case DeviceType.phoneSmall:
      if (landscape) return w > 500 ? 3 : 2;
      return 1;
    case DeviceType.phone:
      return 2;
    case DeviceType.tablet:
      return 3;
    case DeviceType.desktop:
      return 4;
    case DeviceType.largeDesktop:
      return 5;
  }
}

double _cardAspectRatio(DeviceType type, bool landscape, double w) {
  switch (type) {
    case DeviceType.phoneSmall:
      return landscape ? 1.1 : 1.15;
    case DeviceType.phone:
      return 1.0;
    case DeviceType.tablet:
      return 1.0;
    case DeviceType.desktop:
      return landscape ? 1.15 : 1.1;
    case DeviceType.largeDesktop:
      return 1.2;
  }
}