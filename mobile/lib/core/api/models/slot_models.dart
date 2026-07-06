import 'package:vertical_mobile/core/api/json_helpers.dart';
import 'package:vertical_mobile/core/api/models/common_models.dart';
import 'package:vertical_mobile/core/api/models/instructor_models.dart';

enum SlotStatus {
  scheduled,
  cancelled;

  static SlotStatus fromWire(String value) => SlotStatus.values.firstWhere(
        (item) => item.name == value,
        orElse: () => throw ArgumentError('Unknown slot status: $value'),
      );

  String get wireValue => name;
}

class SlotDto {
  const SlotDto({
    required this.id,
    required this.startAt,
    required this.zoneFormat,
    required this.instructorInfo,
    required this.totalSeats,
    required this.freeSeats,
    required this.freeRentalEquipment,
    required this.price,
    required this.rentalPrice,
    required this.status,
  });

  final String id;
  final DateTime startAt;
  final ZoneFormatDto zoneFormat;
  final InstructorDto instructorInfo;
  final int totalSeats;
  final int freeSeats;
  final int freeRentalEquipment;
  final int price;
  final int rentalPrice;
  final SlotStatus status;

  factory SlotDto.fromJson(Map<String, dynamic> json) {
    return SlotDto(
      id: json['id'] as String,
      startAt: parseApiDateTime(json['start_at'] as String),
      zoneFormat: ZoneFormatDto.fromJson(
        json['zone_format'] as Map<String, dynamic>,
      ),
      instructorInfo: InstructorDto.fromJson(
        json['instructor_info'] as Map<String, dynamic>,
      ),
      totalSeats: json['total_seats'] as int,
      freeSeats: json['free_seats'] as int,
      freeRentalEquipment: json['free_rental_equipment'] as int,
      price: json['price'] as int,
      rentalPrice: json['rental_price'] as int,
      status: SlotStatus.fromWire(json['status'] as String),
    );
  }
}

class SlotListResponse {
  const SlotListResponse({
    required this.items,
    required this.meta,
  });

  final List<SlotDto> items;
  final PaginationMeta meta;

  factory SlotListResponse.fromJson(Map<String, dynamic> json) {
    return SlotListResponse(
      items: readList(json, 'items', SlotDto.fromJson),
      meta: PaginationMeta.fromJson(json['meta'] as Map<String, dynamic>),
    );
  }
}

class ListSlotsQuery {
  const ListSlotsQuery({
    this.dateFrom,
    this.dateTo,
    this.zoneFormatTypes = const [],
    this.instructorIds = const [],
    this.onlyAvailable = false,
    this.limit = 20,
    this.offset = 0,
  });

  final DateTime? dateFrom;
  final DateTime? dateTo;
  final List<ZoneFormatType> zoneFormatTypes;
  final List<String> instructorIds;
  final bool onlyAvailable;
  final int limit;
  final int offset;

  Map<String, dynamic> toQueryParameters() {
    return {
      if (dateFrom != null) 'date_from': dateFrom!.toUtc().toIso8601String(),
      if (dateTo != null) 'date_to': dateTo!.toUtc().toIso8601String(),
      if (zoneFormatTypes.isNotEmpty)
        'zone_format_type': zoneFormatTypes.map((e) => e.wireValue).toList(),
      if (instructorIds.isNotEmpty) 'instructor_id': instructorIds,
      'only_available': onlyAvailable,
      'limit': limit,
      'offset': offset,
    };
  }
}
