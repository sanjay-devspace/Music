import 'dart:io';

import 'package:flutter/material.dart' hide SearchController;
import 'package:flutter/rendering.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:go_router/go_router.dart';

import 'package:tunehive/app/routes/app_routes.dart';
import 'package:tunehive/app/routes/route_names.dart';
import 'package:tunehive/app/theme/app_theme.dart';
import 'package:tunehive/controllers/home_controller.dart';
import 'package:tunehive/controllers/library_controller.dart';
import 'package:tunehive/controllers/player_controller.dart';
import 'package:tunehive/controllers/search_controller.dart';
import 'package:tunehive/controllers/shell_controller.dart';
import 'package:tunehive/services/music/music_service.dart';
import 'package:tunehive/services/player/player_service.dart';

void main() {
  setUpAll(() {
    Get.reset();
    final musicService = MusicService();
    final playerService = PlayerService(musicService: musicService);
    Get.put<MusicService>(musicService, permanent: true);
    Get.put<PlayerService>(playerService, permanent: true);
    Get.put<ShellController>(ShellController(), permanent: true);
    Get.put<PlayerController>(PlayerController(playerService), permanent: true);
    Get.put<HomeController>(HomeController(musicService), permanent: true);
    Get.put<SearchController>(SearchController(musicService), permanent: true);
    Get.put<LibraryController>(LibraryController(musicService), permanent: true);
  });

  testWidgets('capture file 320', (tester) async {
    tester.view.physicalSize = const Size(320, 568);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.reset);

    final router = GoRouter(
      initialLocation: RoutePaths.home,
      routes: appRoutes,
    );

    // ignore: flutter_lints
    final original = FlutterError.onError;
    FlutterError.onError = (details) {
      final file = File('${Directory.systemTemp.path}/opencode/cap320.txt');
      final sb = StringBuffer()
        ..writeln('=== CAPTURED_ERROR_START ===')
        ..writeln(details.exception)
        ..writeln('=== CAPTURED_ERROR_END ===');
      for (final d in details.diagnostics) {
        sb.writeln('DIAG: $d');
      }
      file.writeAsStringSync(sb.toString());
      original?.call(details);
    };
    addTearDown(() => FlutterError.onError = original);

    await tester.pumpWidget(
      MaterialApp.router(theme: AppTheme.dark, routerConfig: router),
    );
    await tester.pump(const Duration(seconds: 1));
    for (var i = 0; i < 5; i++) {
      await tester.pump(const Duration(milliseconds: 100));
    }

    final e = tester.takeException();
    if (e is FlutterError) {
      File('${Directory.systemTemp.path}/opencode/cap320_exc.txt')
          .writeAsStringSync('JUST_EXC: $e');
    }

    final tree = StringBuffer();
    debugDumpRenderTree(externalDebugPrint: (line, _) => tree.writeln(line));
    File('${Directory.systemTemp.path}/opencode/cap320_tree.txt')
        .writeAsStringSync(tree.toString());
  });
}
