import 'package:flutter/material.dart';
import 'dart:ui';
/// Captures the current available screen metrics at build time.
///
/// Created once per layout pass inside `ResponsiveLayoutBuilder` and passed
/// down so views can make decisions without touching MediaQuery directly.
class ScreenSize {
  const ScreenSize({
    required this.width,
    required this.height,
    required this.shortestSide,
    required this.dpr,
    required this.pixelRatio,
    required this.textScaleFactor,
    required this.isLandscape,
    required this.viewPadding,
    required this.padding,
  });

  final double width;
  final double height;
  final double shortestSide;
  final double dpr;
  final double pixelRatio;
  final double textScaleFactor;
  final bool isLandscape;
  final EdgeInsets viewPadding;
  final EdgeInsets padding;

  double get aspectRatio => height == 0 ? 1 : width / height;

  bool get isPortrait => !isLandscape;

  double get safeTop => viewPadding.top;
  double get safeBottom => viewPadding.bottom;
  double get safeLeft => viewPadding.left;
  double get safeRight => viewPadding.right;

  ScreenSize copyWith({
    double? width,
    double? height,
    double? shortestSide,
    double? dpr,
    double? pixelRatio,
    double? textScaleFactor,
    bool? isLandscape,
    EdgeInsets? viewPadding,
    EdgeInsets? padding,
  }) {
    return ScreenSize(
      width: width ?? this.width,
      height: height ?? this.height,
      shortestSide: shortestSide ?? this.shortestSide,
      dpr: dpr ?? this.dpr,
      pixelRatio: pixelRatio ?? this.pixelRatio,
      textScaleFactor: textScaleFactor ?? this.textScaleFactor,
      isLandscape: isLandscape ?? this.isLandscape,
      viewPadding: viewPadding ?? this.viewPadding,
      padding: padding ?? this.padding,
    );
  }
}