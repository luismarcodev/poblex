import 'dart:async';

import '../../features/auth/domain/entities/manager_profile.dart';

enum AuthStatus { bootstrapping, authenticated, unauthenticated }

class AuthSession {
  AuthStatus _status = AuthStatus.bootstrapping;
  String? _accessToken;
  ManagerProfile? _profile;
  final _changes = StreamController<AuthStatus>.broadcast();

  AuthStatus get status => _status;
  String? get accessToken => _accessToken;
  ManagerProfile? get profile => _profile;
  Stream<AuthStatus> get changes => _changes.stream;

  void updateAccessToken(String token) {
    _accessToken = token;
  }

  void authenticate(String token, ManagerProfile profile) {
    _accessToken = token;
    _profile = profile;
    _status = AuthStatus.authenticated;
    _changes.add(_status);
  }

  void clear() {
    _accessToken = null;
    _profile = null;
    _status = AuthStatus.unauthenticated;
    _changes.add(_status);
  }

  void dispose() {
    _changes.close();
  }
}
