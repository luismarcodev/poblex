/// Trims free text and turns a blank result into `null` — the pattern every
/// editor screen uses for its optional (usually Valencian) fields before
/// sending them to the API.
String? optionalText(String value) {
  final trimmed = value.trim();
  return trimmed.isEmpty ? null : trimmed;
}
