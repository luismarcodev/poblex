import 'dart:typed_data';

import 'package:equatable/equatable.dart';

class LocalizedText extends Equatable {
  const LocalizedText({required this.es, this.va});
  final String es;
  final String? va;

  Map<String, dynamic> toJson() => {
    'es': es.trim(),
    if (va != null && va!.trim().isNotEmpty) 'va': va!.trim(),
  };

  @override
  List<Object?> get props => [es, va];
}

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
  List<Object?> get props => [id, name, url, mimeType];
}

class NewsAttachmentUploadFile {
  const NewsAttachmentUploadFile({required this.name, required this.bytes});

  final String name;
  final Uint8List bytes;
}

class NewsAttachmentUploadTarget extends Equatable {
  const NewsAttachmentUploadTarget({
    required this.uploadUrl,
    required this.publicUrl,
    required this.expiresInSeconds,
  });

  final String uploadUrl;
  final String publicUrl;
  final int expiresInSeconds;

  @override
  List<Object?> get props => [uploadUrl, publicUrl, expiresInSeconds];
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
  final String category;
  final bool pinned;
  final DateTime publishedAt;
  final bool archived;
  final String? imageUrl;
  final List<NewsAttachment> attachments;

  NewsItem copyWith({List<NewsAttachment>? attachments}) => NewsItem(
    id: id,
    municipalityId: municipalityId,
    title: title,
    body: body,
    category: category,
    pinned: pinned,
    publishedAt: publishedAt,
    archived: archived,
    imageUrl: imageUrl,
    attachments: attachments ?? this.attachments,
  );

  @override
  List<Object?> get props => [
    id,
    municipalityId,
    title,
    body,
    category,
    pinned,
    publishedAt,
    archived,
    imageUrl,
    attachments,
  ];
}

class ManagedNewsPage extends Equatable {
  const ManagedNewsPage({required this.items, required this.nextCursor});
  final List<NewsItem> items;
  final String? nextCursor;
  @override
  List<Object?> get props => [items, nextCursor];
}

class SaveNewsInput extends Equatable {
  const SaveNewsInput({
    required this.title,
    required this.body,
    required this.category,
    required this.imageUrl,
    required this.pinned,
    required this.municipalityIds,
    this.id,
    this.shareToChannels = const {},
  });

  final String? id;
  final LocalizedText title;
  final LocalizedText body;
  final String category;
  final String? imageUrl;
  final bool pinned;
  final List<String> municipalityIds;
  // Checkbox por noticia en el editor — nunca automático para todas.
  final Set<String> shareToChannels;

  bool get isEditing => id != null;
  @override
  List<Object?> get props => [
    id,
    title,
    body,
    category,
    imageUrl,
    pinned,
    municipalityIds,
    shareToChannels,
  ];
}
