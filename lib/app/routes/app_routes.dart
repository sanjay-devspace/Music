import 'package:go_router/go_router.dart';

import 'route_names.dart';
import 'package:tunehive/views/splash/splash_view.dart';
import 'package:tunehive/views/onboarding/onboarding_view.dart';
import 'package:tunehive/views/shell/app_shell_view.dart';
import 'package:tunehive/views/player/player_view.dart';
import 'package:tunehive/views/home/home_view.dart';
import 'package:tunehive/views/auth/login_view.dart';
import 'package:tunehive/views/auth/register_view.dart';
import 'package:tunehive/views/search/search_view.dart';
import 'package:tunehive/views/library/library_view.dart';
import 'package:tunehive/views/profile/profile_view.dart';
import 'package:tunehive/views/song/song_detail_view.dart';
import 'package:tunehive/views/album/album_detail_view.dart';
import 'package:tunehive/views/artist/artist_detail_view.dart';
import 'package:tunehive/views/playlist/playlist_detail_view.dart';
import 'package:tunehive/views/queue/queue_view.dart';
import 'package:tunehive/views/library/liked_songs_view.dart';
import 'package:tunehive/views/library/playlists_view.dart';
import 'package:tunehive/views/library/recently_played_view.dart';
import 'package:tunehive/views/profile/settings_view.dart';
import 'package:tunehive/views/profile/connected_providers_view.dart';
import 'package:tunehive/views/notifications/notification_center_view.dart';
import 'package:tunehive/views/search/search_results_view.dart';

final List<RouteBase> appRoutes = [
    GoRoute(
      path: RoutePaths.splash,
      name: RouteNames.splash,
      builder: (context, state) => const SplashView(),
    ),
    GoRoute(
      path: RoutePaths.onboarding,
      name: RouteNames.onboarding,
      builder: (context, state) => const OnboardingView(),
    ),
    GoRoute(
      path: RoutePaths.login,
      name: RouteNames.login,
      builder: (context, state) => const LoginView(),
    ),
    GoRoute(
      path: RoutePaths.register,
      name: RouteNames.register,
      builder: (context, state) => const RegisterView(),
    ),
    StatefulShellRoute.indexedStack(
      builder: (context, state, navigationShell) => AppShellView(
        navigationShell: navigationShell,
      ),
      branches: [
        StatefulShellBranch(routes: [
          GoRoute(
            path: RoutePaths.home,
            name: RouteNames.home,
            builder: (context, state) => const HomeView(),
          ),
        ]),
        StatefulShellBranch(routes: [
          GoRoute(
            path: RoutePaths.search,
            name: RouteNames.search,
            builder: (context, state) => const SearchView(),
          ),
        ]),
        StatefulShellBranch(routes: [
          GoRoute(
            path: RoutePaths.library,
            name: RouteNames.library,
            builder: (context, state) => const LibraryView(),
          ),
        ]),
        StatefulShellBranch(routes: [
          GoRoute(
            path: RoutePaths.profile,
            name: RouteNames.profile,
            builder: (context, state) => const ProfileView(),
          ),
        ]),
      ],
    ),
    GoRoute(
      path: RoutePaths.player,
      name: RouteNames.player,
      builder: (context, state) => const PlayerView(),
    ),
    GoRoute(
      path: RoutePaths.queue,
      name: RouteNames.queue,
      builder: (context, state) => const QueueView(),
    ),
    GoRoute(
      path: RoutePaths.song,
      name: RouteNames.song,
      builder: (context, state) => SongDetailView(id: state.pathParameters['id']!),
    ),
    GoRoute(
      path: RoutePaths.album,
      name: RouteNames.album,
      builder: (context, state) => AlbumDetailView(id: state.pathParameters['id']!),
    ),
    GoRoute(
      path: RoutePaths.artist,
      name: RouteNames.artist,
      builder: (context, state) => ArtistDetailView(id: state.pathParameters['id']!),
    ),
    GoRoute(
      path: RoutePaths.playlist,
      name: RouteNames.playlist,
      builder: (context, state) => PlaylistDetailView(id: state.pathParameters['id']!),
    ),
    GoRoute(
      path: RoutePaths.settings,
      name: RouteNames.settings,
      builder: (context, state) => const SettingsView(),
    ),
    GoRoute(
      path: RoutePaths.connectedProviders,
      name: RouteNames.connectedProviders,
      builder: (context, state) => const ConnectedProvidersView(),
    ),
    GoRoute(
      path: RoutePaths.notificationCenter,
      name: RouteNames.notificationCenter,
      builder: (context, state) => const NotificationCenterView(),
    ),
    GoRoute(
      path: RoutePaths.searchResults,
      name: RouteNames.searchResults,
      builder: (context, state) => SearchResultsView(query: state.uri.queryParameters['q'] ?? ''),
    ),
    GoRoute(
      path: RoutePaths.likedSongs,
      name: RouteNames.likedSongs,
      builder: (context, state) => const LikedSongsView(),
    ),
    GoRoute(
      path: RoutePaths.playlists,
      name: RouteNames.playlists,
      builder: (context, state) => const PlaylistsView(),
    ),
    GoRoute(
      path: RoutePaths.recentlyPlayed,
      name: RouteNames.recentlyPlayed,
      builder: (context, state) => const RecentlyPlayedView(),
    ),
  ];

final GoRouter appRouter = GoRouter(
  initialLocation: RoutePaths.onboarding,
  routes: appRoutes,
);
