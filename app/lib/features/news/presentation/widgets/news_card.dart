import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:poblex_design_system/poblex_design_system.dart';

import '../../../../core/l10n/app_locales.dart';
import '../../../../l10n/app_localizations.dart';
import '../../domain/entities/news_item.dart';
import '../../../../shared/domain/value_objects/localized_text.dart';
import '../../../../shared/presentation/category_label.dart';

class NewsCard extends StatelessWidget {
  const NewsCard({
    required this.item,
    required this.locale,
    required this.onTap,
    super.key,
  });

  final NewsItem item;
  final AppLocale locale;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final AppLocalizations l10n = AppLocalizations.of(context);
    final ResolvedLocalizedText title = item.title.resolve(locale);
    final String category = localizedCategory(l10n, item.category);
    final String date = DateFormat.yMMMd(
      Localizations.localeOf(context).toLanguageTag(),
    ).format(item.publishedAt.toLocal());

    return Semantics(
      button: true,
      excludeSemantics: true,
      label: l10n.newsSemanticCard(
        title.text,
        category,
        date,
        l10n.newsAttachmentsCount(item.attachments.length),
      ),
      child: Card(
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: onTap,
          child: Container(
            decoration: item.pinned
                ? BoxDecoration(
                    border: Border(
                      left: BorderSide(
                        color: context.semantic.brandGraphic,
                        width: 4,
                      ),
                    ),
                  )
                : null,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: <Widget>[
                if (item.imageUrl != null)
                  Stack(
                    children: <Widget>[
                      ExcludeSemantics(
                        child: CachedNetworkImage(
                          imageUrl: item.imageUrl!,
                          height: 200,
                          width: double.infinity,
                          fit: BoxFit.cover,
                          errorWidget: (_, _, _) => const SizedBox.shrink(),
                        ),
                      ),
                      // Category badge floats over the photo, the way the
                      // Stitch reference cards do — the plain-text metadata
                      // row below still carries it too, so nothing is
                      // conveyed by the overlay alone (A-01).
                      Positioned(
                        left: AppSpacing.sm,
                        top: AppSpacing.sm,
                        child: ExcludeSemantics(
                          child: _PhotoBadge(label: category),
                        ),
                      ),
                    ],
                  ),
                Padding(
                  padding: AppSpacing.cardPadding,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      if (item.imageUrl == null || item.pinned)
                        Padding(
                          padding: const EdgeInsets.only(bottom: AppSpacing.xs),
                          child: Wrap(
                            spacing: AppSpacing.xs,
                            runSpacing: AppSpacing.xs,
                            children: <Widget>[
                              if (item.imageUrl == null)
                                Chip(label: Text(category)),
                              if (item.pinned)
                                Chip(
                                  avatar: const Icon(
                                    Icons.push_pin_outlined,
                                    size: AppSize.iconSm,
                                  ),
                                  label: Text(l10n.newsPinnedLabel),
                                ),
                            ],
                          ),
                        ),
                      if (title.isFallback)
                        Padding(
                          padding: const EdgeInsets.only(bottom: AppSpacing.xs),
                          child: Chip(label: Text(fallbackNotice(l10n, title))),
                        ),
                      Text(
                        title.text,
                        style: Theme.of(context).textTheme.titleLarge,
                      ),
                      const SizedBox(height: AppSpacing.xs),
                      Text(date, style: Theme.of(context).textTheme.bodySmall),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// The pill badge floated over a news photo. Deliberately plain surface +
/// text, never a severity colour: R1 forbids alert colours outside an alert
/// container, and a category badge is exactly the kind of unrelated chrome
/// that must never borrow that palette.
class _PhotoBadge extends StatelessWidget {
  const _PhotoBadge({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.sm,
        vertical: AppSpacing.xxs,
      ),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface.withValues(alpha: 0.92),
        borderRadius: AppRadius.pillAll,
      ),
      child: Text(label, style: Theme.of(context).textTheme.labelMedium),
    );
  }
}

String localizedCategory(AppLocalizations l10n, String category) =>
    switch (category) {
      'general' => l10n.categoryGeneral,
      'sanitaria' => l10n.categorySanitaria,
      'servicios' => l10n.categoryServicios,
      'cultural' => l10n.categoryCultural,
      'deportes' => l10n.categoryDeportes,
      'fiestas' => l10n.categoryFiestas,
      'obras' => l10n.categoryObras,
      _ => prettifyCategorySlug(category),
    };

String fallbackNotice(AppLocalizations l10n, ResolvedLocalizedText value) =>
    value.sourceLocale == AppLocale.es
    ? l10n.languageFallbackNotice
    : l10n.languageFallbackNoticeValencian;
