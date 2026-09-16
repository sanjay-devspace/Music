import 'dart:io';

import 'package:flutter/rendering.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:tunehive/app/routes/app_routes.dart';
import 'package:tunehive/app/theme/app_theme.dart';

void main() {
  final dir = Directory(
      '${Directory.systemTemp.path}${Platform.pathSeparator}opencode')
    ..createSync(recursive: trueinate: true);
  final out = File(
      '${dir.path}${Platform.pathSeparator}diagdump.txt');
  final buf = StringBuffer();

  testWidgets('diag', (tester) async {
    tester.view.physicalSize = const Size(320, 568);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.reset);

    final original = FlutterError.onError;
    FlutterError.onError = (details) {
      buf.writeln('=== ERROR_START ===');
      buf.writeln(details.toString());
      buf.writeln('=== ERROR_END ===');
      original?.call(details);
    };
    addTearDown(() => FlutterError.onError = original);

    final router = GoRouter(
      initialLocation: RoutePaths.home,
      routes: appRoutes,
    );
    await tester.pumpWidget(
      MaterialApp.router(theme: AppTheme.dark, routerConfig: router),
    );
    await tester.pump(const Duration(seconds: 1));
    for (var i = 0; i < 10; i++) {
      await tester.pump(const Duration(milliseconds: 100));
    }

    try {
      final eObj = tester.takeException();
      if (eObj is FlutterError) {
        buf.writeln('=== CAPTURE_START ===');
        buf.writeln(eObj.toString());
        buf.writeln('=== CAPTURE_END ===');
      }
    } catch (_) {}

    out.writeAsStringSync(buf.toString());
  });
}