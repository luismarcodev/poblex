import 'package:flutter/material.dart';
import 'package:poblex_design_system/poblex_design_system.dart';

import '../../core/errors/failure.dart';
import '../../l10n/app_localizations.dart';

typedef FailureCopy = ({String title, String body});

FailureCopy localizedFailureCopy(AppLocalizations l10n, AppFailure failure) =>
    switch (failure) {
      NetworkFailure(timedOut: true) => (
        title: l10n.errorTimeoutTitle,
        body: l10n.errorTimeoutBody,
      ),
      NetworkFailure() => (
        title: l10n.errorNetworkTitle,
        body: l10n.errorNetworkBody,
      ),
      NotFoundFailure() => (
        title: l10n.errorNotFoundTitle,
        body: l10n.errorNotFoundBody,
      ),
      TooManyRequestsFailure() => (
        title: l10n.errorTooManyRequestsTitle,
        body: l10n.errorTooManyRequestsBody,
      ),
      ConflictFailure() => (
        title: l10n.errorConflictTitle,
        body: l10n.errorConflictBody,
      ),
      ServerFailure() => (
        title: l10n.errorServerTitle,
        body: l10n.errorServerBody,
      ),
      _ => (title: l10n.errorUnknownTitle, body: l10n.errorUnknownBody),
    };

class FailureView extends StatelessWidget {
  const FailureView({
    required this.failure,
    required this.sectionName,
    required this.onRetry,
    super.key,
  });

  final AppFailure failure;
  final String sectionName;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    final AppLocalizations l10n = AppLocalizations.of(context);
    final FailureCopy copy = localizedFailureCopy(l10n, failure);

    // This is always placed straight as a Scaffold's `body` (see NewsScreen,
    // NewsDetailScreen, MunicipalityOnboardingScreen) — never inside a
    // scrollable of its own. A bare Center has no way to give at 200% text
    // scale: the copy plus the retry button can genuinely outgrow the
    // viewport, and Center doesn't scroll (A-13). LayoutBuilder gives the
    // content a floor of the viewport's height so it still centers when it
    // fits, and SingleChildScrollView lets it scroll when it doesn't.
    return LayoutBuilder(
      builder: (BuildContext context, BoxConstraints constraints) {
        return SingleChildScrollView(
          child: ConstrainedBox(
            constraints: BoxConstraints(minHeight: constraints.maxHeight),
            child: Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 520),
                child: Padding(
                  padding: const EdgeInsets.all(AppSpacing.xl),
                  child: Semantics(
                    container: true,
                    liveRegion: true,
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: <Widget>[
                        AppIconBadge(
                          icon: Icons.cloud_off_outlined,
                          size: AppIconBadgeSize.large,
                          backgroundColor: Theme.of(
                            context,
                          ).colorScheme.errorContainer,
                          foregroundColor: Theme.of(
                            context,
                          ).colorScheme.onErrorContainer,
                        ),
                        const SizedBox(height: AppSpacing.md),
                        Text(
                          copy.title,
                          style: Theme.of(context).textTheme.headlineSmall,
                        ),
                        const SizedBox(height: AppSpacing.xs),
                        Text(copy.body, textAlign: TextAlign.center),
                        const SizedBox(height: AppSpacing.xl),
                        Semantics(
                          button: true,
                          label: l10n.errorRetrySemantic(sectionName),
                          child: SizedBox(
                            width: double.infinity,
                            child: FilledButton.icon(
                              onPressed: onRetry,
                              icon: const Icon(Icons.refresh),
                              label: Text(l10n.errorRetry),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}

class InlineFailureView extends StatelessWidget {
  const InlineFailureView({
    required this.failure,
    required this.sectionName,
    required this.onRetry,
    super.key,
  });

  final AppFailure failure;
  final String sectionName;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    final AppLocalizations l10n = AppLocalizations.of(context);
    final FailureCopy copy = localizedFailureCopy(l10n, failure);
    return Semantics(
      container: true,
      liveRegion: true,
      child: Card(
        child: Padding(
          padding: AppSpacing.cardPadding,
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Icon(
                Icons.error_outline,
                color: Theme.of(context).colorScheme.error,
              ),
              const SizedBox(width: AppSpacing.sm),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Text(
                      copy.title,
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    const SizedBox(height: AppSpacing.xxs),
                    Text(copy.body),
                    const SizedBox(height: AppSpacing.xs),
                    Semantics(
                      button: true,
                      label: l10n.errorRetrySemantic(sectionName),
                      child: TextButton.icon(
                        onPressed: onRetry,
                        icon: const Icon(Icons.refresh),
                        label: Text(l10n.errorRetry),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
