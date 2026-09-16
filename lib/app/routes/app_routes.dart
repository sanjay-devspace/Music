import 'package:go_router/go_router.dart';
import 'package:tunehive/app/routes/route_names.dart';
import 'package:tunehive/views/onboarding/onboarding_view.dart';
import 'package:tunehive/views/home/home_view.dart';

final GoRouter appRouter = GoRouter(
  initialLocation: RoutePaths.onboarding,
  routes: [
    GoRoute(
      path: RoutePaths.onboarding,
      name: RouteNames.onboarding,
      builder: (context, state) => const OnboardingView(),
    ),
    GoRoute(
      path: RoutePaths.home,
      name: RouteNames.home,
      builder: (context, state) => const HomeView(),
    ),
  ],
);
