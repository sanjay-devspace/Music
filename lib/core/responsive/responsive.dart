import 'package:flutter/widgets.dart';
import 'device_type.dart';
import 'responsive_breakpoints.dart';
import 'responsive_values.dart';
import 'screen_size.dart';

/// High-level responsive facade used across the app.
///
/// Views build an instance from the nearest [ResponsiveLayout] context so
/// that MediaQuery calls are centralized here.
class Responsive {
  Responsive._(this.screen, this.device, this.values);

  final ScreenSize screen;
  final DeviceType device;
  final ResponsiveValues values;

  // ---- Device helpers --------------------------------------------------
  bool get isMobile => device.isMobile;
  bool get isPhone => device.isPhone;
  bool get isPhoneSmall => device == DeviceType.phoneSmall;
  bool get isTablet => device.isTablet;
  bool get isDesktop => device.isDesktop;
  bool get isLargeDesktop => device == DeviceType.largeDesktop;
  bool get isLandscape => screen.isLandscape;
  bool get isPortrait => screen.isPortrait;

  // ---- Direct value access ---------------------------------------------
  double get width => screen.width;
  double get height => screen.height;
  double get shortestSide => screen.shortestSide;
  double get safeTopPadding => screen.safeTop;
  double get safeBottomPadding => screen.safeBottom;

  EdgeInsets get padding => values.padding;
  double get spacing => values.spacing;
  double get iconSize => values.iconSize;
  double get artworkSize => values.artworkSize;
  int get gridColumns => values.gridColumns;
  double get cardAspectRatio => values.cardAspectRatio;

  /// Comfortable content width for centered desktop layouts. On phones and
  /// tablets it degrades to the full available width.
  double get maxContentWidth {
    if (isPhone) return width;
    return device == DeviceType.largeDesktop ? 1440 : 1240;
  }

  /// Padding used around the main (non-sidebar) content area.
  EdgeInsets get contentPadding {
    if (isMobile) return padding;
    return EdgeInsets.symmetric(
      horizontal: (width - maxContentWidth) / 2,
      vertical: padding.top,
    );
  }

  FontSizeScale get fontSize => values.fontSize;
  RadiusScale get radius => values.radius;

  // ---- Statically resolved from context ---------------------------------
  static Responsive of(BuildContext context, {Size? overrideSize}) {
    final query = MediaQuery.sizeOf(context);
    final size = overrideSize ?? query;
    final screen = ScreenSize(
      width: size.width,
      height: size.height,
      shortestSide: size.shortestSide,
      dpr: MediaQuery.devicePixelRatioOf(context),
      pixelRatio: MediaQuery.devicePixelRatioOf(context),
      textScaleFactor: MediaQuery.textScalerOf(context).scale(1),
      isLandscape:
          MediaQuery.orientationOf(context) == Orientation.landscape,
      viewPadding: MediaQuery.viewPaddingOf(context),
      padding: MediaQuery.paddingOf(context),
    );
    final device = ResponsiveBreakpoints.fromOriented(size);
    return Responsive._(
      screen,
      device,
      ResponsiveValues.fromScreenSize(screen, deviceType: device),
    );
  }

  /// Convenience width function — resolves `.of(context).width`.
  static double widthOf(BuildContext context) => of(context).width;

  static double heightOf(BuildContext context) => of(context).height;
}