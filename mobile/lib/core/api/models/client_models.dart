import 'package:vertical_mobile/core/api/json_helpers.dart';

class ClientDto {
  const ClientDto({
    required this.id,
    required this.phone,
    required this.createdAt,
    this.name,
  });

  final String id;
  final String? name;
  final String phone;
  final DateTime createdAt;

  factory ClientDto.fromJson(Map<String, dynamic> json) {
    return ClientDto(
      id: json['id'] as String,
      name: json['name'] as String?,
      phone: json['phone'] as String,
      createdAt: parseApiDateTime(json['created_at'] as String),
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        if (name != null) 'name': name,
        'phone': phone,
        'created_at': createdAt.toUtc().toIso8601String(),
      };
}

class UpdateProfileRequest {
  const UpdateProfileRequest({required this.name});

  final String name;

  Map<String, dynamic> toJson() => {'name': name};
}
