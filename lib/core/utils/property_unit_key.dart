// lib/core/utils/property_unit_key.dart

/// Normalizes flat numbers so "A-203", "A 203", "a203" match.
String normalizeFlatNumber(String flat) {
  return flat.toUpperCase().replaceAll(RegExp(r'[^A-Z0-9]'), '');
}

String normalizePart(String value) {
  return value.trim().toLowerCase().replaceAll(RegExp(r'\s+'), ' ');
}

/// Stable key for "same unit" checks.
/// Society: societyId + building + floor + flat
/// Independent: building (house type) + flat (house name)
String buildPropertyUnitKey({
  required String societyId,
  required String building,
  required String floor,
  required String flatNumber,
}) {
  final flat = normalizeFlatNumber(flatNumber);
  final b = normalizePart(building);
  final f = normalizePart(floor);
  final s = societyId.trim().toLowerCase();
  return '$s|$b|$f|$flat';
}