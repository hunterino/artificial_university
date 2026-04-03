// Safe JSON extraction helpers.
//
// Each function checks the type of `json[key]` and throws [FormatException]
// with a descriptive message when the value is missing (and no fallback is
// provided) or has an unexpected type.

String extractString(Map<String, dynamic> json, String key,
    {String? fallback}) {
  final value = json[key];
  if (value == null) {
    if (fallback != null) return fallback;
    throw FormatException('Missing required string field "$key" in $json');
  }
  if (value is! String) {
    throw FormatException(
        'Expected String for "$key", got ${value.runtimeType}: $value');
  }
  return value;
}

int extractInt(Map<String, dynamic> json, String key, {int? fallback}) {
  final value = json[key];
  if (value == null) {
    if (fallback != null) return fallback;
    throw FormatException('Missing required int field "$key" in $json');
  }
  if (value is! int) {
    throw FormatException(
        'Expected int for "$key", got ${value.runtimeType}: $value');
  }
  return value;
}

double extractDouble(Map<String, dynamic> json, String key,
    {double? fallback}) {
  final value = json[key];
  if (value == null) {
    if (fallback != null) return fallback;
    throw FormatException('Missing required double field "$key" in $json');
  }
  if (value is int) return value.toDouble();
  if (value is! double) {
    throw FormatException(
        'Expected double for "$key", got ${value.runtimeType}: $value');
  }
  return value;
}

List<String> extractStringList(Map<String, dynamic> json, String key,
    {List<String>? fallback}) {
  final value = json[key];
  if (value == null) {
    if (fallback != null) return fallback;
    throw FormatException(
        'Missing required string list field "$key" in $json');
  }
  if (value is! List) {
    throw FormatException(
        'Expected List for "$key", got ${value.runtimeType}: $value');
  }
  return value.cast<String>();
}

List<dynamic> extractList(Map<String, dynamic> json, String key,
    {List<dynamic>? fallback}) {
  final value = json[key];
  if (value == null) {
    if (fallback != null) return fallback;
    throw FormatException('Missing required list field "$key" in $json');
  }
  if (value is! List) {
    throw FormatException(
        'Expected List for "$key", got ${value.runtimeType}: $value');
  }
  return value;
}

Map<String, dynamic> extractMap(Map<String, dynamic> json, String key) {
  final value = json[key];
  if (value == null) {
    throw FormatException('Missing required map field "$key" in $json');
  }
  if (value is! Map<String, dynamic>) {
    throw FormatException(
        'Expected Map<String, dynamic> for "$key", got ${value.runtimeType}: $value');
  }
  return value;
}

String? extractStringOrNull(Map<String, dynamic> json, String key) {
  final value = json[key];
  if (value == null) return null;
  if (value is! String) {
    throw FormatException(
        'Expected String or null for "$key", got ${value.runtimeType}: $value');
  }
  return value;
}

List<String>? extractStringListOrNull(Map<String, dynamic> json, String key) {
  final value = json[key];
  if (value == null) return null;
  if (value is! List) {
    throw FormatException(
        'Expected List or null for "$key", got ${value.runtimeType}: $value');
  }
  return value.cast<String>();
}
