import '../../../../core/result/result.dart';
import '../entities/news_item.dart';

abstract interface class NewsRepository {
  Future<Result<NewsPage>> list({
    required String municipalityId,
    required bool archived,
    String? category,
    String? cursor,
  });

  Future<Result<List<String>>> categories(String municipalityId);

  Future<Result<NewsItem>> detail({
    required String id,
    required String municipalityId,
  });
}
