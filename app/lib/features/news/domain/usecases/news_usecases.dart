import '../../../../core/result/result.dart';
import '../entities/news_item.dart';
import '../repositories/news_repository.dart';

class GetNews {
  const GetNews(this._repository);
  final NewsRepository _repository;

  Future<Result<NewsPage>> call({
    required String municipalityId,
    bool archived = false,
    String? category,
    String? cursor,
  }) => _repository.list(
    municipalityId: municipalityId,
    archived: archived,
    category: category,
    cursor: cursor,
  );
}

class GetNewsCategories {
  const GetNewsCategories(this._repository);
  final NewsRepository _repository;

  Future<Result<List<String>>> call(String municipalityId) =>
      _repository.categories(municipalityId);
}

class GetNewsDetail {
  const GetNewsDetail(this._repository);
  final NewsRepository _repository;

  Future<Result<NewsItem>> call({
    required String id,
    required String municipalityId,
  }) => _repository.detail(id: id, municipalityId: municipalityId);
}
