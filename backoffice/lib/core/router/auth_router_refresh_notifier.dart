import 'dart:async';

import 'package:flutter/foundation.dart';

import '../session/auth_session.dart';

class AuthRouterRefreshNotifier extends ChangeNotifier {
  AuthRouterRefreshNotifier(AuthSession session) {
    _subscription = session.changes.listen((_) => notifyListeners());
  }

  late final StreamSubscription<AuthStatus> _subscription;

  @override
  void dispose() {
    _subscription.cancel();
    super.dispose();
  }
}
