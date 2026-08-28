/// Turns an open category slug ("obras_urgentes") into a readable label
/// ("Obras urgentes") when there is no curated translation for it.
///
/// Categories are open text set by each town's manager from the backoffice —
/// there is no closed enum on the backend — so a brand-new slug the app has
/// never seen must still render as something a vecino can read, never the
/// raw slug and never a blank space.
String prettifyCategorySlug(String slug) {
  final String spaced = slug.replaceAll(RegExp('[_-]+'), ' ').trim();
  if (spaced.isEmpty) return slug;
  return spaced[0].toUpperCase() + spaced.substring(1);
}
