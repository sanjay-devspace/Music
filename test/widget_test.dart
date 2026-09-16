import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tunehive/app/theme/app_colors.dart';
import 'package:tunehive/app/theme/app_theme.dart';
import 'package:tunehive/widgets/app_button.dart';

void main() {
  test('TuneHive color system uses the deep navy + coral identity', () {
    expect(AppColors.background, const Color(0xFF15262D));
    expect(AppColors.primary, const Color(0xFFFF5B63));
    expect(AppColors.playerSurface, const Color(0xFFF6F7F5));
    expect(AppColors.playerControls, const Color(0xFF050708));
  });

  testWidgets('AppButton renders with the coral primary theme',
      (WidgetTester tester) async {
    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.dark,
        home: Scaffold(
          body: AppButton(label: 'Play', onPressed: () {}),
        ),
      ),
    );

    expect(find.text('Play'), findsOneWidget);
  });
}