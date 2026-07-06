import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:vertical_mobile/app/presentation/splash_screen.dart';
import 'package:vertical_mobile/app/router/app_routes.dart';
import 'package:vertical_mobile/app/router/main_shell_screen.dart';
import 'package:vertical_mobile/core/session/auth_session_notifier.dart';
import 'package:vertical_mobile/core/session/auth_session_status.dart';
import 'package:vertical_mobile/features/auth/presentation/auth_screen.dart';
import 'package:vertical_mobile/features/bookings/presentation/booking_details_screen.dart';
import 'package:vertical_mobile/features/bookings/presentation/bookings_screen.dart';
import 'package:vertical_mobile/features/profile/presentation/profile_screen.dart';
import 'package:vertical_mobile/features/slots/presentation/slots_screen.dart';
import 'package:vertical_mobile/core/api/models/slot_models.dart';
import 'package:vertical_mobile/features/bookings/presentation/slot_booking_screen.dart';
import 'package:vertical_mobile/features/slots/presentation/slot_details_screen.dart';

final _rootNavigatorKey = GlobalKey<NavigatorState>();

String? resolveAppRedirect({
  required AuthSessionStatus session,
  required String path,
}) {
  switch (session) {
    case AuthSessionStatus.unknown:
      return path == AppRoutes.splash ? null : AppRoutes.splash;
    case AuthSessionStatus.unauthenticated:
      return path == AppRoutes.auth ? null : AppRoutes.auth;
    case AuthSessionStatus.pendingProfile:
      return path == AppRoutes.auth ? null : AppRoutes.auth;
    case AuthSessionStatus.authenticated:
      if (path == AppRoutes.splash || path == AppRoutes.auth) {
        return AppRoutes.slots;
      }
      return null;
  }
}

final goRouterProvider = Provider<GoRouter>((ref) {
  final router = GoRouter(
    navigatorKey: _rootNavigatorKey,
    initialLocation: AppRoutes.splash,
    redirect: (context, state) {
      final session = ref.read(authSessionProvider);
      return resolveAppRedirect(session: session, path: state.uri.path);
    },
    routes: [
      GoRoute(
        path: AppRoutes.splash,
        builder: (context, state) => const SplashScreen(),
      ),
      GoRoute(
        path: AppRoutes.auth,
        builder: (context, state) => const AuthScreen(),
      ),
      StatefulShellRoute.indexedStack(
        builder: (context, state, navigationShell) {
          return MainShellScreen(navigationShell: navigationShell);
        },
        branches: [
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: AppRoutes.slots,
                builder: (context, state) => const SlotsScreen(),
                routes: [
                  GoRoute(
                    path: ':slotId',
                    parentNavigatorKey: _rootNavigatorKey,
                    builder: (context, state) => SlotDetailsScreen(
                      slotId: state.pathParameters['slotId']!,
                    ),
                    routes: [
                      GoRoute(
                        path: 'book',
                        parentNavigatorKey: _rootNavigatorKey,
                        builder: (context, state) => SlotBookingScreen(
                          slotId: state.pathParameters['slotId']!,
                          initialSlot: state.extra as SlotDto?,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: AppRoutes.bookings,
                builder: (context, state) => const BookingsScreen(),
                routes: [
                  GoRoute(
                    path: ':bookingId',
                    parentNavigatorKey: _rootNavigatorKey,
                    builder: (context, state) => BookingDetailsScreen(
                      bookingId: state.pathParameters['bookingId']!,
                    ),
                  ),
                ],
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: AppRoutes.profile,
                builder: (context, state) => const ProfileScreen(),
              ),
            ],
          ),
        ],
      ),
    ],
  );

  ref.listen<AuthSessionStatus>(authSessionProvider, (_, _) {
    router.refresh();
  });
  ref.onDispose(router.dispose);
  return router;
});
