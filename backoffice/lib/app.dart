import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:poblex_design_system/poblex_design_system.dart';

import 'features/auth/presentation/viewmodels/auth_view_model.dart';
import 'l10n/app_localizations.dart';

class PoblexBackofficeApp extends ConsumerWidget {
  const PoblexBackofficeApp({required this.router, super.key});
  final GoRouter router;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Keep the bootstrap provider alive without rebuilding MaterialApp for
    // every authentication transition. Navigation reacts to AuthSession.
    ref.listen(authViewModelProvider, (_, _) {});
    return MaterialApp.router(
      onGenerateTitle: (context) =>
          '${AppLocalizations.of(context).appName} · ${AppLocalizations.of(context).backofficeTitle}',
      theme: AppTheme.light(),
      darkTheme: AppTheme.dark(),
      builder: AppTheme.textScalingBuilder,
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      routerConfig: router,
      debugShowCheckedModeBanner: false,
    );
  }
}
