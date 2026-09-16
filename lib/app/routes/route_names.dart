/// Central route names so views never hardcode path strings.
abstract class RouteNames {
  static const String splash = '/splash';
  static const String onboarding = '/onboarding';
  static const String login = '/login';
  static const String register = '/register';
  static const String home = '/home';
  static const String search = '/search';
  static const String library = '/library';
  static const String player = '/player';
  static const String song = '/song';
  static const String album = '/album';
  static const String artist = '/artist';
  static const String playlist = '/playlist';
  static const String playlistNew = '/playlist/new';
  static const String profile = '/profile';
  static const String settings = '/settings';
  static const String queue = '/queue';
}

/// Central path strings (using GoRouter URL syntax).
abstract class RoutePaths {
  static const String splash = '/splash';
  static const String onboarding = '/onboarding';
  static const String login = '/login';
  static const String register = '/register';
  static const String home = '/home';
  static const String search = '/search';
  static const String library = '/library';
  static const String player = '/player';
  static const String song = '/song/:id';
  static const String album = '/album/:id';
  static const String artist = '/artist/:id';
  static const String playlist = '/playlist/:id';
  static const String playlistNew = '/playlist/new';
  static const String profile = '/profile';
  static const String settings = '/settings';
  static const String queue = '/queue';

  static String songWith(String id) => song.replaceFirst(':id', id);
  static String albumWith(String id) => album.replaceFirst(':id', id);
  static String artistWith(String id) => artist.replaceFirst(':id', id);
  static String playlistWith(String id) => playlist.replaceFirst(':id', id);
}