import 'package:vertical_mobile/core/api/json_helpers.dart';
import 'package:vertical_mobile/core/api/models/common_models.dart';

enum ZoneFormatType {
  novice,
  experienced;

  static ZoneFormatType fromWire(String value) => ZoneFormatType.values.firstWhere(
        (item) => item.name == value,
        orElse: () => throw ArgumentError('Unknown zone format type: $value'),
      );

  String get wireValue => name;
}

class ZoneFormatDto {
  const ZoneFormatDto({
    required this.id,
    required this.name,
    required this.type,
    required this.capacityCap,
    required this.durationMin,
    this.description,
  });

  final String id;
  final String name;
  final String? description;
  final ZoneFormatType type;
  final int capacityCap;
  final int durationMin;

  factory ZoneFormatDto.fromJson(Map<String, dynamic> json) {
    return ZoneFormatDto(
      id: json['id'] as String,
      name: json['name'] as String,
      description: json['description'] as String?,
      type: ZoneFormatType.fromWire(json['type'] as String),
      capacityCap: json['capacity_cap'] as int,
      durationMin: json['duration_min'] as int,
    );
  }
}

class InstructorDto {
  const InstructorDto({
    required this.id,
    required this.name,
  });

  final String id;
  final String name;

  factory InstructorDto.fromJson(Map<String, dynamic> json) {
    return InstructorDto(
      id: json['id'] as String,
      name: json['name'] as String,
    );
  }
}

class ZoneFormatListResponse {
  const ZoneFormatListResponse({
    required this.items,
    required this.meta,
  });

  final List<ZoneFormatDto> items;
  final PaginationMeta meta;

  factory ZoneFormatListResponse.fromJson(Map<String, dynamic> json) {
    return ZoneFormatListResponse(
      items: readList(json, 'items', ZoneFormatDto.fromJson),
      meta: PaginationMeta.fromJson(json['meta'] as Map<String, dynamic>),
    );
  }
}

class InstructorListResponse {
  const InstructorListResponse({
    required this.items,
    required this.meta,
  });

  final List<InstructorDto> items;
  final PaginationMeta meta;

  factory InstructorListResponse.fromJson(Map<String, dynamic> json) {
    return InstructorListResponse(
      items: readList(json, 'items', InstructorDto.fromJson),
      meta: PaginationMeta.fromJson(json['meta'] as Map<String, dynamic>),
    );
  }
}
