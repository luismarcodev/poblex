import '../../../../core/result/result.dart';
import '../entities/social_account.dart';
import '../repositories/social_repository.dart';

class ListSocialAccounts {
  const ListSocialAccounts(this._repository);
  final SocialRepository _repository;
  Future<Result<List<SocialAccount>>> call(String municipalityId) =>
      _repository.listAccounts(municipalityId);
}

class StartSocialOAuth {
  const StartSocialOAuth(this._repository);
  final SocialRepository _repository;
  Future<Result<String>> call({
    required String municipalityId,
    required String platform,
  }) => _repository.startOAuth(
    municipalityId: municipalityId,
    platform: platform,
  );
}

class DisconnectSocialAccount {
  const DisconnectSocialAccount(this._repository);
  final SocialRepository _repository;
  Future<Result<void>> call(String id) => _repository.disconnect(id);
}
