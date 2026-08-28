import '../../../../shared/data/models/localized_text_model.dart';

class NewsAttachmentModel {
  const NewsAttachmentModel({
    required this.id,
    required this.name,
    required this.url,
    required this.mimeType,
  });
  final String id;
  final String name;
  final String url;
  final String mimeType;

  factory NewsAttachmentModel.fromJson(Map<String, dynamic> json) =>
      NewsAttachmentModel(
        id: json['id'] as String,
        name: json['name'] as String,
        url: json['url'] as String,
        mimeType: json['mimeType'] as String,
      );
}

class NewsItemModel {
  const NewsItemModel({
    required this.id,
    required this.municipalityId,
    required this.title,
    required this.body,
    required this.category,
    required this.pinned,
    required this.publishedAt,
    required this.archived,
    required this.attachments,
    this.imageUrl,
  });

  final String id;
  final String municipalityId;
  final LocalizedTextModel title;
  final LocalizedTextModel body;
  final String? imageUrl;
  final String category;
  final bool pinned;
  final DateTime publishedAt;
  final bool archived;
  final List<NewsAttachmentModel> attachments;

  factory NewsItemModel.fromJson(Map<String, dynamic> json) {
    final dynamic rawAttachments = json['attachments'];
    return NewsItemModel(
      id: json['id'] as String,
      municipalityId: json['municipalityId'] as String,
      title: LocalizedTextModel.fromJson(
        Map<String, dynamic>.from(json['title'] as Map),
      ),
      body: LocalizedTextModel.fromJson(
        Map<String, dynamic>.from(json['body'] as Map),
      ),
      imageUrl: json['imageUrl'] as String?,
      category: json['category'] as String,
      pinned: json['pinned'] as bool,
      publishedAt: DateTime.parse(json['publishedAt'] as String),
      archived: json['archived'] as bool,
      attachments: rawAttachments is List<dynamic>
          ? rawAttachments
                .whereType<Map<String, dynamic>>()
                .map(NewsAttachmentModel.fromJson)
                .toList(growable: false)
          : const <NewsAttachmentModel>[],
    );
  }
}

class NewsPageModel {
  const NewsPageModel({
    required this.pinned,
    required this.items,
    this.nextCursor,
  });
  final List<NewsItemModel> pinned;
  final List<NewsItemModel> items;
  final String? nextCursor;

  factory NewsPageModel.fromJson(Map<String, dynamic> json) => NewsPageModel(
    pinned: _items(json['pinned']),
    items: _items(json['items']),
    nextCursor: json['nextCursor'] as String?,
  );

  static List<NewsItemModel> _items(dynamic value) => value is List<dynamic>
      ? value
            .whereType<Map<String, dynamic>>()
            .map(NewsItemModel.fromJson)
            .toList(growable: false)
      : const <NewsItemModel>[];
}
