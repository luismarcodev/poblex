import 'package:flutter_test/flutter_test.dart';
import 'package:poblex_backoffice/features/news/data/models/news_item_model.dart';

void main() {
  test('maps the complete managed news contract', () {
    final model = NewsItemModel.fromJson({
      'id': 'news-1',
      'municipalityId': 'municipality-1',
      'title': {'es': 'Corte de agua', 'va': "Tall d'aigua"},
      'body': {'es': 'Desde las diez', 'va': 'Des de les deu'},
      'imageUrl': null,
      'category': 'servicios',
      'pinned': true,
      'publishedAt': '2026-08-09T10:00:00.000Z',
      'archived': false,
      'attachments': [
        {
          'id': 'attachment-1',
          'name': 'bando.pdf',
          'url': 'https://example.com/bando.pdf',
          'mimeType': 'application/pdf',
        },
      ],
    });

    expect(model.entity.title.es, 'Corte de agua');
    expect(model.entity.title.va, "Tall d'aigua");
    expect(model.entity.pinned, isTrue);
    expect(model.entity.attachments.single.name, 'bando.pdf');
    expect(model.entity.publishedAt.isUtc, isTrue);
  });
}
