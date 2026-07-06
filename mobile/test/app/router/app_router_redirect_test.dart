import 'package:flutter_test/flutter_test.dart';
import 'package:vertical_mobile/app/router/app_router.dart';
import 'package:vertical_mobile/app/router/app_routes.dart';
import 'package:vertical_mobile/core/session/auth_session_status.dart';

void main() {
  group('resolveAppRedirect', () {
    test('unknown session stays on splash', () {
      expect(
        resolveAppRedirect(
          session: AuthSessionStatus.unknown,
          path: AppRoutes.splash,
        ),
        isNull,
      );
    });

    test('unknown session redirects away from auth', () {
      expect(
        resolveAppRedirect(
          session: AuthSessionStatus.unknown,
          path: AppRoutes.auth,
        ),
        AppRoutes.splash,
      );
    });

    test('unauthenticated session opens auth', () {
      expect(
        resolveAppRedirect(
          session: AuthSessionStatus.unauthenticated,
          path: AppRoutes.slots,
        ),
        AppRoutes.auth,
      );
    });

    test('authenticated session opens slots from splash', () {
      expect(
        resolveAppRedirect(
          session: AuthSessionStatus.authenticated,
          path: AppRoutes.splash,
        ),
        AppRoutes.slots,
      );
    });

    test('authenticated session keeps shell routes', () {
      expect(
        resolveAppRedirect(
          session: AuthSessionStatus.authenticated,
          path: AppRoutes.profile,
        ),
        isNull,
      );
    });

    test('pendingProfile session stays on auth', () {
      expect(
        resolveAppRedirect(
          session: AuthSessionStatus.pendingProfile,
          path: AppRoutes.auth,
        ),
        isNull,
      );
      expect(
        resolveAppRedirect(
          session: AuthSessionStatus.pendingProfile,
          path: AppRoutes.slots,
        ),
        AppRoutes.auth,
      );
    });
  });
}
