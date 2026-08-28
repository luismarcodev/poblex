import 'package:equatable/equatable.dart';

class SocialAccount extends Equatable {
  const SocialAccount({
    required this.id,
    required this.municipalityId,
    required this.platform,
    required this.accountName,
    required this.status,
    required this.tokenExpiresAt,
    required this.lastErrorMessage,
    required this.connectedAt,
    required this.lastRefreshedAt,
  });

  final String id;
  final String municipalityId;
  // 'instagram' | 'facebook'
  final String platform;
  final String accountName;
  // 'connected' | 'expired' | 'error' | 'revoked'
  final String status;
  final DateTime tokenExpiresAt;
  final String? lastErrorMessage;
  final DateTime connectedAt;
  final DateTime? lastRefreshedAt;

  bool get isConnected => status == 'connected';

  @override
  List<Object?> get props => [
    id,
    municipalityId,
    platform,
    accountName,
    status,
    tokenExpiresAt,
    lastErrorMessage,
    connectedAt,
    lastRefreshedAt,
  ];
}
