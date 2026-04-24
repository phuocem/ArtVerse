class TypeHelpers {
  static String asString(dynamic value, [String defaultValue = '']) {
    if (value == null) return defaultValue;
    return value.toString();
  }

  static String? asStringOrNull(dynamic value) {
    if (value == null) return null;
    return value.toString();
  }

  static int asInt(dynamic value, [int defaultValue = 0]) {
    if (value == null) return defaultValue;
    if (value is int) return value;
    if (value is double) return value.toInt();
    if (value is String) return int.tryParse(value) ?? defaultValue;
    return defaultValue;
  }

  static double asDouble(dynamic value, [double defaultValue = 0.0]) {
    if (value == null) return defaultValue;
    if (value is double) return value;
    if (value is int) return value.toDouble();
    if (value is String) return double.tryParse(value) ?? defaultValue;
    return defaultValue;
  }

  static bool asBool(dynamic value, [bool defaultValue = false]) {
    if (value == null) return defaultValue;
    if (value is bool) return value;
    if (value is int) return value != 0;
    if (value is String) {
      final lower = value.toLowerCase();
      if (lower == 'true' || lower == '1') return true;
      if (lower == 'false' || lower == '0') return false;
    }
    return defaultValue;
  }

  static Map<String, dynamic> asMap(dynamic value) {
    if (value == null) return {};
    if (value is Map<String, dynamic>) return value;
    if (value is Map) return Map<String, dynamic>.from(value);
    return {};
  }

  static List<T> asList<T>(dynamic value) {
    if (value == null) return [];
    if (value is List<T>) return value;
    if (value is List) return List<T>.from(value);
    return [];
  }

  static List<dynamic> asListDynamic(dynamic value) {
    if (value == null) return [];
    if (value is List) return value;
    return [];
  }

  static Iterable<T> asIterable<T>(dynamic value) {
    if (value == null) return [];
    if (value is Iterable<T>) return value;
    if (value is Iterable) return value.cast<T>();
    if (value is List) return value.cast<T>();
    return [];
  }
}
