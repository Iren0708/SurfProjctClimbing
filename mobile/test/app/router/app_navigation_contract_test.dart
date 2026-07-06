import 'package:flutter_test/flutter_test.dart';
import 'package:vertical_mobile/app/router/app_routes.dart';
import 'package:vertical_mobile/app/router/app_shell_branch.dart';

/// Сверка маршрутов с feature-list.md §3 (MOB-18).
void main() {
  group('Navigation contract (feature-list §3)', () {
    test('shell tab bar labels match ТЗ', () {
      expect(AppShellBranch.tabLabels, [
        'Тренировки',
        'Мои записи',
        'Профиль',
      ]);
      expect(AppShellBranch.slots, 0);
      expect(AppShellBranch.bookings, 1);
      expect(AppShellBranch.profile, 2);
    });

    test('shell routes cover SCR-002, SCR-005, SCR-007', () {
      expect(AppRoutes.slots, '/slots');
      expect(AppRoutes.bookings, '/bookings');
      expect(AppRoutes.profile, '/profile');
    });

    test('nested routes cover SCR-003, SCR-004, SCR-006', () {
      const slotId = '11111111-1111-1111-1111-111111111111';
      const bookingId = 'bbbbbbbb-bbbb-bbbb-bbbb-bbbbbbbbbbbb';

      expect(AppRoutes.slotDetailsPath(slotId), '/slots/$slotId');
      expect(AppRoutes.slotBookingPath(slotId), '/slots/$slotId/book');
      expect(AppRoutes.bookingDetailsPath(bookingId), '/bookings/$bookingId');
    });

    test('auth zone routes cover SCR-001 entry', () {
      expect(AppRoutes.splash, '/splash');
      expect(AppRoutes.auth, '/auth');
    });
  });
}
