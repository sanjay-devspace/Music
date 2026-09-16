import 'package:flutter/material.dart';
import 'package:tunehive/core/responsive/responsive.dart';
import 'package:tunehive/core/responsive/responsive_values.dart';

class OnboardingResponsive {
  final BuildContext context;

  OnboardingResponsive(this.context);

  EdgeInsets get padding {
    if (Responsive.of(context).isDesktop) {
      return const EdgeInsets.symmetric(horizontal: 120, vertical: 48);
    } else if (Responsive.of(context).isTablet) {
      return const EdgeInsets.symmetric(horizontal: 64, vertical: 32);
    } else {
      return const EdgeInsets.symmetric(horizontal: 24, vertical: 24);
    }
  }

  double get artworkSize {
    if (Responsive.of(context).isDesktop) {
      return 300.0;
    } else if (Responsive.of(context).isTablet) {
      return 250.0;
    } else {
      return 200.0;
    }
  }

  double get glowHeight {
    if (Responsive.of(context).isDesktop) {
      return 600.0;
    } else {
      return 400.0;
    }
  }

  TextStyle get headlineStyle {
    final baseStyle = Theme.of(context).textTheme.displaySmall?.copyWith(
      fontWeight: FontWeight.bold,
      color: Colors.white,
      height: 1.1,
    );
    
    if (Responsive.of(context).isDesktop) {
      return baseStyle!.copyWith(fontSize: 64);
    } else if (Responsive.of(context).isTablet) {
      return baseStyle!.copyWith(fontSize: 48);
    } else {
      return baseStyle!.copyWith(fontSize: 40);
    }
  }

  FontSizeScale get fontSize => Responsive.of(context).fontSize;
}
