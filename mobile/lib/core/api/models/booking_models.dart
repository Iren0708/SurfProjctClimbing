import 'package:vertical_mobile/core/api/json_helpers.dart';
import 'package:vertical_mobile/core/api/models/common_models.dart';
import 'package:vertical_mobile/core/api/models/slot_models.dart';

enum Equipment {
  own,
  rental;

  static Equipment fromWire(String value) => Equipment.values.firstWhere(
        (item) => item.name == value,
        orElse: () => throw ArgumentError('Unknown equipment: $value'),
      );

  String get wireValue => name;
}

enum BookingStatus {
  active,
  cancelled,
  lateCancel,
  clubCancelled;

  static BookingStatus fromWire(String value) => switch (value) {
        'active' => BookingStatus.active,
        'cancelled' => BookingStatus.cancelled,
        'late_cancel' => BookingStatus.lateCancel,
        'club_cancelled' => BookingStatus.clubCancelled,
        _ => throw ArgumentError('Unknown booking status: $value'),
      };

  String get wireValue => switch (this) {
        BookingStatus.active => 'active',
        BookingStatus.cancelled => 'cancelled',
        BookingStatus.lateCancel => 'late_cancel',
        BookingStatus.clubCancelled => 'club_cancelled',
      };
}

class CreateBookingRequest {
  const CreateBookingRequest({
    required this.slotId,
    required this.equipment,
  });

  final String slotId;
  final Equipment equipment;

  Map<String, dynamic> toJson() => {
        'slot_id': slotId,
        'equipment': equipment.wireValue,
      };
}

class BookingDto {
  const BookingDto({
    required this.id,
    required this.slotId,
    required this.clientId,
    required this.equipment,
    required this.status,
    required this.priceTotal,
    required this.createdAt,
    this.cancelledAt,
    this.cancellationReason,
    this.slot,
  });

  final String id;
  final String slotId;
  final String clientId;
  final Equipment equipment;
  final BookingStatus status;
  final int priceTotal;
  final DateTime createdAt;
  final DateTime? cancelledAt;
  final String? cancellationReason;
  final SlotDto? slot;

  factory BookingDto.fromJson(Map<String, dynamic> json) {
    final cancelledAtRaw = json['cancelled_at'] as String?;
    final slotJson = json['slot'];
    return BookingDto(
      id: json['id'] as String,
      slotId: json['slot_id'] as String,
      clientId: json['client_id'] as String,
      equipment: Equipment.fromWire(json['equipment'] as String),
      status: BookingStatus.fromWire(json['status'] as String),
      priceTotal: json['price_total'] as int,
      createdAt: parseApiDateTime(json['created_at'] as String),
      cancelledAt:
          cancelledAtRaw == null ? null : parseApiDateTime(cancelledAtRaw),
      cancellationReason: json['cancellation_reason'] as String?,
      slot: slotJson == null
          ? null
          : SlotDto.fromJson(slotJson as Map<String, dynamic>),
    );
  }
}

class BookingSummaryDto {
  const BookingSummaryDto({
    required this.id,
    required this.slotId,
    required this.equipment,
    required this.status,
    required this.priceTotal,
    required this.createdAt,
    this.cancelledAt,
    this.cancellationReason,
    this.slot,
  });

  final String id;
  final String slotId;
  final Equipment equipment;
  final BookingStatus status;
  final int priceTotal;
  final DateTime createdAt;
  final DateTime? cancelledAt;
  final String? cancellationReason;
  final SlotDto? slot;

  factory BookingSummaryDto.fromJson(Map<String, dynamic> json) {
    final cancelledAtRaw = json['cancelled_at'] as String?;
    final slotJson = json['slot'];
    return BookingSummaryDto(
      id: json['id'] as String,
      slotId: json['slot_id'] as String,
      equipment: Equipment.fromWire(json['equipment'] as String),
      status: BookingStatus.fromWire(json['status'] as String),
      priceTotal: json['price_total'] as int,
      createdAt: parseApiDateTime(json['created_at'] as String),
      cancelledAt:
          cancelledAtRaw == null ? null : parseApiDateTime(cancelledAtRaw),
      cancellationReason: json['cancellation_reason'] as String?,
      slot: slotJson == null
          ? null
          : SlotDto.fromJson(slotJson as Map<String, dynamic>),
    );
  }
}

class CreateBookingResponse extends BookingDto {
  const CreateBookingResponse({
    required super.id,
    required super.slotId,
    required super.clientId,
    required super.equipment,
    required super.status,
    required super.priceTotal,
    required super.createdAt,
    required this.isFirstBooking,
    required this.reminderHours,
    super.cancelledAt,
    super.cancellationReason,
    super.slot,
  });

  final bool isFirstBooking;
  final List<int> reminderHours;

  factory CreateBookingResponse.fromJson(Map<String, dynamic> json) {
    final booking = BookingDto.fromJson(json);
    final reminderHoursRaw = json['reminder_hours'] as List<dynamic>?;
    return CreateBookingResponse(
      id: booking.id,
      slotId: booking.slotId,
      clientId: booking.clientId,
      equipment: booking.equipment,
      status: booking.status,
      priceTotal: booking.priceTotal,
      createdAt: booking.createdAt,
      cancelledAt: booking.cancelledAt,
      cancellationReason: booking.cancellationReason,
      slot: booking.slot,
      isFirstBooking: json['is_first_booking'] as bool,
      reminderHours: reminderHoursRaw?.cast<int>() ?? const [24, 2],
    );
  }
}

class BookingListResponse {
  const BookingListResponse({
    required this.items,
    required this.meta,
  });

  final List<BookingSummaryDto> items;
  final PaginationMeta meta;

  factory BookingListResponse.fromJson(Map<String, dynamic> json) {
    return BookingListResponse(
      items: readList(json, 'items', BookingSummaryDto.fromJson),
      meta: PaginationMeta.fromJson(json['meta'] as Map<String, dynamic>),
    );
  }
}

class ListBookingsQuery {
  const ListBookingsQuery({
    this.statuses = const [],
    this.limit = 20,
    this.offset = 0,
  });

  final List<BookingStatus> statuses;
  final int limit;
  final int offset;

  Map<String, dynamic> toQueryParameters() {
    return {
      if (statuses.isNotEmpty) 'status': statuses.map((e) => e.wireValue).toList(),
      'limit': limit,
      'offset': offset,
    };
  }
}
