import 'package:vertical_mobile/core/api/models/instructor_models.dart';
import 'package:vertical_mobile/core/api/models/slot_models.dart';
import 'package:vertical_mobile/features/slots/domain/slot_list_messages.dart';

abstract final class SlotFormatters {
  static const _weekdayNames = [
    'Пн',
    'Вт',
    'Ср',
    'Чт',
    'Пт',
    'Сб',
    'Вс',
  ];

  static const _monthNames = [
    'января',
    'февраля',
    'марта',
    'апреля',
    'мая',
    'июня',
    'июля',
    'августа',
    'сентября',
    'октября',
    'ноября',
    'декабря',
  ];

  static String formatTime(DateTime startAt) {
    final local = startAt.toLocal();
    final hours = local.hour.toString().padLeft(2, '0');
    final minutes = local.minute.toString().padLeft(2, '0');
    return '$hours:$minutes';
  }

  static String formatShortDate(DateTime date) {
    final local = date.toLocal();
    return '${local.day} ${_monthNames[local.month - 1]}';
  }

  static String formatDateTimeHeader(DateTime startAt) {
    final local = startAt.toLocal();
    final weekday = _weekdayNames[local.weekday - 1];
    final date = '${local.day} ${_monthNames[local.month - 1]}';
    return '$weekday, $date · ${formatTime(startAt)}';
  }

  static String? formatDuration(int durationMin) {
    if (durationMin <= 0) {
      return null;
    }
    return '~$durationMin мин';
  }

  static String instructorLabel(String name) => 'Инструктор: $name';

  static String seatsDetailLabel(SlotDto slot) {
    if (slot.freeSeats <= 0) {
      return 'Места: ${SlotListMessages.noSeats}';
    }
    return 'Места: ${slot.freeSeats} из ${slot.totalSeats} свободно';
  }

  static String rentalLabel(int freeRentalEquipment) {
    final count = freeRentalEquipment < 0 ? 0 : freeRentalEquipment;
    return 'Прокат: $count ${_rentalSets(count)} свободно';
  }

  static String priceDetailLabel(int price) => 'Цена: ${formatPrice(price)}';

  static String _rentalSets(int count) {
    final mod10 = count % 10;
    final mod100 = count % 100;
    if (mod10 == 1 && mod100 != 11) {
      return 'комплект';
    }
    if (mod10 >= 2 && mod10 <= 4 && (mod100 < 12 || mod100 > 14)) {
      return 'комплекта';
    }
    return 'комплектов';
  }

  static String formatDayHeader(DateTime day, {DateTime? now}) {
    final reference = now ?? DateTime.now();
    final today = DateTime(reference.year, reference.month, reference.day);
    final target = DateTime(day.year, day.month, day.day);
    final diff = target.difference(today).inDays;

    final datePart = '${day.day} ${_monthNames[day.month - 1]}';
    return switch (diff) {
      0 => 'Сегодня, $datePart',
      1 => 'Завтра, $datePart',
      _ => datePart,
    };
  }

  static String formatPrice(int price) {
    return '$price ₽';
  }

  static String zoneTypeLabel(ZoneFormatType type) {
    return switch (type) {
      ZoneFormatType.novice => 'Новичковый',
      ZoneFormatType.experienced => 'Опытный',
    };
  }

  static String seatsLabel(SlotDto slot) {
    if (slot.freeSeats <= 0) {
      return SlotListMessages.noSeats;
    }
    return '${slot.freeSeats} из ${slot.totalSeats}';
  }
}
