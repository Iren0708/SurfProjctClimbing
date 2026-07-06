import 'package:vertical_mobile/core/api/models/booking_models.dart';

import 'slot_test_data.dart';

BookingSummaryDto testBookingSummary({
  String id = 'bbbbbbbb-bbbb-bbbb-bbbb-bbbbbbbbbbbb',
  String slotId = '11111111-1111-1111-1111-111111111111',
  Equipment equipment = Equipment.own,
  BookingStatus status = BookingStatus.active,
  int priceTotal = 1200,
  DateTime? createdAt,
  DateTime? slotStartAt,
}) {
  return BookingSummaryDto(
    id: id,
    slotId: slotId,
    equipment: equipment,
    status: status,
    priceTotal: priceTotal,
    createdAt: createdAt ?? DateTime.utc(2026, 7, 10, 9),
    slot: testSlot(id: slotId, startAt: slotStartAt ?? DateTime.utc(2026, 7, 10, 10)),
  );
}

BookingDto testBooking({
  String id = 'bbbbbbbb-bbbb-bbbb-bbbb-bbbbbbbbbbbb',
  String slotId = '11111111-1111-1111-1111-111111111111',
  Equipment equipment = Equipment.own,
  BookingStatus status = BookingStatus.active,
  int priceTotal = 1200,
  DateTime? createdAt,
  DateTime? slotStartAt,
}) {
  return BookingDto(
    id: id,
    slotId: slotId,
    clientId: 'cccccccc-cccc-cccc-cccc-cccccccccccc',
    equipment: equipment,
    status: status,
    priceTotal: priceTotal,
    createdAt: createdAt ?? DateTime.utc(2026, 7, 10, 9),
    slot: testSlot(id: slotId, startAt: slotStartAt ?? DateTime.utc(2026, 7, 10, 10)),
  );
}
