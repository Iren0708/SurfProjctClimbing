import 'package:flutter_test/flutter_test.dart';
import 'package:vertical_mobile/core/api/models/booking_models.dart';
import 'package:vertical_mobile/core/domain/policies/cancellation_policy.dart';

void main() {
  group('CancellationPolicy', () {
    final now = DateTime.utc(2026, 7, 6, 10);

    test('exactly 2 hours before start is early cancel', () {
      final startAt = now.add(const Duration(hours: 2));

      expect(CancellationPolicy.isEarlyCancel(now, startAt), isTrue);
      expect(
        CancellationPolicy.previewType(now, startAt),
        CancelPreviewType.early,
      );
    });

    test('one second before 2 hour boundary is late cancel', () {
      final startAt =
          now.add(const Duration(hours: 2)).subtract(const Duration(seconds: 1));

      expect(CancellationPolicy.isEarlyCancel(now, startAt), isFalse);
      expect(
        CancellationPolicy.previewType(now, startAt),
        CancelPreviewType.late,
      );
    });

    test('more than 2 hours before start is early cancel', () {
      final startAt = now.add(const Duration(hours: 3));

      expect(CancellationPolicy.isEarlyCancel(now, startAt), isTrue);
    });

    test('canClientCancel only for active future bookings', () {
      expect(
        CancellationPolicy.canClientCancel(
          status: BookingStatus.active,
          slotStartAt: now.add(const Duration(hours: 1)),
          now: now,
        ),
        isTrue,
      );

      expect(
        CancellationPolicy.canClientCancel(
          status: BookingStatus.clubCancelled,
          slotStartAt: now.add(const Duration(hours: 1)),
          now: now,
        ),
        isFalse,
      );

      expect(
        CancellationPolicy.canClientCancel(
          status: BookingStatus.active,
          slotStartAt: now.subtract(const Duration(minutes: 1)),
          now: now,
        ),
        isFalse,
      );
    });

    test('earlyCancelDeadline is start minus 2 hours', () {
      final startAt = DateTime.utc(2026, 7, 6, 14);
      expect(
        CancellationPolicy.earlyCancelDeadline(startAt),
        DateTime.utc(2026, 7, 6, 12),
      );
    });
  });
}
