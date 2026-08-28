import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:poblex_design_system/poblex_design_system.dart';

import '../../core/l10n/app_locales.dart';
import '../../core/session/session_state.dart';
import '../../core/session/session_view_model.dart';
import '../../l10n/app_localizations.dart';
import 'app_drawer.dart';

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final AppLocalizations l10n = AppLocalizations.of(context);
    final AppLocale locale =
        ref.watch(
          sessionViewModelProvider.select(
            (AsyncValue<SessionState> value) => value.value?.locale,
          ),
        ) ??
        AppLocale.es;
    return Scaffold(
      appBar: AppBar(title: Text(l10n.sectionSettings)),
      drawer: const AppDrawer(),
      body: ListView(
        padding: const EdgeInsets.all(AppSpacing.xl),
        children: <Widget>[
          Text(
            l10n.settingsLanguageTitle,
            style: Theme.of(context).textTheme.headlineSmall,
          ),
          const SizedBox(height: AppSpacing.xs),
          Text(l10n.settingsLanguageBody),
          const SizedBox(height: AppSpacing.md),
          // Two large list rows (§8.11), not a dropdown, and built from Wrap +
          // FilterChip rather than a SegmentedButton in a horizontal scroller:
          // the same reasoning as the news tabs — nothing may be clipped or
          // hidden off-screen at 200% text scale (§8.6, A-13).
          Wrap(
            spacing: AppSpacing.xs,
            runSpacing: AppSpacing.xs,
            children: <Widget>[
              _LanguageChip(
                label: l10n.languageSpanish,
                selected: locale == AppLocale.es,
                onTap: () => _changeLanguage(context, ref, AppLocale.es),
              ),
              _LanguageChip(
                label: l10n.languageValencian,
                selected: locale == AppLocale.va,
                onTap: () => _changeLanguage(context, ref, AppLocale.va),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Future<void> _changeLanguage(
    BuildContext context,
    WidgetRef ref,
    AppLocale locale,
  ) async {
    await ref.read(sessionViewModelProvider.notifier).setLocaleOverride(locale);
    if (!context.mounted) return;
    final AppLocalizations l10n = AppLocalizations.of(context);
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text(l10n.settingsLanguageChanged)));
  }
}

class _LanguageChip extends StatelessWidget {
  const _LanguageChip({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      selected: selected,
      inMutuallyExclusiveGroup: true,
      label: label,
      excludeSemantics: true,
      child: FilterChip(
        label: Text(label),
        selected: selected,
        onSelected: (_) {
          if (!selected) onTap();
        },
      ),
    );
  }
}
