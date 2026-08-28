import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:poblex_design_system/poblex_design_system.dart';

import '../../../../core/errors/failure.dart';
import '../../../../core/l10n/app_locales.dart';
import '../../../../core/session/session_state.dart';
import '../../../../core/session/session_view_model.dart';
import '../../../../l10n/app_localizations.dart';
import '../../../../shared/presentation/failure_view.dart';
import '../../domain/entities/news_item.dart';
import '../../../../shared/domain/value_objects/localized_text.dart';
import '../viewmodels/news_detail_view_model.dart';
import '../widgets/news_card.dart';
import '../widgets/news_detail_skeleton.dart';

class NewsDetailScreen extends ConsumerWidget {
  const NewsDetailScreen({required this.newsId, super.key});
  final String newsId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final AppLocalizations l10n = AppLocalizations.of(context);
    final AsyncValue<NewsDetailUiState> detail = ref.watch(
      newsDetailViewModelProvider(newsId),
    );
    return Scaffold(
      appBar: AppBar(title: Text(l10n.newsDetailTitle)),
      body: detail.when(
        loading: () => const NewsDetailSkeleton(),
        error: (_, _) => FailureView(
          failure: const UnknownFailure(),
          sectionName: l10n.sectionNews,
          onRetry: () =>
              ref.read(newsDetailViewModelProvider(newsId).notifier).retry(),
        ),
        data: (NewsDetailUiState value) {
          if (value.failure != null) {
            return FailureView(
              failure: value.failure!,
              sectionName: l10n.sectionNews,
              onRetry: () => ref
                  .read(newsDetailViewModelProvider(newsId).notifier)
                  .retry(),
            );
          }
          return _NewsDetail(item: value.item!);
        },
      ),
    );
  }
}

class _NewsDetail extends ConsumerWidget {
  const _NewsDetail({required this.item});
  final NewsItem item;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final AppLocalizations l10n = AppLocalizations.of(context);
    final AppLocale? locale = ref.watch(
      sessionViewModelProvider.select(
        (AsyncValue<SessionState> value) => value.value?.locale,
      ),
    );
    if (locale == null) return const NewsDetailSkeleton();
    final ResolvedLocalizedText title = item.title.resolve(locale);
    final ResolvedLocalizedText body = item.body.resolve(locale);
    final String date = DateFormat.yMMMMd(
      Localizations.localeOf(context).toLanguageTag(),
    ).format(item.publishedAt.toLocal());

    return SelectionArea(
      child: ListView(
        padding: const EdgeInsets.only(bottom: AppSpacing.xxl),
        children: <Widget>[
          if (item.imageUrl != null)
            Semantics(
              image: true,
              label: l10n.newsImageSemantic(title.text),
              child: CachedNetworkImage(
                imageUrl: item.imageUrl!,
                height: 260,
                fit: BoxFit.cover,
                errorWidget: (_, _, _) => const SizedBox.shrink(),
              ),
            ),
          Center(
            child: ConstrainedBox(
              constraints: BoxConstraints(maxWidth: AppSize.maxContentWidth),
              child: Padding(
                padding: const EdgeInsets.all(AppSpacing.xl),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Wrap(
                      spacing: AppSpacing.xs,
                      runSpacing: AppSpacing.xs,
                      children: <Widget>[
                        Chip(
                          label: Text(localizedCategory(l10n, item.category)),
                        ),
                        if (item.pinned)
                          Chip(label: Text(l10n.newsPinnedLabel)),
                        if (title.isFallback)
                          Chip(label: Text(fallbackNotice(l10n, title))),
                      ],
                    ),
                    const SizedBox(height: AppSpacing.md),
                    Semantics(
                      header: true,
                      child: Text(
                        title.text,
                        style: Theme.of(context).textTheme.headlineLarge,
                      ),
                    ),
                    const SizedBox(height: AppSpacing.xs),
                    Text(date),
                    const SizedBox(height: AppSpacing.xl),
                    Text(
                      body.text,
                      style: Theme.of(context).textTheme.bodyLarge,
                    ),
                    if (body.isFallback && !title.isFallback) ...<Widget>[
                      const SizedBox(height: AppSpacing.sm),
                      Chip(label: Text(fallbackNotice(l10n, body))),
                    ],
                    if (item.attachments.isNotEmpty) ...<Widget>[
                      const SizedBox(height: AppSpacing.xxl),
                      Semantics(
                        header: true,
                        child: Text(
                          l10n.newsDetailAttachmentsHeading,
                          style: Theme.of(context).textTheme.headlineSmall,
                        ),
                      ),
                      const SizedBox(height: AppSpacing.xs),
                      for (final NewsAttachment attachment in item.attachments)
                        _AttachmentTile(
                          attachment: attachment,
                          semanticLabel: l10n.newsOpenAttachment(
                            attachment.name,
                          ),
                        ),
                    ],
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

class _AttachmentTile extends StatelessWidget {
  const _AttachmentTile({
    required this.attachment,
    required this.semanticLabel,
  });

  final NewsAttachment attachment;
  final String semanticLabel;

  @override
  Widget build(BuildContext context) {
    final bool isPdf = attachment.mimeType == 'application/pdf';

    // One grouped node instead of the leading icon, the title and the
    // trailing chevron being read out as three separate items (A-27).
    return Semantics(
      button: isPdf,
      label: semanticLabel,
      excludeSemantics: true,
      child: ListTile(
        minTileHeight: AppSize.comfortableTouchTarget,
        contentPadding: EdgeInsets.zero,
        leading: const Icon(Icons.picture_as_pdf_outlined),
        title: Text(attachment.name),
        trailing: const Icon(Icons.chevron_right),
        onTap: isPdf ? () => context.push('/pdf', extra: attachment) : null,
      ),
    );
  }
}
