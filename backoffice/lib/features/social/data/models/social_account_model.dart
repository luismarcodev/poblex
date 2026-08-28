import '../../domain/entities/social_account.dart';

class SocialAccountModel {
  const SocialAccountModel(this.entity);
  final SocialAccount entity;

  factory SocialAccountModel.fromJson(Map<String, dynamic> json) {
    final lastRefreshedAt = json['lastRefreshedAt'] as String?;
    return SocialAccountModel(
      SocialAccount(
        id: json['id'] as String,
        municipalityId: json['municipalityId'] as String,
        platform: json['platform'] as String,
        accountName: json['accountName'] as String,
        status: json['status'] as String,
        tokenExpiresAt: DateTime.parse(json['tokenExpiresAt'] as String),
        lastErrorMessage: json['lastErrorMessage'] as String?,
        connectedAt: DateTime.parse(json['connectedAt'] as String),
        lastRefreshedAt: lastRefreshedAt == null
            ? null
            : DateTime.parse(lastRefreshedAt),
      ),
    );
  }
}
