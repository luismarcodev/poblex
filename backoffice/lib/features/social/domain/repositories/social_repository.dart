import '../../../../core/result/result.dart';
import '../entities/social_account.dart';

abstract interface class SocialRepository {
  Future<Result<List<SocialAccount>>> listAccounts(String municipalityId);

  /// Devuelve la URL de autorización de Meta a la que redirigir al gestor.
  Future<Result<String>> startOAuth({
    required String municipalityId,
    required String platform,
  });

  Future<Result<void>> disconnect(String id);
}
