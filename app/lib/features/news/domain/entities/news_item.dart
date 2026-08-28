import 'package:equatable/equatable.dart';

import '../../../../shared/domain/value_objects/localized_text.dart';

class NewsAttachment extends Equatable {
  const NewsAttachment({
    required this.id,
    required this.name,
    required this.url,
    required this.mimeType,
  });

  final String id;
  final String name;
  final String url;
  final String mimeType;

  @override
  List<Object> get props => <Object>[id, name, url, mimeType];
}

class NewsItem extends Equatable {
  const NewsItem({
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
  final LocalizedText title;
  final LocalizedText body;
  final String? imageUrl;
  final String category;
  final bool pinned;
  final DateTime publishedAt;
  final bool archived;
  final List<NewsAttachment> attachments;

  @override
  List<Object?> get props => <Object?>[
    id,
    municipalityId,
    title,
    body,
    imageUrl,
    category,
    pinned,
    publishedAt,
    archived,
    attachments,
  ];
}

class NewsPage extends Equatable {
  const NewsPage({required this.pinned, required this.items, this.nextCursor});

  final List<NewsItem> pinned;
  final List<NewsItem> items;
  final String? nextCursor;

  @override
  List<Object?> get props => <Object?>[pinned, items, nextCursor];
}
