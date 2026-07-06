import 'package:vertical_mobile/core/api/models/booking_models.dart';

/// Лейблы статусов брони (SCR-005, SCR-006).
abstract final class BookingStatusLabels {
  static const active = 'Активна';
  static const cancelled = 'Отменена';
  static const lateCancel = 'Поздняя отмена';
  static const clubCancelled = 'Отменена скалодромом';
  static const past = 'Прошедшая';

  static String forBooking({
    required BookingStatus status,
    required DateTime? slotStartAt,
    required DateTime now,
  }) {
    if (status == BookingStatus.active &&
        slotStartAt != null &&
        !slotStartAt.isAfter(now)) {
      return past;
    }

    return switch (status) {
      BookingStatus.active => active,
      BookingStatus.cancelled => cancelled,
      BookingStatus.lateCancel => lateCancel,
      BookingStatus.clubCancelled => clubCancelled,
    };
  }
}
