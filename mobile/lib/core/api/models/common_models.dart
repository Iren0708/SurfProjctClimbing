class PaginationMeta {
  const PaginationMeta({
    required this.limit,
    required this.offset,
    required this.total,
  });

  final int limit;
  final int offset;
  final int total;

  factory PaginationMeta.fromJson(Map<String, dynamic> json) {
    return PaginationMeta(
      limit: json['limit'] as int,
      offset: json['offset'] as int,
      total: json['total'] as int,
    );
  }

  Map<String, dynamic> toJson() => {
        'limit': limit,
        'offset': offset,
        'total': total,
      };
}

class ApiErrorDetails {
  const ApiErrorDetails({
    this.availableSeats,
    this.availableRentalEquipment,
  });

  final int? availableSeats;
  final int? availableRentalEquipment;

  factory ApiErrorDetails.fromJson(Map<String, dynamic> json) {
    return ApiErrorDetails(
      availableSeats: json['available_seats'] as int?,
      availableRentalEquipment: json['available_rental_equipment'] as int?,
    );
  }
}

class ApiErrorBody {
  const ApiErrorBody({
    required this.code,
    required this.message,
    this.details,
  });

  final String code;
  final String message;
  final ApiErrorDetails? details;

  factory ApiErrorBody.fromJson(Map<String, dynamic> json) {
    final detailsJson = json['details'];
    return ApiErrorBody(
      code: json['code'] as String,
      message: json['message'] as String,
      details: detailsJson == null
          ? null
          : ApiErrorDetails.fromJson(detailsJson as Map<String, dynamic>),
    );
  }
}
