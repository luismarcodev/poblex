import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:poblex_design_system/poblex_design_system.dart';

import '../../features/auth/domain/entities/manager_profile.dart';
import '../../features/auth/presentation/viewmodels/auth_view_model.dart';
import '../../features/auth/presentation/viewmodels/municipality_view_model.dart';
import '../../l10n/app_localizations.dart';

class BackofficeShell extends ConsumerWidget {
  const BackofficeShell({
    required this.child,
    this.location = '/noticias',
    super.key,
  });
  final Widget child;
  final String location;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final auth = ref.watch(
      authViewModelProvider.select(
        (value) => (profile: value.valueOrNull, loading: value.isLoading),
      ),
    );
    final profile = auth.profile;
    if (profile == null) {
      return Scaffold(
        body: Center(
          child: Semantics(
            liveRegion: true,
            label: l10n.loading,
            child: auth.loading
                ? const CircularProgressIndicator()
                : const SizedBox.shrink(),
          ),
        ),
      );
    }
    if (profile.municipalities.isEmpty) {
      return Scaffold(
        body: SafeArea(
          child: SingleChildScrollView(
            padding: AppSpacing.screenPadding,
            child: Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(
                  maxWidth: AppSize.maxContentWidth,
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.location_off_outlined, size: 56),
                    const SizedBox(height: AppSpacing.md),
                    Text(
                      l10n.managerWithoutMunicipalities,
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: AppSpacing.xl),
                    FilledButton(
                      onPressed: () =>
                          ref.read(authViewModelProvider.notifier).logout(),
                      child: Text(l10n.logout),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      );
    }

    final municipality = ref.watch(selectedMunicipalityProvider);
    final brand = resolveBrandPalette(municipality.primaryColor);
    final brightness = Theme.of(context).brightness;
    final theme = brightness == Brightness.dark
        ? AppTheme.dark(brand: brand)
        : AppTheme.light(brand: brand);

    return Theme(
      data: theme,
      child: LayoutBuilder(
        builder: (context, constraints) {
          if (constraints.maxWidth >= AppBreakpoints.compact) {
            return _WideShell(
              profile: profile,
              municipality: municipality,
              location: location,
              child: child,
            );
          }
          return _CompactShell(
            profile: profile,
            municipality: municipality,
            location: location,
            child: child,
          );
        },
      ),
    );
  }
}

int _selectedSectionIndex(String location) {
  if (location.startsWith('/eventos')) return 1;
  if (location.startsWith('/alertas')) return 2;
  if (location.startsWith('/incidencias')) return 3;
  if (location.startsWith('/encuestas')) return 4;
  if (location.startsWith('/formularios')) return 5;
  if (location.startsWith('/farmacias')) return 6;
  if (location.startsWith('/comercios')) return 7;
  if (location.startsWith('/instalaciones')) return 8;
  return 0;
}

void _goToSection(BuildContext context, int index) {
  context.go(switch (index) {
    1 => '/eventos',
    2 => '/alertas',
    3 => '/incidencias',
    4 => '/encuestas',
    5 => '/formularios',
    6 => '/farmacias',
    7 => '/comercios',
    8 => '/instalaciones',
    _ => '/noticias',
  });
}

String _sectionTitle(BuildContext context, String location) {
  final l10n = AppLocalizations.of(context);
  return switch (_selectedSectionIndex(location)) {
    1 => l10n.eventsTitle,
    2 => l10n.alertsTitle,
    3 => l10n.incidentsTitle,
    4 => l10n.surveysTitle,
    5 => l10n.formsTitle,
    6 => l10n.pharmaciesTitle,
    7 => l10n.businessesTitle,
    8 => l10n.facilitiesTitle,
    _ => l10n.newsTitle,
  };
}

class _WideShell extends ConsumerWidget {
  const _WideShell({
    required this.profile,
    required this.municipality,
    required this.location,
    required this.child,
  });
  final ManagerProfile profile;
  final ManagedMunicipality municipality;
  final String location;
  final Widget child;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    return Scaffold(
      body: Row(
        children: [
          SizedBox(
            width: AppSize.navigationRailWidth,
            child: Material(
              color: context.colors.surface,
              child: SafeArea(
                child: LayoutBuilder(
                  builder: (context, constraints) => SingleChildScrollView(
                    child: ConstrainedBox(
                      constraints: BoxConstraints(
                        minHeight: constraints.maxHeight,
                      ),
                      child: IntrinsicHeight(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            Padding(
                              padding: const EdgeInsets.all(AppSpacing.xl),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    l10n.appName,
                                    style: context.text.headlineSmall,
                                  ),
                                  Text(
                                    l10n.backofficeTitle,
                                    style: context.text.bodyMedium?.copyWith(
                                      color: context.semantic.textMuted,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.symmetric(
                                horizontal: AppSpacing.md,
                              ),
                              child: _MunicipalitySelector(
                                profile: profile,
                                selected: municipality,
                              ),
                            ),
                            const SizedBox(height: AppSpacing.xl),
                            Expanded(
                              child: NavigationRail(
                                extended: true,
                                selectedIndex: _selectedSectionIndex(location),
                                onDestinationSelected: (index) =>
                                    _goToSection(context, index),
                                destinations: [
                                  NavigationRailDestination(
                                    icon: const Icon(Icons.newspaper_outlined),
                                    selectedIcon: const Icon(Icons.newspaper),
                                    label: Text(l10n.newsTitle),
                                  ),
                                  NavigationRailDestination(
                                    icon: const Icon(Icons.event_outlined),
                                    selectedIcon: const Icon(Icons.event),
                                    label: Text(l10n.eventsTitle),
                                  ),
                                  NavigationRailDestination(
                                    icon: const Icon(
                                      Icons.notification_important_outlined,
                                    ),
                                    selectedIcon: const Icon(
                                      Icons.notification_important,
                                    ),
                                    label: Text(l10n.alertsTitle),
                                  ),
                                  NavigationRailDestination(
                                    icon: const Icon(Icons.report_outlined),
                                    selectedIcon: const Icon(Icons.report),
                                    label: Text(l10n.incidentsTitle),
                                  ),
                                  NavigationRailDestination(
                                    icon: const Icon(Icons.poll_outlined),
                                    selectedIcon: const Icon(Icons.poll),
                                    label: Text(l10n.surveysTitle),
                                  ),
                                  NavigationRailDestination(
                                    icon: const Icon(
                                      Icons.description_outlined,
                                    ),
                                    selectedIcon: const Icon(Icons.description),
                                    label: Text(l10n.formsTitle),
                                  ),
                                  NavigationRailDestination(
                                    icon: const Icon(
                                      Icons.local_pharmacy_outlined,
                                    ),
                                    selectedIcon: const Icon(
                                      Icons.local_pharmacy,
                                    ),
                                    label: Text(l10n.pharmaciesTitle),
                                  ),
                                  NavigationRailDestination(
                                    icon: const Icon(Icons.storefront_outlined),
                                    selectedIcon: const Icon(Icons.storefront),
                                    label: Text(l10n.businessesTitle),
                                  ),
                                  NavigationRailDestination(
                                    icon: const Icon(Icons.stadium_outlined),
                                    selectedIcon: const Icon(Icons.stadium),
                                    label: Text(l10n.facilitiesTitle),
                                  ),
                                ],
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.all(AppSpacing.md),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.stretch,
                                children: [
                                  Text(
                                    profile.displayName,
                                    maxLines: 2,
                                    overflow: TextOverflow.ellipsis,
                                    style: context.text.titleSmall,
                                  ),
                                  Text(
                                    profile.email,
                                    maxLines: 2,
                                    overflow: TextOverflow.ellipsis,
                                    style: context.text.bodySmall,
                                  ),
                                  const SizedBox(height: AppSpacing.sm),
                                  OutlinedButton.icon(
                                    onPressed: () => ref
                                        .read(authViewModelProvider.notifier)
                                        .logout(),
                                    icon: const Icon(Icons.logout),
                                    label: Text(l10n.logout),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
          const VerticalDivider(width: 1),
          Expanded(child: child),
        ],
      ),
    );
  }
}

class _CompactShell extends ConsumerWidget {
  const _CompactShell({
    required this.profile,
    required this.municipality,
    required this.location,
    required this.child,
  });
  final ManagerProfile profile;
  final ManagedMunicipality municipality;
  final String location;
  final Widget child;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    return Scaffold(
      drawer: NavigationDrawer(
        selectedIndex: _selectedSectionIndex(location),
        onDestinationSelected: (index) {
          Navigator.of(context).pop();
          _goToSection(context, index);
        },
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(
              AppSpacing.xl,
              AppSpacing.xl,
              AppSpacing.xl,
              AppSpacing.md,
            ),
            child: Text(l10n.backofficeTitle, style: context.text.titleLarge),
          ),
          NavigationDrawerDestination(
            icon: const Icon(Icons.newspaper_outlined),
            selectedIcon: const Icon(Icons.newspaper),
            label: Text(l10n.newsTitle),
          ),
          NavigationDrawerDestination(
            icon: const Icon(Icons.event_outlined),
            selectedIcon: const Icon(Icons.event),
            label: Text(l10n.eventsTitle),
          ),
          NavigationDrawerDestination(
            icon: const Icon(Icons.notification_important_outlined),
            selectedIcon: const Icon(Icons.notification_important),
            label: Text(l10n.alertsTitle),
          ),
          NavigationDrawerDestination(
            icon: const Icon(Icons.report_outlined),
            selectedIcon: const Icon(Icons.report),
            label: Text(l10n.incidentsTitle),
          ),
          NavigationDrawerDestination(
            icon: const Icon(Icons.poll_outlined),
            selectedIcon: const Icon(Icons.poll),
            label: Text(l10n.surveysTitle),
          ),
          NavigationDrawerDestination(
            icon: const Icon(Icons.description_outlined),
            selectedIcon: const Icon(Icons.description),
            label: Text(l10n.formsTitle),
          ),
          NavigationDrawerDestination(
            icon: const Icon(Icons.local_pharmacy_outlined),
            selectedIcon: const Icon(Icons.local_pharmacy),
            label: Text(l10n.pharmaciesTitle),
          ),
          NavigationDrawerDestination(
            icon: const Icon(Icons.storefront_outlined),
            selectedIcon: const Icon(Icons.storefront),
            label: Text(l10n.businessesTitle),
          ),
          NavigationDrawerDestination(
            icon: const Icon(Icons.stadium_outlined),
            selectedIcon: const Icon(Icons.stadium),
            label: Text(l10n.facilitiesTitle),
          ),
        ],
      ),
      appBar: AppBar(
        title: Text(_sectionTitle(context, location)),
        actions: [
          IconButton(
            onPressed: () => ref.read(authViewModelProvider.notifier).logout(),
            tooltip: l10n.logout,
            icon: const Icon(Icons.logout),
          ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(
              AppSpacing.md,
              0,
              AppSpacing.md,
              AppSpacing.xs,
            ),
            child: _MunicipalitySelector(
              profile: profile,
              selected: municipality,
            ),
          ),
          Expanded(child: child),
        ],
      ),
    );
  }
}

class _MunicipalitySelector extends ConsumerWidget {
  const _MunicipalitySelector({required this.profile, required this.selected});
  final ManagerProfile profile;
  final ManagedMunicipality selected;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    return DropdownButtonFormField<String>(
      initialValue: selected.id,
      isExpanded: true,
      decoration: InputDecoration(
        labelText: l10n.municipalityLabel,
        prefixIcon: const Icon(Icons.location_on_outlined),
      ),
      items: profile.municipalities
          .map(
            (municipality) => DropdownMenuItem(
              value: municipality.id,
              child: Text(municipality.name, overflow: TextOverflow.ellipsis),
            ),
          )
          .toList(growable: false),
      onChanged: (id) {
        if (id == null) return;
        final municipality = profile.municipalities.firstWhere(
          (value) => value.id == id,
        );
        ref.read(selectedMunicipalityProvider.notifier).select(municipality);
      },
    );
  }
}
