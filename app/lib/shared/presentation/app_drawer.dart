import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:poblex_design_system/poblex_design_system.dart';

import '../../l10n/app_localizations.dart';

class _DrawerSection {
  const _DrawerSection({
    required this.icon,
    required this.label,
    required this.path,
  });

  final IconData icon;
  final String label;
  final String path;
}

/// Reachable from every screen inside [AppShell]: the single navigation
/// surface for the whole app, which is what keeps every section at one tap
/// from anywhere (A-33).
class AppDrawer extends StatelessWidget {
  const AppDrawer({super.key});

  @override
  Widget build(BuildContext context) {
    final AppLocalizations l10n = AppLocalizations.of(context);
    // Every AppDrawer call site is a route built directly by GoRoute (the
    // shell branches and the standalone /incidents, /surveys, /forms,
    // /pharmacies, /businesses, /facilities routes), so the matched path is
    // always one of the exact section paths below.
    final String currentPath = GoRouterState.of(context).uri.path;
    final List<_DrawerSection> sections = <_DrawerSection>[
      _DrawerSection(icon: Icons.home_outlined, label: l10n.navHome, path: '/'),
      _DrawerSection(
        icon: Icons.newspaper_outlined,
        label: l10n.sectionNews,
        path: '/news',
      ),
      _DrawerSection(
        icon: Icons.event_outlined,
        label: l10n.sectionEvents,
        path: '/events',
      ),
      _DrawerSection(
        icon: Icons.warning_amber_outlined,
        label: l10n.sectionAlerts,
        path: '/alerts',
      ),
      _DrawerSection(
        icon: Icons.report_problem_outlined,
        label: l10n.sectionIncidents,
        path: '/incidents',
      ),
      _DrawerSection(
        icon: Icons.poll_outlined,
        label: l10n.sectionSurveys,
        path: '/surveys',
      ),
      _DrawerSection(
        icon: Icons.description_outlined,
        label: l10n.sectionForms,
        path: '/forms',
      ),
      _DrawerSection(
        icon: Icons.local_pharmacy_outlined,
        label: l10n.sectionPharmacies,
        path: '/pharmacies',
      ),
      _DrawerSection(
        icon: Icons.storefront_outlined,
        label: l10n.sectionBusinesses,
        path: '/businesses',
      ),
      _DrawerSection(
        icon: Icons.stadium_outlined,
        label: l10n.sectionFacilities,
        path: '/facilities',
      ),
    ];

    final ColorScheme scheme = Theme.of(context).colorScheme;
    return Drawer(
      semanticLabel: l10n.drawerTitle,
      child: SafeArea(
        child: ListView(
          padding: EdgeInsets.zero,
          children: <Widget>[
            Padding(
              padding: const EdgeInsets.fromLTRB(
                AppSpacing.md,
                AppSpacing.xl,
                AppSpacing.md,
                AppSpacing.md,
              ),
              child: Semantics(
                header: true,
                child: Row(
                  children: <Widget>[
                    PoblexMark(size: 32, color: scheme.primary),
                    const SizedBox(width: AppSpacing.xs),
                    Text(
                      l10n.drawerTitle,
                      style: Theme.of(context).textTheme.headlineSmall
                          ?.copyWith(color: scheme.primary),
                    ),
                  ],
                ),
              ),
            ),
            for (final _DrawerSection section in sections)
              _DrawerTile(
                section: section,
                selected: section.path == currentPath,
              ),
            const Divider(),
            _DrawerTile(
              section: _DrawerSection(
                icon: Icons.settings_outlined,
                label: l10n.sectionSettings,
                path: '/more',
              ),
              selected: currentPath == '/more',
            ),
          ],
        ),
      ),
    );
  }
}

/// Highlights the active section the way every Stitch reference screen
/// highlights its current nav item (`bg-primary-container`,
/// `text-on-primary-container`, bold) instead of leaving all rows identical.
class _DrawerTile extends StatelessWidget {
  const _DrawerTile({required this.section, required this.selected});

  final _DrawerSection section;
  final bool selected;

  @override
  Widget build(BuildContext context) {
    final ColorScheme scheme = Theme.of(context).colorScheme;
    final Color? tileColor = selected ? scheme.primaryContainer : null;
    final Color? contentColor = selected ? scheme.onPrimaryContainer : null;
    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.xs,
        vertical: AppSpacing.xxs,
      ),
      child: ListTile(
        shape: RoundedRectangleBorder(borderRadius: AppRadius.mdAll),
        tileColor: tileColor,
        leading: Icon(section.icon, color: contentColor),
        title: Text(
          section.label,
          style: selected ? const TextStyle(fontWeight: FontWeight.w700) : null,
        ),
        textColor: contentColor,
        selected: selected,
        onTap: () {
          Navigator.of(context).pop();
          context.go(section.path);
        },
      ),
    );
  }
}
