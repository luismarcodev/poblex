const Map<String, String> _accentReplacements = {
  'á': 'a',
  'à': 'a',
  'ä': 'a',
  'â': 'a',
  'é': 'e',
  'è': 'e',
  'ë': 'e',
  'ê': 'e',
  'í': 'i',
  'ì': 'i',
  'ï': 'i',
  'î': 'i',
  'ó': 'o',
  'ò': 'o',
  'ö': 'o',
  'ô': 'o',
  'ú': 'u',
  'ù': 'u',
  'ü': 'u',
  'û': 'u',
  'ñ': 'n',
  'ç': 'c',
};

/// Turns free text (a form title, a survey question) into a short,
/// filesystem-safe slug so an exported file is identifiable by name
/// instead of only by its UUID.
String filenameSlug(String text, {int maxLength = 60}) {
  var result = text.toLowerCase();
  _accentReplacements.forEach((accented, plain) {
    result = result.replaceAll(accented, plain);
  });
  result = result
      .replaceAll(RegExp(r'[^a-z0-9]+'), '-')
      .replaceAll(RegExp(r'^-+|-+$'), '');
  if (result.length > maxLength) {
    result = result.substring(0, maxLength).replaceAll(RegExp(r'-+$'), '');
  }
  return result.isEmpty ? 'sin-titulo' : result;
}
