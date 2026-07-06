DateTime parseApiDateTime(String value) => DateTime.parse(value).toUtc();

String? readString(Map<String, dynamic> json, String key) =>
    json[key] as String?;

int readInt(Map<String, dynamic> json, String key) => json[key] as int;

bool readBool(Map<String, dynamic> json, String key) => json[key] as bool;

List<T> readList<T>(
  Map<String, dynamic> json,
  String key,
  T Function(Map<String, dynamic>) map,
) {
  final raw = json[key] as List<dynamic>;
  return raw.map((item) => map(item as Map<String, dynamic>)).toList();
}
