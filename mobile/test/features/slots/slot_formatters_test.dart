import 'package:flutter_test/flutter_test.dart';
import 'package:vertical_mobile/features/slots/domain/slot_formatters.dart';

import '../../support/slot_test_data.dart';

void main() {
  group('SlotFormatters', () {
    test('formats time in local timezone', () {
      final slot = testSlot(startAt: DateTime.utc(2026, 7, 10, 15, 30));
      expect(SlotFormatters.formatTime(slot.startAt), isNotEmpty);
    });

    test('shows no seats label when free_seats is zero', () {
      final slot = testSlot(freeSeats: 0);
      expect(SlotFormatters.seatsLabel(slot), 'Мест нет');
    });

    test('shows seats count when available', () {
      final slot = testSlot(freeSeats: 3, totalSeats: 8);
      expect(SlotFormatters.seatsLabel(slot), '3 из 8');
    });

    test('formats today header', () {
      final now = DateTime(2026, 7, 10, 12);
      final day = DateTime(2026, 7, 10);
      expect(
        SlotFormatters.formatDayHeader(day, now: now),
        contains('Сегодня'),
      );
    });

    test('formats date time header with weekday', () {
      final startAt = DateTime(2026, 7, 8, 15); // Wednesday local
      expect(
        SlotFormatters.formatDateTimeHeader(startAt),
        contains('·'),
      );
    });

    test('formats seats detail label', () {
      final slot = testSlot(freeSeats: 3, totalSeats: 8);
      expect(
        SlotFormatters.seatsDetailLabel(slot),
        'Места: 3 из 8 свободно',
      );
    });

    test('formats rental label with plural forms', () {
      expect(SlotFormatters.rentalLabel(1), 'Прокат: 1 комплект свободно');
      expect(SlotFormatters.rentalLabel(2), 'Прокат: 2 комплекта свободно');
      expect(SlotFormatters.rentalLabel(5), 'Прокат: 5 комплектов свободно');
    });
  });
}
