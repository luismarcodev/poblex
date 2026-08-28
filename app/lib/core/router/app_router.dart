import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../features/alerts/presentation/screens/alert_detail_screen.dart';
import '../../features/alerts/presentation/screens/alerts_screen.dart';
import '../../features/businesses/presentation/screens/business_detail_screen.dart';
import '../../features/businesses/presentation/screens/businesses_screen.dart';
import '../../features/events/presentation/screens/event_detail_screen.dart';
import '../../features/events/presentation/screens/events_screen.dart';
import '../../features/facilities/presentation/screens/facilities_screen.dart';
import '../../features/facilities/presentation/screens/facility_detail_screen.dart';
import '../../features/facilities/presentation/screens/my_reservations_screen.dart';
import '../../features/forms/presentation/screens/form_detail_screen.dart';
import '../../features/forms/presentation/screens/forms_screen.dart';
import '../../features/incidents/presentation/screens/incident_detail_screen.dart';
import '../../features/incidents/presentation/screens/incident_report_screen.dart';
import '../../features/incidents/presentation/screens/my_incidents_screen.dart';
import '../../features/pharmacies/presentation/screens/pharmacies_screen.dart';
import '../../features/surveys/presentation/screens/survey_detail_screen.dart';
import '../../features/surveys/presentation/screens/surveys_screen.dart';
import '../../features/news/domain/entities/news_item.dart';
import '../../features/news/presentation/screens/news_detail_screen.dart';
import '../../features/news/presentation/screens/news_screen.dart';
import '../../features/news/presentation/screens/pdf_attachment_screen.dart';
import '../../shared/presentation/app_shell.dart';
import '../../shared/presentation/home_screen.dart';
import '../../shared/presentation/settings_screen.dart';

abstract final class AppRouter {
  static GoRouter create() => GoRouter(
    initialLocation: '/',
    routes: <RouteBase>[
      // Reachable from Home or the drawer — every section sits one tap away
      // from anywhere in the app (A-33). These five live outside the shell
      // because they don't need branch state preserved the way the
      // StatefulShellRoute branches below do.
      GoRoute(
        path: '/incidents',
        builder: (_, _) => const MyIncidentsScreen(),
        routes: <RouteBase>[
          GoRoute(path: 'new', builder: (_, _) => const IncidentReportScreen()),
          GoRoute(
            path: ':id',
            builder: (_, GoRouterState state) =>
                IncidentDetailScreen(incidentId: state.pathParameters['id']!),
          ),
        ],
      ),
      GoRoute(
        path: '/surveys',
        builder: (_, _) => const SurveysScreen(),
        routes: <RouteBase>[
          GoRoute(
            path: ':id',
            builder: (_, GoRouterState state) =>
                SurveyDetailScreen(surveyId: state.pathParameters['id']!),
          ),
        ],
      ),
      GoRoute(
        path: '/forms',
        builder: (_, _) => const FormsScreen(),
        routes: <RouteBase>[
          GoRoute(
            path: ':id',
            builder: (_, GoRouterState state) =>
                FormDetailScreen(formId: state.pathParameters['id']!),
          ),
        ],
      ),
      GoRoute(path: '/pharmacies', builder: (_, _) => const PharmaciesScreen()),
      GoRoute(
        path: '/businesses',
        builder: (_, _) => const BusinessesScreen(),
        routes: <RouteBase>[
          GoRoute(
            path: ':id',
            builder: (_, GoRouterState state) =>
                BusinessDetailScreen(businessId: state.pathParameters['id']!),
          ),
        ],
      ),
      GoRoute(
        path: '/facilities',
        builder: (_, _) => const FacilitiesScreen(),
        routes: <RouteBase>[
          GoRoute(
            path: ':id',
            builder: (_, GoRouterState state) =>
                FacilityDetailScreen(facilityId: state.pathParameters['id']!),
          ),
        ],
      ),
      GoRoute(
        path: '/reservations',
        builder: (_, _) => const MyReservationsScreen(),
      ),
      GoRoute(
        path: '/pdf',
        builder: (BuildContext context, GoRouterState state) {
          final Object? attachment = state.extra;
          if (attachment is! NewsAttachment) {
            return const PdfAttachmentUnavailableScreen();
          }
          return PdfAttachmentScreen(attachment: attachment);
        },
      ),
      StatefulShellRoute.indexedStack(
        builder:
            (
              BuildContext context,
              GoRouterState state,
              StatefulNavigationShell navigationShell,
            ) => AppShell(navigationShell: navigationShell),
        branches: <StatefulShellBranch>[
          StatefulShellBranch(
            routes: <RouteBase>[
              GoRoute(path: '/', builder: (_, _) => const HomeScreen()),
            ],
          ),
          StatefulShellBranch(
            routes: <RouteBase>[
              GoRoute(
                path: '/news',
                builder: (_, _) => const NewsScreen(),
                routes: <RouteBase>[
                  GoRoute(
                    path: ':id',
                    builder: (_, GoRouterState state) =>
                        NewsDetailScreen(newsId: state.pathParameters['id']!),
                  ),
                ],
              ),
            ],
          ),
          StatefulShellBranch(
            routes: <RouteBase>[
              GoRoute(
                path: '/events',
                builder: (_, _) => const EventsScreen(),
                routes: <RouteBase>[
                  GoRoute(
                    path: ':id',
                    builder: (_, GoRouterState state) =>
                        EventDetailScreen(eventId: state.pathParameters['id']!),
                  ),
                ],
              ),
            ],
          ),
          StatefulShellBranch(
            routes: <RouteBase>[
              GoRoute(
                path: '/alerts',
                builder: (_, _) => const AlertsScreen(),
                routes: <RouteBase>[
                  GoRoute(
                    path: ':id',
                    builder: (_, GoRouterState state) =>
                        AlertDetailScreen(alertId: state.pathParameters['id']!),
                  ),
                ],
              ),
            ],
          ),
          StatefulShellBranch(
            routes: <RouteBase>[
              GoRoute(path: '/more', builder: (_, _) => const SettingsScreen()),
            ],
          ),
        ],
      ),
    ],
  );
}
