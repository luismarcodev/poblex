import 'package:flutter_test/flutter_test.dart';
import 'package:poblex_backoffice/features/news/domain/value_objects/news_category.dart';

void main() {
  test('matches the backend category slug contract', () {
    expect(isValidNewsCategory('servicios'), isTrue);
    expect(isValidNewsCategory('proteccion-civil'), isTrue);
    expect(isValidNewsCategory('proteccion_civil'), isFalse);
    expect(isValidNewsCategory('Proteccion-civil'), isFalse);
    expect(isValidNewsCategory('proteccion--civil'), isFalse);
  });
}
