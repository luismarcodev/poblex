import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:poblex_design_system/poblex_design_system.dart';

import '../../../../core/l10n/app_locales.dart';
import '../../../../l10n/app_localizations.dart';
import '../../../../shared/domain/value_objects/localized_text.dart';
import '../../domain/entities/event.dart';

class EventCard extends StatelessWidget {
  const EventCard({
    required this.event,
    required this.locale,
    required this.hasReminder,
    required this.onTap,
    required this.onToggleReminder,
    super.key,
  });

  final MunicipalEvent event;
  final AppLocale locale;
  final bool hasReminder;
  final VoidCallback onTap;
  final VoidCallback onToggleReminder;

  @override
  Widget build(BuildContext context) {
    final AppLocalizations l10n = AppLocalizations.of(context);
    final ResolvedLocalizedText title = event.title.resolve(locale);
    final bool isPast = event.isPastAt(DateTime.now());
    final String languageTag = Localizations.localeOf(context).toLanguageTag();
    final String time = DateFormat.Hm(
      languageTag,
    ).format(event.startAt.toLocal());
    final String fullDate = DateFormat.yMMMMEEEEd(
      languageTag,
    ).format(event.startAt.toLocal());

    final String cardSemanticLabel = <String>[
      title.text,
      fullDate,
      time,
      if (event.locationName != null)
        l10n.eventLocationSemantic(event.locationName!),
      if (isPast) l10n.eventPastLabel,
    ].join('. ');
    final String reminderSemanticLabel = l10n.eventReminderSemantic(
      hasReminder.toString(),
      title.text,
    );

    return Card(
      clipBehavior: Clip.antiAlias,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Semantics(
            button: true,
            excludeSemantics: true,
            label: cardSemanticLabel,
            child: InkWell(
              onTap: onTap,
              child: Padding(
                padding: const EdgeInsets.fromLTRB(
                  AppSpacing.md,
                  AppSpacing.md,
                  AppSpacing.md,
                  AppSpacing.xs,
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    _DateBadge(
                      startAt: event.startAt,
                      languageTag: languageTag,
                    ),
                    const SizedBox(width: AppSpacing.md),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          if (isPast)
                            Padding(
                              padding: const EdgeInsets.only(
                                bottom: AppSpacing.xxs,
                              ),
                              child: Chip(
                                label: Text(l10n.eventPastLabel),
                                visualDensity: VisualDensity.compact,
                              ),
                            ),
                          Text(
                            title.text,
                            style: Theme.of(context).textTheme.titleMedium,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: AppSpacing.xxs),
                          Row(
                            children: <Widget>[
                              const ExcludeSemantics(
                                child: Icon(
                                  Icons.schedule_outlined,
                                  size: AppSize.iconSm,
                                ),
                              ),
                              const SizedBox(width: AppSpacing.xxs),
                              Text(time),
                            ],
                          ),
                          if (event.locationName != null) ...<Widget>[
                            const SizedBox(height: AppSpacing.xxs),
                            Row(
                              children: <Widget>[
                                const ExcludeSemantics(
                                  child: Icon(
                                    Icons.place_outlined,
                                    size: AppSize.iconSm,
                                  ),
                                ),
                                const SizedBox(width: AppSpacing.xxs),
                                Expanded(
                                  child: Text(
                                    event.locationName!,
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          // A visible button, never a swipe-only action (A-21). Kept
          // outside the card's excludeSemantics tree above so a screen
          // reader can reach it as its own control, not just as text
          // folded into the card's combined label.
          Padding(
            padding: const EdgeInsets.fromLTRB(
              AppSpacing.md,
              0,
              AppSpacing.md,
              AppSpacing.md,
            ),
            child: Align(
              alignment: Alignment.centerLeft,
              child: Semantics(
                button: true,
                excludeSemantics: true,
                label: reminderSemanticLabel,
                child: OutlinedButton.icon(
                  onPressed: onToggleReminder,
                  icon: Icon(
                    hasReminder
                        ? Icons.notifications_active
                        : Icons.notifications_none_outlined,
                  ),
                  label: Text(
                    hasReminder
                        ? l10n.eventReminderActive
                        : l10n.eventReminderSet,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _DateBadge extends StatelessWidget {
  const _DateBadge({required this.startAt, required this.languageTag});

  final DateTime startAt;
  final String languageTag;

  @override
  Widget build(BuildContext context) {
    final ColorScheme colors = Theme.of(context).colorScheme;
    final DateTime local = startAt.toLocal();
    return ExcludeSemantics(
      child: Container(
        width: 64,
        padding: const EdgeInsets.symmetric(vertical: AppSpacing.xs),
        decoration: BoxDecoration(
          color: colors.secondaryContainer,
          borderRadius: AppRadius.mdAll,
        ),
        child: Column(
          children: <Widget>[
            Text(
              DateFormat.d(languageTag).format(local),
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                color: colors.onSecondaryContainer,
              ),
              textAlign: TextAlign.center,
            ),
            Text(
              DateFormat.MMM(languageTag).format(local),
              style: Theme.of(context).textTheme.labelMedium?.copyWith(
                color: colors.onSecondaryContainer,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
