import 'package:vertical_mobile/core/api/models/instructor_models.dart';
import 'package:vertical_mobile/core/api/models/slot_models.dart';

SlotDto testSlot({
  String id = '11111111-1111-1111-1111-111111111111',
  int freeSeats = 5,
  int totalSeats = 8,
  int freeRentalEquipment = 3,
  SlotStatus status = SlotStatus.scheduled,
  int price = 1200,
  int rentalPrice = 400,
  DateTime? startAt,
}) {
  return SlotDto(
    id: id,
    startAt: startAt ?? DateTime.utc(2026, 7, 10, 10),
    zoneFormat: const ZoneFormatDto(
      id: '22222222-2222-2222-2222-222222222222',
      name: 'Новичковый',
      type: ZoneFormatType.novice,
      capacityCap: 8,
      durationMin: 90,
    ),
    instructorInfo: const InstructorDto(
      id: '33333333-3333-3333-3333-333333333333',
      name: 'Анна',
    ),
    totalSeats: totalSeats,
    freeSeats: freeSeats,
    freeRentalEquipment: freeRentalEquipment,
    price: price,
    rentalPrice: rentalPrice,
    status: status,
  );
}
