import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:poblex_design_system/poblex_design_system.dart';

import '../../../../l10n/app_localizations.dart';
import '../../../../core/errors/failure.dart';
import '../../../../shared/presentation/failure_view.dart';
import '../../domain/entities/municipality.dart';
import '../viewmodels/municipalities_view_model.dart';

class MunicipalityOnboardingScreen extends ConsumerWidget {
  const MunicipalityOnboardingScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final AppLocalizations l10n = AppLocalizations.of(context);
    final AsyncValue<MunicipalitiesUiState> state = ref.watch(
      municipalitiesViewModelProvider,
    );

    return Scaffold(
      body: SafeArea(
        bottom: false,
        child: state.when(
          loading: () => Semantics(
            label: l10n.loading,
            child: const Center(child: CircularProgressIndicator()),
          ),
          error: (_, _) => FailureView(
            failure: const UnknownFailure(),
            sectionName: l10n.onboardingMunicipalityTitle,
            onRetry: () =>
                ref.read(municipalitiesViewModelProvider.notifier).retry(),
          ),
          data: (MunicipalitiesUiState value) {
            if (value.failure != null && value.items.isEmpty) {
              return FailureView(
                failure: value.failure!,
                sectionName: l10n.onboardingMunicipalityTitle,
                onRetry: () =>
                    ref.read(municipalitiesViewModelProvider.notifier).retry(),
              );
            }
            return _OnboardingContent(state: value);
          },
        ),
      ),
    );
  }
}

/// The municipality picker follows a neutral, locally rendered introduction.
class _OnboardingContent extends ConsumerStatefulWidget {
  const _OnboardingContent({required this.state});
  final MunicipalitiesUiState state;

  @override
  ConsumerState<_OnboardingContent> createState() => _OnboardingContentState();
}

class _OnboardingContentState extends ConsumerState<_OnboardingContent> {
  final TextEditingController _search = TextEditingController();
  String _query = '';

  @override
  void dispose() {
    _search.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final AppLocalizations l10n = AppLocalizations.of(context);
    final List<Municipality> filtered = _query.trim().isEmpty
        ? widget.state.items
        : widget.state.items
              .where(
                (Municipality m) =>
                    m.name.toLowerCase().contains(_query.trim().toLowerCase()),
              )
              .toList(growable: false);

    return ListView(
      padding: EdgeInsets.zero,
      children: <Widget>[
        const _OnboardingHero(),
        Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(
              maxWidth: AppSize.maxContentWidth,
            ),
            child: Padding(
              padding: const EdgeInsets.all(AppSpacing.xl),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Text(
                    l10n.onboardingMunicipalityTitle,
                    style: Theme.of(context).textTheme.headlineLarge,
                  ),
                  const SizedBox(height: AppSpacing.sm),
                  Text(l10n.onboardingMunicipalityBody),
                  const SizedBox(height: AppSpacing.lg),
                  TextField(
                    controller: _search,
                    onChanged: (String value) => setState(() => _query = value),
                    textInputAction: TextInputAction.search,
                    decoration: InputDecoration(
                      hintText: l10n.onboardingSearchHint,
                      prefixIcon: const Icon(Icons.search),
                      suffixIcon: _query.isEmpty
                          ? null
                          : IconButton(
                              icon: const Icon(Icons.clear),
                              tooltip: l10n.onboardingSearchClear,
                              onPressed: () => setState(() {
                                _search.clear();
                                _query = '';
                              }),
                            ),
                    ),
                  ),
                  const SizedBox(height: AppSpacing.lg),
                  if (widget.state.failure != null) ...<Widget>[
                    InlineFailureView(
                      failure: widget.state.failure!,
                      sectionName: l10n.onboardingMunicipalityTitle,
                      onRetry: () => ref
                          .read(municipalitiesViewModelProvider.notifier)
                          .retry(),
                    ),
                    const SizedBox(height: AppSpacing.sm),
                  ],
                  if (widget.state.items.isEmpty)
                    _EmptyMunicipalities(
                      onRetry: () => ref
                          .read(municipalitiesViewModelProvider.notifier)
                          .retry(),
                    )
                  else if (filtered.isEmpty)
                    Padding(
                      padding: const EdgeInsets.symmetric(
                        vertical: AppSpacing.xl,
                      ),
                      child: Text(
                        l10n.onboardingSearchNoResults(_query.trim()),
                        textAlign: TextAlign.center,
                      ),
                    )
                  else
                    for (final Municipality municipality in filtered)
                      Padding(
                        padding: const EdgeInsets.only(bottom: AppSpacing.sm),
                        child: _MunicipalityTile(
                          municipality: municipality,
                          busy: widget.state.selectingId == municipality.id,
                          enabled: widget.state.selectingId == null,
                        ),
                      ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _OnboardingHero extends StatelessWidget {
  const _OnboardingHero();

  @override
  Widget build(BuildContext context) {
    final AppLocalizations l10n = AppLocalizations.of(context);
    return ExcludeSemantics(
      child: Container(
        constraints: const BoxConstraints(minHeight: 220),
        color: AppPalette.neutral900,
        padding: const EdgeInsets.all(AppSpacing.lg),
        alignment: Alignment.bottomLeft,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            Row(
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                const PoblexMark(size: 32, color: Colors.white),
                const SizedBox(width: AppSpacing.xxs),
                Text(
                  l10n.appName,
                  style: Theme.of(
                    context,
                  ).textTheme.titleMedium?.copyWith(color: Colors.white),
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.xxs),
            Text(
              l10n.homeGreeting,
              style: Theme.of(
                context,
              ).textTheme.headlineMedium?.copyWith(color: Colors.white),
            ),
          ],
        ),
      ),
    );
  }
}

class _MunicipalityTile extends ConsumerWidget {
  const _MunicipalityTile({
    required this.municipality,
    required this.busy,
    required this.enabled,
  });

  final Municipality municipality;
  final bool busy;
  final bool enabled;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final AppLocalizations l10n = AppLocalizations.of(context);
    return Card(
      shape: const RoundedRectangleBorder(borderRadius: AppRadius.lgAll),
      child: MergeSemantics(
        child: ListTile(
          shape: const RoundedRectangleBorder(borderRadius: AppRadius.lgAll),
          minTileHeight: AppSize.comfortableTouchTarget,
          leading: municipality.logoUrl == null
              ? const AppIconBadge(icon: Icons.location_city_outlined)
              : Semantics(
                  image: true,
                  label: l10n.onboardingMunicipalitySemantic(municipality.name),
                  child: ClipOval(
                    child: CachedNetworkImage(
                      imageUrl: municipality.logoUrl!,
                      width: AppSize.iconIllustration,
                      height: AppSize.iconIllustration,
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
          title: Text(municipality.name),
          subtitle: Text(municipality.province),
          trailing: busy
              ? const SizedBox.square(
                  dimension: AppSize.iconMd,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              : const Icon(Icons.chevron_right),
          enabled: enabled,
          onTap: () => ref
              .read(municipalitiesViewModelProvider.notifier)
              .select(municipality),
        ),
      ),
    );
  }
}

class _EmptyMunicipalities extends StatelessWidget {
  const _EmptyMunicipalities({required this.onRetry});
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    final AppLocalizations l10n = AppLocalizations.of(context);
    return Column(
      children: <Widget>[
        Text(
          l10n.onboardingNoMunicipalitiesTitle,
          style: Theme.of(context).textTheme.headlineSmall,
        ),
        const SizedBox(height: AppSpacing.xs),
        Text(l10n.onboardingNoMunicipalitiesBody),
        const SizedBox(height: AppSpacing.md),
        FilledButton.icon(
          onPressed: onRetry,
          icon: const Icon(Icons.refresh),
          label: Text(l10n.errorRetry),
        ),
      ],
    );
  }
}
