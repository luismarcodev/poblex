import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'core/di/injection_container.dart';
import 'core/notifications/push_lifecycle_listener.dart';
import 'core/notifications/push_notification_service.dart';
import 'core/router/app_router.dart';
import 'core/session/session_state.dart';
import 'core/session/session_view_model.dart';
import 'core/theme/app_theme.dart';
import 'core/theme/brand_palette_resolver.dart';
import 'features/municipalities/presentation/screens/municipality_onboarding_screen.dart';
import 'l10n/app_localizations.dart';

@pragma('vm:entry-point')
Future<void> firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp();
}

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  bool firebaseAvailable = false;
  try {
    await Firebase.initializeApp();
    FirebaseMessaging.onBackgroundMessage(firebaseMessagingBackgroundHandler);
    firebaseAvailable = true;
  } on Object catch (error) {
    if (kDebugMode) {
      debugPrint(
        'Firebase is not configured yet; push notifications are disabled: '
        '$error',
      );
    }
  }

  await configureDependencies(firebaseAvailable: firebaseAvailable);
  try {
    await getIt<PushNotificationService>().initialize();
  } on Object catch (error) {
    // Push is optional for reading municipal content. A transient FCM failure
    // must not turn into a blank screen before Flutter can render the app.
    if (kDebugMode) {
      debugPrint('Push notifications could not be initialized: $error');
    }
  }
  runApp(const ProviderScope(child: PoblexApp()));
}

class PoblexApp extends ConsumerStatefulWidget {
  const PoblexApp({super.key});

  @override
  ConsumerState<PoblexApp> createState() => _PoblexAppState();
}

class _PoblexAppState extends ConsumerState<PoblexApp> {
  late final GoRouter _router = AppRouter.create();

  @override
  void dispose() {
    _router.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final AsyncValue<SessionState> session = ref.watch(
      sessionViewModelProvider,
    );
    return session.when(
      loading: () => _FoundationApp(
        home: const Scaffold(body: Center(child: CircularProgressIndicator())),
      ),
      error: (_, _) =>
          const _FoundationApp(home: MunicipalityOnboardingScreen()),
      data: (SessionState value) {
        final brand = resolveBrandPalette(value.municipalityPrimaryColor);
        if (!value.hasMunicipality) {
          return _FoundationApp(
            locale: value.locale.uiLocale,
            lightTheme: AppTheme.light(brand: brand),
            darkTheme: AppTheme.dark(brand: brand),
            home: const MunicipalityOnboardingScreen(),
          );
        }
        return MaterialApp.router(
          onGenerateTitle: (BuildContext context) =>
              AppLocalizations.of(context).appName,
          locale: value.locale.uiLocale,
          theme: AppTheme.light(brand: brand),
          darkTheme: AppTheme.dark(brand: brand),
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          routerConfig: _router,
          builder: (BuildContext context, Widget? child) =>
              AppTheme.textScalingBuilder(
                context,
                PushLifecycleListener(
                  router: _router,
                  child: child ?? const SizedBox.shrink(),
                ),
              ),
        );
      },
    );
  }
}

class _FoundationApp extends StatelessWidget {
  const _FoundationApp({
    required this.home,
    this.locale,
    this.lightTheme,
    this.darkTheme,
  });

  final Widget home;
  final Locale? locale;
  final ThemeData? lightTheme;
  final ThemeData? darkTheme;

  @override
  Widget build(BuildContext context) => MaterialApp(
    onGenerateTitle: (BuildContext context) =>
        AppLocalizations.of(context).appName,
    locale: locale,
    theme: lightTheme ?? AppTheme.light(),
    darkTheme: darkTheme ?? AppTheme.dark(),
    builder: AppTheme.textScalingBuilder,
    localizationsDelegates: AppLocalizations.localizationsDelegates,
    supportedLocales: AppLocalizations.supportedLocales,
    home: home,
  );
}
