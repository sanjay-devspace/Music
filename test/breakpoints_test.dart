import 'package:flutter/material.dart' hide SearchController;
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
import 'package:tunehive/views/library/library_view.dart';
import 'package:tunehive/views/profile/profile_view.dart';
import 'package:tunehive/views/search/search_view.dart';

/// Renders screens at the required design breakpoints and asserts they paint
/// without exceptions (layout overflows surface as FlutterErrors here).
void main() {
  const breakpoints = <(String, Size)>[
    ('320x568 portrait', Size(320, 568)),
    ('375x667 portrait', Size(375, 667)),
    ('390x844 portrait', Size(390, 844)),
    ('412x915 portrait', Size(412, 915)),
    ('600x960', Size(600, 960)),
    ('768x1024 portrait', Size(768, 1024)),
    ('1024x768 landscape', Size(1024, 768)),
    ('1280x800 desktop', Size(1280, 800)),
    ('1440x900 desktop', Size(1440, 900)),
    ('1920x1080 desktop', Size(1920, 1080)),
  ];

  late MusicService musicService;

  setUpAll(() {
    Get.reset();
    musicService = MusicService();
    final playerService = PlayerService(musicService: musicService);

    Get.put<MusicService>(musicService, permanent: true);
    Get.put<PlayerService>(playerService, permanent: true);
    Get.put<ShellController>(ShellController(), permanent: true);
    Get.put<PlayerController>(PlayerController(playerService), permanent: true);
    Get.put<HomeController>(HomeController(musicService), permanent: true);
    Get.put<SearchController>(SearchController(musicService), permanent: true);
    Get.put<LibraryController>(LibraryController(musicService), permanent: true);
  });

  Future<void> size(WidgetTester tester, Size logical) async {
    tester.view.physicalSize = logical;
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.reset);
  }

  Future<void> settle(WidgetTester tester) async {
    for (var i = 0; i < 12; i++) {
      await tester.pump(const Duration(milliseconds: 100));
    }
  }

  group('Home + shell at each breakpoint', () {
    for (final (label, rs) in breakpoints) {
      testWidgets('renders without overflow @ $label', (tester) async {
        await size(tester, rs);

        final router = GoRouter(
          initialLocation: RoutePaths.home,
          routes: appRoutes,
        );

        final originalOnError = FlutterError.onError;
        FlutterError.onError = (details) {
          // ignore: avoid_print
          print('CAPTURED:\n$details');
          originalOnError?.call(details);
        };
        addTearDown(() {
          FlutterError.onError = originalOnError;
        });

        await tester.pumpWidget(
          MaterialApp.router(
            theme: AppTheme.dark,
            routerConfig: router,
          ),
        );
        await settle(tester);

        final e = tester.takeException();
        expect(e, isNull, reason: 'Home/shell overflowed at $label');
      });
    }
  });

  group('Search / Library / Profile rendering', () {
    for (final view
        in <Widget Function()>[SearchView.new, LibraryView.new, ProfileView.new]) {
      for (final (label, rs) in const <(String, Size)>[
        ('phone 390x844', Size(390, 844)),
        ('landscape 1024x768', Size(1024, 768)),
        ('desktop 1280x800', Size(1280, 800)),
      ]) {
        testWidgets('$view @ $label renders cleanly', (tester) async {
          await size(tester, rs);
final originalOnError = FlutterError.onError;
        FlutterError.onError = (details) {
          // ignore: avoid_print
          print('CAPTURED_ERROR $details');
          originalOnError?.call(details);
        };
        addTearDown(() => FlutterError.onError = originalOnError);

        await tester.pumpWidget(
            MaterialApp(theme: AppTheme.dark, home: view()),
          );
          await settle(tester);
          expect(tester.takeException(), isNull, reason: '$label overflowed');
        });
      }
    }
  });
}