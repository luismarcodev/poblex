import 'package:go_router/go_router.dart';

import '../../features/alerts/domain/entities/managed_alert.dart';
import '../../features/alerts/presentation/screens/alert_editor_screen.dart';
import '../../features/alerts/presentation/screens/alerts_screen.dart';
import '../../features/auth/presentation/screens/login_screen.dart';
import '../../features/businesses/domain/entities/managed_business.dart';
import '../../features/businesses/presentation/screens/business_editor_screen.dart';
import '../../features/businesses/presentation/screens/businesses_screen.dart';
import '../../features/auth/presentation/screens/forgot_password_screen.dart';
import '../../features/auth/presentation/screens/reset_password_screen.dart';
import '../../features/auth/presentation/screens/splash_screen.dart';
import '../../features/events/domain/entities/managed_event.dart';
import '../../features/events/presentation/screens/event_editor_screen.dart';
import '../../features/events/presentation/screens/events_screen.dart';
import '../../features/facilities/domain/entities/managed_facility.dart';
import '../../features/facilities/presentation/screens/facilities_screen.dart';
import '../../features/facilities/presentation/screens/facility_editor_screen.dart';
import '../../features/facilities/presentation/screens/reservations_screen.dart';
import '../../features/forms/presentation/screens/form_editor_screen.dart';
import '../../features/forms/presentation/screens/forms_screen.dart';
import '../../features/incidents/presentation/screens/incidents_screen.dart';
import '../../features/news/domain/entities/news_item.dart';
import '../../features/news/presentation/screens/news_editor_screen.dart';
import '../../features/news/presentation/screens/news_screen.dart';
import '../../features/pharmacies/domain/entities/duty_pharmacy.dart';
import '../../features/pharmacies/presentation/screens/duty_pharmacies_screen.dart';
import '../../features/pharmacies/presentation/screens/duty_pharmacy_editor_screen.dart';
import '../../features/social/presentation/screens/social_connections_screen.dart';
import '../../features/surveys/presentation/screens/survey_editor_screen.dart';
import '../../features/surveys/presentation/screens/surveys_screen.dart';
import '../../shared/presentation/backoffice_shell.dart';
import '../session/auth_session.dart';
import 'auth_router_refresh_notifier.dart';

GoRouter createRouter(AuthSession session) {
  final refresh = AuthRouterRefreshNotifier(session);
  return GoRouter(
    initialLocation: '/inicio',
    refreshListenable: refresh,
    redirect: (context, state) {
      final path = state.matchedLocation;
      return resolveAuthRedirect(status: session.status, path: path);
    },
    routes: [
      GoRoute(path: '/inicio', builder: (_, _) => const SplashScreen()),
      GoRoute(path: '/acceso', builder: (_, _) => const LoginScreen()),
      GoRoute(
        path: '/forgot-password',
        builder: (_, _) => const ForgotPasswordScreen(),
      ),
      GoRoute(
        path: '/reset-password',
        builder: (_, state) => ResetPasswordScreen(
          token: state.uri.queryParameters['token'] ?? '',
        ),
      ),
      ShellRoute(
        builder: (context, state, child) =>
            BackofficeShell(location: state.matchedLocation, child: child),
        routes: [
          GoRoute(
            path: '/noticias',
            builder: (_, _) => const NewsScreen(),
            routes: [
              GoRoute(
                path: 'nueva',
                builder: (_, _) => const NewsEditorScreen(),
              ),
              GoRoute(
                path: 'editar/:id',
                builder: (_, state) => NewsEditorScreen(
                  newsId: state.pathParameters['id'],
                  initialNews: state.extra as NewsItem?,
                ),
              ),
              GoRoute(
                path: 'conexiones',
                builder: (_, state) => SocialConnectionsScreen(
                  oauthStatus: state.uri.queryParameters['status'],
                ),
              ),
            ],
          ),
          GoRoute(
            path: '/eventos',
            builder: (_, _) => const EventsScreen(),
            routes: [
              GoRoute(
                path: 'nuevo',
                builder: (_, _) => const EventEditorScreen(),
              ),
              GoRoute(
                path: 'editar/:id',
                builder: (_, state) => EventEditorScreen(
                  eventId: state.pathParameters['id'],
                  initialEvent: state.extra as ManagedEvent?,
                ),
              ),
            ],
          ),
          GoRoute(
            path: '/alertas',
            builder: (_, _) => const AlertsScreen(),
            routes: [
              GoRoute(
                path: 'nueva',
                builder: (_, _) => const AlertEditorScreen(),
              ),
              GoRoute(
                path: 'editar/:id',
                builder: (_, state) => AlertEditorScreen(
                  alertId: state.pathParameters['id'],
                  initialAlert: state.extra as ManagedAlert?,
                ),
              ),
            ],
          ),
          GoRoute(
            path: '/encuestas',
            builder: (_, _) => const SurveysScreen(),
            routes: [
              GoRoute(
                path: 'nueva',
                builder: (_, _) => const SurveyEditorScreen(),
              ),
            ],
          ),
          GoRoute(
            path: '/incidencias',
            builder: (_, _) => const IncidentsScreen(),
          ),
          GoRoute(
            path: '/comercios',
            builder: (_, _) => const BusinessesScreen(),
            routes: [
              GoRoute(
                path: 'nuevo',
                builder: (_, _) => const BusinessEditorScreen(),
              ),
              GoRoute(
                path: 'editar/:id',
                builder: (_, state) => BusinessEditorScreen(
                  businessId: state.pathParameters['id'],
                  initialBusiness: state.extra as ManagedBusiness?,
                ),
              ),
            ],
          ),
          GoRoute(
            path: '/instalaciones',
            builder: (_, _) => const FacilitiesScreen(),
            routes: [
              GoRoute(
                path: 'nueva',
                builder: (_, _) => const FacilityEditorScreen(),
              ),
              GoRoute(
                path: 'editar/:id',
                builder: (_, state) => FacilityEditorScreen(
                  facilityId: state.pathParameters['id'],
                  initialFacility: state.extra as ManagedFacility?,
                ),
              ),
              GoRoute(
                path: 'reservas',
                builder: (_, _) => const ReservationsScreen(),
              ),
            ],
          ),
          GoRoute(
            path: '/farmacias',
            builder: (_, _) => const DutyPharmaciesScreen(),
            routes: [
              GoRoute(
                path: 'nueva',
                builder: (_, _) => const DutyPharmacyEditorScreen(),
              ),
              GoRoute(
                path: 'editar/:municipalityId/:date',
                redirect: (_, state) =>
                    DateTime.tryParse(state.pathParameters['date'] ?? '') ==
                        null
                    ? '/farmacias'
                    : null,
                builder: (_, state) => DutyPharmacyEditorScreen(
                  municipalityId: state.pathParameters['municipalityId'],
                  date: DateTime.parse(state.pathParameters['date']!),
                  initial: state.extra as DutyPharmacy?,
                ),
              ),
            ],
          ),
          GoRoute(
            path: '/formularios',
            builder: (context, _) =>
                FormsScreen(onCreate: () => context.go('/formularios/nuevo')),
            routes: [
              GoRoute(
                path: 'nuevo',
                builder: (context, _) => FormEditorScreen(
                  onCancel: () => context.go('/formularios'),
                  onCreated: () => context.go('/formularios'),
                ),
              ),
            ],
          ),
        ],
      ),
    ],
  );
}

String? resolveAuthRedirect({
  required AuthStatus status,
  required String path,
}) {
  final isPasswordRecovery =
      path == '/forgot-password' || path == '/reset-password';
  // Recovery links and protected deep links must survive bootstrapping. Once
  // the refresh request finishes, the session change re-evaluates the route.
  if (isPasswordRecovery || status == AuthStatus.bootstrapping) return null;
  if (status == AuthStatus.unauthenticated) {
    return path == '/acceso' ? null : '/acceso';
  }
  if (path == '/inicio' || path == '/acceso') return '/noticias';
  return null;
}
