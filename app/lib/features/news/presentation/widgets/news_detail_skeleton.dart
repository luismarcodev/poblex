import 'package:flutter/material.dart';
import 'package:poblex_design_system/poblex_design_system.dart';

import '../../../../l10n/app_localizations.dart';
import '../../../../shared/presentation/widgets/app_skeleton.dart';

/// Loading state of the detail screen, shaped like [_NewsDetail]: hero image,
/// category chip, a title spanning two lines, and a few body lines — so
/// nothing jumps once the real article replaces it (§8.9).
class NewsDetailSkeleton extends StatelessWidget {
  const NewsDetailSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    final AppLocalizations l10n = AppLocalizations.of(context);
    return Semantics(
      label: l10n.loadingNews,
      liveRegion: true,
      child: ListView(
        padding: EdgeInsets.zero,
        children: <Widget>[
          const AppSkeleton(height: 260, borderRadius: BorderRadius.zero),
          Center(
            child: ConstrainedBox(
              constraints: BoxConstraints(maxWidth: AppSize.maxContentWidth),
              child: Padding(
                padding: const EdgeInsets.all(AppSpacing.xl),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    AppSkeleton(
                      width: 96,
                      height: 32,
                      borderRadius: AppRadius.pillAll,
                    ),
                    const SizedBox(height: AppSpacing.md),
                    const AppSkeleton(width: double.infinity, height: 30),
                    const SizedBox(height: AppSpacing.xxs),
                    const AppSkeleton(width: 220, height: 30),
                    const SizedBox(height: AppSpacing.xl),
                    const AppSkeleton(width: double.infinity, height: 18),
                    const SizedBox(height: AppSpacing.xxs),
                    const AppSkeleton(width: double.infinity, height: 18),
                    const SizedBox(height: AppSpacing.xxs),
                    const AppSkeleton(width: 260, height: 18),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
