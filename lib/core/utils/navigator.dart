import 'package:flutter/material.dart';

/// Utility to access the current app navigator.
abstract class AppNavigator {
  static GlobalKey<NavigatorState> key = GlobalKey<NavigatorState>();
}