import '../../../../core/network/api_error_mapper.dart';
import '../../../../core/result/result.dart';
import '../../domain/entities/social_account.dart';
import '../../domain/repositories/social_repository.dart';
import '../datasources/social_remote_datasource.dart';

class SocialRepositoryImpl implements SocialRepository {
  const SocialRepositoryImpl(this._remote);
  final SocialRemoteDataSource _remote;

  Future<Result<T>> _capture<T>(Future<T> Function() action) async {
    try {
      return Success(await action());
    } catch (error) {
      return Failure(mapApiError(error));
    }
  }

  @override
  Future<Result<List<SocialAccount>>> listAccounts(String municipalityId) =>
      _capture(
        () async => (await _remote.listAccounts(
          municipalityId,
        )).map((model) => model.entity).toList(growable: false),
      );

  @override
  Future<Result<String>> startOAuth({
    required String municipalityId,
    required String platform,
  }) => _capture(
    () =>
        _remote.startOAuth(municipalityId: municipalityId, platform: platform),
  );

  @override
  Future<Result<void>> disconnect(String id) =>
      _capture(() => _remote.disconnect(id));
}
