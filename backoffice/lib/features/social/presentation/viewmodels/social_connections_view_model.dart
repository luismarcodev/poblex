import 'package:equatable/equatable.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/di/injection_container.dart';
import '../../../../core/errors/app_failure.dart';
import '../../../../core/result/result.dart';
import '../../../auth/presentation/viewmodels/municipality_view_model.dart';
import '../../domain/entities/social_account.dart';
import '../../domain/usecases/social_usecases.dart';
import '../platform/social_oauth_launcher.dart';

class SocialConnectionsUiState extends Equatable {
  const SocialConnectionsUiState({
    required this.municipalityId,
    required this.accounts,
    this.busyPlatforms = const {},
  });

  final String municipalityId;
  final List<SocialAccount> accounts;
  final Set<String> busyPlatforms;

  SocialAccount? accountFor(String platform) {
    for (final account in accounts) {
      if (account.platform == platform) return account;
    }
    return null;
  }

  SocialConnectionsUiState copyWith({
    List<SocialAccount>? accounts,
    Set<String>? busyPlatforms,
  }) => SocialConnectionsUiState(
    municipalityId: municipalityId,
    accounts: accounts ?? this.accounts,
    busyPlatforms: busyPlatforms ?? this.busyPlatforms,
  );

  @override
  List<Object?> get props => [municipalityId, accounts, busyPlatforms];
}

final socialConnectionsViewModelProvider =
    AsyncNotifierProvider<SocialConnectionsViewModel, SocialConnectionsUiState>(
      SocialConnectionsViewModel.new,
    );

class SocialConnectionsViewModel
    extends AsyncNotifier<SocialConnectionsUiState> {
  @override
  Future<SocialConnectionsUiState> build() async {
    final municipalityId = ref.watch(
      selectedMunicipalityProvider.select((municipality) => municipality.id),
    );
    final result = await getIt<ListSocialAccounts>()(municipalityId);
    return switch (result) {
      Success(value: final accounts) => SocialConnectionsUiState(
        municipalityId: municipalityId,
        accounts: accounts,
      ),
      Failure(error: final error) => throw error,
    };
  }

  Future<void> refresh() async {
    ref.invalidateSelf();
    await future;
  }

  /// Redirige el navegador entero a Meta — no vuelve a este método. El
  /// estado "busy" no hace falta limpiarlo: la pantalla se abandona.
  Future<AppFailure?> connect(String platform) async {
    final current = state.valueOrNull;
    if (current == null || current.busyPlatforms.contains(platform)) {
      return null;
    }
    _setBusy(platform, true);
    final result = await getIt<StartSocialOAuth>()(
      municipalityId: current.municipalityId,
      platform: platform,
    );
    if (result case Failure(error: final error)) {
      _setBusy(platform, false);
      return error;
    }
    launchSocialOAuth((result as Success<String>).value);
    return null;
  }

  Future<AppFailure?> disconnect(SocialAccount account) async {
    final current = state.valueOrNull;
    if (current == null || current.busyPlatforms.contains(account.platform)) {
      return null;
    }
    _setBusy(account.platform, true);
    final result = await getIt<DisconnectSocialAccount>()(account.id);
    final latest = state.valueOrNull;
    if (latest == null) return null;
    if (result case Failure(error: final error)) {
      _setBusy(account.platform, false);
      return error;
    }
    state = AsyncData(
      latest.copyWith(
        accounts: latest.accounts
            .where((value) => value.id != account.id)
            .toList(),
        busyPlatforms: {...latest.busyPlatforms}..remove(account.platform),
      ),
    );
    return null;
  }

  void _setBusy(String platform, bool busy) {
    final current = state.valueOrNull;
    if (current == null) return;
    final ids = {...current.busyPlatforms};
    busy ? ids.add(platform) : ids.remove(platform);
    state = AsyncData(current.copyWith(busyPlatforms: ids));
  }
}
