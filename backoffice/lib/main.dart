import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_web_plugins/url_strategy.dart';

import 'app.dart';
import 'core/di/injection_container.dart';
import 'core/router/app_router.dart';
import 'core/session/auth_session.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  usePathUrlStrategy();
  configureDependencies();
  final router = createRouter(getIt<AuthSession>());
  runApp(ProviderScope(child: PoblexBackofficeApp(router: router)));
}
