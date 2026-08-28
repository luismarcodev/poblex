import '../../../../core/network/dio_error_mapper.dart';
import '../../../../core/result/result.dart';
import '../../domain/entities/news_item.dart';
import '../../domain/repositories/news_repository.dart';
import '../datasources/news_remote_datasource.dart';
import '../mappers/news_item_mapper.dart';
import '../models/news_item_model.dart';

class NewsRepositoryImpl implements NewsRepository {
  const NewsRepositoryImpl(this._remote);
  final NewsRemoteDataSource _remote;

  @override
  Future<Result<NewsPage>> list({
    required String municipalityId,
    required bool archived,
    String? category,
    String? cursor,
  }) async {
    try {
      final NewsPageModel page = await _remote.list(
        municipalityId: municipalityId,
        archived: archived,
        category: category,
        cursor: cursor,
      );
      return Success<NewsPage>(
        NewsPage(
          pinned: page.pinned.map(NewsItemMapper.toDomain).toList(),
          items: page.items.map(NewsItemMapper.toDomain).toList(),
          nextCursor: page.nextCursor,
        ),
      );
    } on Object catch (error) {
      return Failed<NewsPage>(mapDioError(error));
    }
  }

  @override
  Future<Result<List<String>>> categories(String municipalityId) async {
    try {
      return Success<List<String>>(await _remote.categories(municipalityId));
    } on Object catch (error) {
      return Failed<List<String>>(mapDioError(error));
    }
  }

  @override
  Future<Result<NewsItem>> detail({
    required String id,
    required String municipalityId,
  }) async {
    try {
      return Success<NewsItem>(
        NewsItemMapper.toDomain(
          await _remote.detail(id: id, municipalityId: municipalityId),
        ),
      );
    } on Object catch (error) {
      return Failed<NewsItem>(mapDioError(error));
    }
  }
}
