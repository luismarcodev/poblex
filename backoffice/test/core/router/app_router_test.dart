import 'package:flutter_test/flutter_test.dart';
import 'package:poblex_backoffice/core/router/app_router.dart';
import 'package:poblex_backoffice/core/session/auth_session.dart';

void main() {
  test('preserves a protected deep link while the session bootstraps', () {
    final redirect = resolveAuthRedirect(
      status: AuthStatus.bootstrapping,
      path: '/noticias/editar/news-1',
    );

    expect(redirect, isNull);
  });

  test('redirects protected routes only after authentication fails', () {
    final redirect = resolveAuthRedirect(
      status: AuthStatus.unauthenticated,
      path: '/noticias/editar/news-1',
    );

    expect(redirect, '/acceso');
  });

  test('keeps password recovery public regardless of session state', () {
    final redirect = resolveAuthRedirect(
      status: AuthStatus.unauthenticated,
      path: '/reset-password',
    );

    expect(redirect, isNull);
  });
}
