import 'package:flutter/material.dart';
import 'package:poblex_design_system/poblex_design_system.dart';

import '../../../../l10n/app_localizations.dart';
import '../../../../shared/presentation/widgets/app_skeleton.dart';

/// Placeholder with the exact geometry of [NewsCard] — same image height,
/// same padding, same chip/title/date rhythm — so the layout does not jump
/// once the real content arrives (design-system.md §8.9).
class NewsCardSkeleton extends StatelessWidget {
  const NewsCardSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    return Card(
      clipBehavior: Clip.antiAlias,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          const AppSkeleton(height: 180, borderRadius: BorderRadius.zero),
          Padding(
            padding: AppSpacing.cardPadding,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                AppSkeleton(
                  width: 96,
                  height: 32,
                  borderRadius: AppRadius.pillAll,
                ),
                const SizedBox(height: AppSpacing.sm),
                const AppSkeleton(width: double.infinity, height: 22),
                const SizedBox(height: AppSpacing.xxs),
                const AppSkeleton(width: 200, height: 22),
                const SizedBox(height: AppSpacing.xs),
                const AppSkeleton(width: 120, height: 14),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// Loading state of the news list: a handful of [NewsCardSkeleton]s under a
/// single semantics announcement, so a screen reader says "Cargando
/// noticias" once instead of narrating each placeholder block (A-31).
class NewsListSkeleton extends StatelessWidget {
  const NewsListSkeleton({super.key});

  static const int _placeholderCount = 3;

  @override
  Widget build(BuildContext context) {
    final AppLocalizations l10n = AppLocalizations.of(context);
    return Semantics(
      label: l10n.loadingNews,
      liveRegion: true,
      child: ListView.separated(
        padding: const EdgeInsets.fromLTRB(
          AppSpacing.md,
          AppSpacing.xs,
          AppSpacing.md,
          AppSpacing.xxl,
        ),
        itemCount: _placeholderCount,
        separatorBuilder: (BuildContext context, int index) =>
            const SizedBox(height: AppSpacing.sm),
        itemBuilder: (BuildContext context, int index) =>
            const NewsCardSkeleton(),
      ),
    );
  }
}
