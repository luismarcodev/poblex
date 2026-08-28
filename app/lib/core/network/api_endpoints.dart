/// Paths of the API, relative to `/v1`. Kept in one place so a contract change
/// shows up as a single diff instead of scattered string literals.
abstract final class ApiEndpoints {
  const ApiEndpoints._();

  static const String municipalities = '/municipalities';
  static String municipality(String id) => '/municipalities/$id';

  static const String devices = '/devices';
  static String device(String id) => '/devices/$id';

  static const String news = '/news';

  /// Archived news — the "Histórico" tab. A dedicated endpoint and not a flag
  /// on the published list, so pinned items never leak into the archive.
  static const String newsArchive = '/news/archive';

  /// Categories actually present in the municipality. Without this the filter
  /// bar could only offer the categories of the page already loaded.
  static const String newsCategories = '/news/categories';

  static String newsDetail(String id) => '/news/$id';

  static const String events = '/events';
  static String eventDetail(String id) => '/events/$id';
  static String eventReminder(String id) => '/events/$id/reminder';

  static const String alerts = '/alerts';
  static String alertDetail(String id) => '/alerts/$id';

  static const String incidents = '/incidents';
  static String incidentPhoto(String id) => '/incidents/$id/photo';
  static String incidentDetail(String id) => '/incidents/$id';

  static const String surveys = '/surveys';
  static String surveyDetail(String id) => '/surveys/$id';
  static String surveyVote(String id) => '/surveys/$id/vote';

  static const String forms = '/forms';
  static String formDetail(String id) => '/forms/$id';
  static String formSubmissions(String id) => '/forms/$id/submissions';

  static const String pharmaciesDuty = '/pharmacies/duty';
  static const String pharmaciesDutyToday = '/pharmacies/duty/today';

  static const String businesses = '/businesses';
  static const String businessesCategories = '/businesses/categories';
  static String businessDetail(String id) => '/businesses/$id';

  static const String facilities = '/facilities';
  static String facilityDetail(String id) => '/facilities/$id';
  static String facilityAvailability(String id) => '/facilities/$id/availability';

  static const String reservations = '/reservations';
  static String reservationCancel(String id) => '/reservations/$id/cancel';
}
