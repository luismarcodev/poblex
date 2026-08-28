import 'package:flutter/material.dart';
import 'package:poblex_design_system/poblex_design_system.dart';

import '../../../../l10n/app_localizations.dart';

class SplashScreen extends StatelessWidget {
  const SplashScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Scaffold(
      body: Center(
        child: Semantics(
          liveRegion: true,
          label: l10n.loading,
          child: const SizedBox(
            width: AppSize.comfortableTouchTarget,
            height: AppSize.comfortableTouchTarget,
            child: CircularProgressIndicator(),
          ),
        ),
      ),
    );
  }
}
