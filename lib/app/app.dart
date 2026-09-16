import 'package:flutter/material.dart';
import 'package:tunehive/app/routes/app_routes.dart';
import 'package:tunehive/app/theme/app_theme.dart';

class TuneHiveApp extends StatelessWidget {
  const TuneHiveApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: 'TuneHive',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.dark,
      routerConfig: appRouter,
    );
  }
}
