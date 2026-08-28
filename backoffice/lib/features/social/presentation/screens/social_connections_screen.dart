import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:poblex_design_system/poblex_design_system.dart';

import '../../../../core/errors/app_failure.dart';
import '../../../../l10n/app_localizations.dart';
import '../../domain/entities/social_account.dart';
import '../viewmodels/social_connections_view_model.dart';

const List<String> _platforms = ['instagram', 'facebook'];

class SocialConnectionsScreen extends ConsumerWidget {
  const SocialConnectionsScreen({super.key, this.oauthStatus});

  /// `status` recibido en la vuelta del redirect del callback OAuth
  /// (`?status=ok|error`), leído por el router desde la query string.
  final String? oauthStatus;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final state = ref.watch(socialConnectionsViewModelProvider);

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!context.mounted || oauthStatus == null) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            oauthStatus == 'ok'
                ? l10n.socialOAuthSuccess
                : l10n.socialOAuthError,
          ),
        ),
      );
      ref.read(socialConnectionsViewModelProvider.notifier).refresh();
    });

    return SafeArea(
      top: false,
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(
            maxWidth: AppSize.maxWorkspaceWidth,
          ),
          child: Padding(
            padding: AppSpacing.screenPadding,
            child: RefreshIndicator(
              onRefresh: () => ref
                  .read(socialConnectionsViewModelProvider.notifier)
                  .refresh(),
              child: CustomScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                slivers: [
                  SliverToBoxAdapter(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          l10n.socialConnectionsTitle,
                          style: context.text.headlineLarge,
                        ),
                        const SizedBox(height: AppSpacing.xs),
                        Text(
                          l10n.socialConnectionsSubtitle,
                          style: context.text.bodyMedium?.copyWith(
                            color: context.semantic.textMuted,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SliverToBoxAdapter(
                    child: SizedBox(height: AppSpacing.lg),
                  ),
                  ...state.when(
                    loading: () => [
                      SliverFillRemaining(
                        hasScrollBody: false,
                        child: Semantics(
                          liveRegion: true,
                          label: l10n.loading,
                          child: const Center(
                            child: CircularProgressIndicator(),
                          ),
                        ),
                      ),
                    ],
                    error: (error, _) => [
                      SliverToBoxAdapter(child: _ErrorState(error: error)),
                    ],
                    data: (uiState) => [
                      SliverList.builder(
                        itemCount: _platforms.length,
                        itemBuilder: (context, index) => _PlatformCard(
                          platform: _platforms[index],
                          account: uiState.accountFor(_platforms[index]),
                          busy: uiState.busyPlatforms.contains(
                            _platforms[index],
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _PlatformCard extends ConsumerWidget {
  const _PlatformCard({
    required this.platform,
    required this.account,
    required this.busy,
  });

  final String platform;
  final SocialAccount? account;
  final bool busy;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final platformLabel = platform == 'instagram'
        ? l10n.socialPlatformInstagram
        : l10n.socialPlatformFacebook;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.lg),
        child: Row(
          children: [
            Icon(
              platform == 'instagram'
                  ? Icons.camera_alt_outlined
                  : Icons.facebook_outlined,
              size: 32,
            ),
            const SizedBox(width: AppSpacing.md),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(platformLabel, style: context.text.titleLarge),
                  const SizedBox(height: AppSpacing.xs),
                  Text(
                    account == null
                        ? l10n.socialNotConnected
                        : '${account!.accountName} · ${_statusLabel(l10n, account!.status)}',
                    style: context.text.bodyMedium?.copyWith(
                      color: context.semantic.textMuted,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: AppSpacing.md),
            if (busy)
              Semantics(
                liveRegion: true,
                label: l10n.loading,
                child: const SizedBox.square(
                  dimension: 24,
                  child: CircularProgressIndicator(strokeWidth: 3),
                ),
              )
            else if (account == null)
              FilledButton(
                onPressed: () => _connect(context, ref),
                child: Text(l10n.socialConnect),
              )
            else
              OutlinedButton(
                onPressed: () => _confirmDisconnect(context, ref, account!),
                child: Text(l10n.socialDisconnect),
              ),
          ],
        ),
      ),
    );
  }

  String _statusLabel(AppLocalizations l10n, String status) => switch (status) {
    'connected' => l10n.socialStatusConnected,
    'expired' => l10n.socialStatusExpired,
    'error' => l10n.socialStatusError,
    'revoked' => l10n.socialStatusRevoked,
    _ => status,
  };

  Future<void> _connect(BuildContext context, WidgetRef ref) => _runMutation(
    context,
    ref.read(socialConnectionsViewModelProvider.notifier).connect(platform),
  );

  Future<void> _confirmDisconnect(
    BuildContext context,
    WidgetRef ref,
    SocialAccount account,
  ) async {
    final l10n = AppLocalizations.of(context);
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(l10n.socialDisconnectConfirmTitle),
        content: Text(l10n.socialDisconnectConfirmBody),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text(l10n.cancel),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            child: Text(l10n.socialDisconnect),
          ),
        ],
      ),
    );
    if (confirmed != true || !context.mounted) return;
    await _runMutation(
      context,
      ref.read(socialConnectionsViewModelProvider.notifier).disconnect(account),
    );
  }
}

class _ErrorState extends ConsumerWidget {
  const _ErrorState({required this.error});
  final Object error;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    return Padding(
      padding: AppSpacing.screenPadding,
      child: Center(
        child: Semantics(
          liveRegion: true,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.cloud_off_outlined, size: 56),
              const SizedBox(height: AppSpacing.md),
              Text(
                error is NetworkFailure ? l10n.networkError : l10n.genericError,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: AppSpacing.xl),
              FilledButton.icon(
                onPressed: () => ref
                    .read(socialConnectionsViewModelProvider.notifier)
                    .refresh(),
                icon: const Icon(Icons.refresh),
                label: Text(l10n.retry),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

Future<void> _runMutation(
  BuildContext context,
  Future<AppFailure?> operation,
) async {
  final failure = await operation;
  if (failure == null || !context.mounted) return;
  final l10n = AppLocalizations.of(context);
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(
      content: Text(
        failure is NetworkFailure ? l10n.networkError : l10n.genericError,
      ),
    ),
  );
}
