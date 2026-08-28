import 'package:web/web.dart' as web;

/// Redirect completo, no popup: "Facebook Login for Business" gestiona su
/// propio flujo de consentimiento y vuelve al callback del backend, que a su
/// vez redirige de vuelta aquí con `?status=ok|error`.
void launchSocialOAuth(String url) {
  web.window.location.href = url;
}
