import 'package:flutter/material.dart' hide SearchController;
import 'package:get/get.dart';

import 'app/app.dart';
import 'controllers/home_controller.dart';
import 'controllers/library_controller.dart';
import 'controllers/player_controller.dart';
import 'controllers/search_controller.dart';
import 'controllers/shell_controller.dart';
import 'services/music/music_service.dart';
import 'services/player/player_service.dart';
import 'services/auth/auth_service.dart';
import 'core/storage/storage_service.dart';
import 'controllers/auth_controller.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // ---- Service layer -------------------------------------------------------
  final musicService = MusicService();
  final playerService = PlayerService(musicService: musicService);

  // ---- Register everything via GetX before the widget tree is built. --------
  Get.put<MusicService>(musicService, permanent: true);
  Get.put<PlayerService>(playerService, permanent: true);
  Get.put<ShellController>(ShellController(), permanent: true);
  Get.put<PlayerController>(PlayerController(playerService), permanent: true);
  Get.put<HomeController>(HomeController(musicService), permanent: true);
  Get.put<SearchController>(SearchController(musicService), permanent: true);
  Get.put<LibraryController>(LibraryController(musicService), permanent: true);

  final storageService = StorageService.noop();
  final authService = AuthService(storageService);
  Get.put<AuthService>(authService, permanent: true);
  Get.put<AuthController>(AuthController(authService), permanent: true);

  runApp(const TuneHiveApp());
}