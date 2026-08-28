import '../../domain/entities/news_item.dart';

class NewsItemModel {
  const NewsItemModel(this.entity);
  final NewsItem entity;

  factory NewsItemModel.fromJson(Map<String, dynamic> json) {
    LocalizedText localized(Object? raw) {
      final value = raw as Map<String, dynamic>;
      return LocalizedText(
        es: value['es'] as String? ?? '',
        va: value['va'] as String?,
      );
    }

    final rawAttachments = json['attachments'] as List<dynamic>? ?? const [];
    return NewsItemModel(
      NewsItem(
        id: json['id'] as String,
        municipalityId: json['municipalityId'] as String,
        title: localized(json['title']),
        body: localized(json['body']),
        category: json['category'] as String,
        pinned: json['pinned'] as bool,
        publishedAt: DateTime.parse(json['publishedAt'] as String),
        archived: json['archived'] as bool,
        imageUrl: json['imageUrl'] as String?,
        attachments: rawAttachments
            .map((raw) {
              final value = raw as Map<String, dynamic>;
              return NewsAttachment(
                id: value['id'] as String,
                name: value['name'] as String,
                url: value['url'] as String,
                mimeType: value['mimeType'] as String,
              );
            })
            .toList(growable: false),
      ),
    );
  }
}
