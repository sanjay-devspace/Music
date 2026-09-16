import 'package:flutter/material.dart';
import 'package:tunehive/app/app.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  // Here we would initialize our services (like Supabase, Audio, etc)
  runApp(const TuneHiveApp());
}
