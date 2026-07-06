import 'package:vertical_mobile/core/api/models/booking_models.dart';

enum CancelPreviewType {
  early,
  late,
}

/// Правило отмены за 2 часа (LOGIC-004). Источник истины — сервер.
class CancellationPolicy {
  const CancellationPolicy._();

  static const cancelLeadTime = Duration(hours: 2);

  /// `true` при ≥ 2 ч до старта (включая ровно 2 ч).
  static bool isEarlyCancel(DateTime now, DateTime slotStartAt) {
    final deadline = slotStartAt.subtract(cancelLeadTime);
    return !now.isAfter(deadline);
  }

  static CancelPreviewType previewType(DateTime now, DateTime slotStartAt) {
    return isEarlyCancel(now, slotStartAt)
        ? CancelPreviewType.early
        : CancelPreviewType.late;
  }

  static DateTime earlyCancelDeadline(DateTime slotStartAt) {
    return slotStartAt.subtract(cancelLeadTime);
  }

  static bool canClientCancel({
    required BookingStatus status,
    required DateTime slotStartAt,
    required DateTime now,
  }) {
    if (status != BookingStatus.active) {
      return false;
    }
    return slotStartAt.isAfter(now);
  }
}
