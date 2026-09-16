import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:go_router/go_router.dart';

import 'package:tunehive/app/routes/app_routes.dart';
import 'package:tunehive/app/routes/route_names.dart';
import 'package:tunehive/app/theme/app_theme.dart';

void main() {
  testWidgets('capture', (tester) async {
    tester.view.physicalSize = const Size(320, 568);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.reset);

    final original = FlutterError.onError;
    FlutterError.onError = (details) {
      debugPrint('CAPTURED_ERROR:\n${details.toString()}');
      debugPrint('====================');
      original?.call(details);
    };
    addTearDown(() => FlutterError.onError = original);

    await tester.pumpWidget(
      MaterialApp.router(
        theme: AppTheme.dark,
        routerConfig: GoRouter(
          initialLocation: RoutePaths.home,
          routes: appRoutes,
        ),
      ),
    );
    for (var i = 0; i < 12; i++) {
      await tester.pump(const Duration(milliseconds: 100));
    }
    await tester.pump();
  });
}
