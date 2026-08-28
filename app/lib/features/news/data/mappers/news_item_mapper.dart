import '../../domain/entities/news_item.dart';
import '../../../../shared/domain/value_objects/localized_text.dart';
import '../models/news_item_model.dart';

abstract final class NewsItemMapper {
  static NewsItem toDomain(NewsItemModel model) => NewsItem(
    id: model.id,
    municipalityId: model.municipalityId,
    title: LocalizedText(es: model.title.es, va: model.title.va),
    body: LocalizedText(es: model.body.es, va: model.body.va),
    imageUrl: model.imageUrl,
    category: model.category,
    pinned: model.pinned,
    publishedAt: model.publishedAt,
    archived: model.archived,
    attachments: model.attachments
        .map(
          (NewsAttachmentModel item) => NewsAttachment(
            id: item.id,
            name: item.name,
            url: item.url,
            mimeType: item.mimeType,
          ),
        )
        .toList(growable: false),
  );
}
