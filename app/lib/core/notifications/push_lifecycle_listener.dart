import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../l10n/app_localizations.dart';
import '../di/injection_container.dart';
import '../session/session_view_model.dart';
import 'push_notification_service.dart';

class PushLifecycleListener extends ConsumerStatefulWidget {
  const PushLifecycleListener({
    required this.router,
    required this.child,
    super.key,
  });

  final GoRouter router;
  final Widget child;

  @override
  ConsumerState<PushLifecycleListener> createState() =>
      _PushLifecycleListenerState();
}

class _PushLifecycleListenerState extends ConsumerState<PushLifecycleListener> {
  final List<StreamSubscription<Object?>> _subscriptions =
      <StreamSubscription<Object?>>[];

  @override
  void initState() {
    super.initState();
    final PushNotificationService push = getIt<PushNotificationService>();
    _subscriptions
      ..add(push.openedMessages.listen(_openMessage))
      ..add(push.foregroundMessages.listen(_showForegroundMessage))
      ..add(
        push.tokenRefreshes.listen(
          (String token) => ref
              .read(sessionViewModelProvider.notifier)
              .refreshPushToken(token),
        ),
      );
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      final PushMessage? initial = await push.takeInitialMessage();
      if (initial != null && mounted) _openMessage(initial);
    });
  }

  @override
  void dispose() {
    for (final StreamSubscription<Object?> subscription in _subscriptions) {
      subscription.cancel();
    }
    super.dispose();
  }

  void _openMessage(PushMessage message) {
    if (!mounted) return;
    final String? activeMunicipalityId = ref
        .read(sessionViewModelProvider)
        .value
        ?.municipalityId;
    if (!notificationBelongsToMunicipality(message, activeMunicipalityId)) {
      final AppLocalizations l10n = AppLocalizations.of(context);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Semantics(
            liveRegion: true,
            child: Text(l10n.notificationOtherMunicipality),
          ),
        ),
      );
      return;
    }
    if (message.type == 'news') widget.router.go('/news/${message.itemId}');
  }

  void _showForegroundMessage(PushMessage message) {
    if (!mounted) return;
    final String? activeMunicipalityId = ref
        .read(sessionViewModelProvider)
        .value
        ?.municipalityId;
    if (!notificationBelongsToMunicipality(message, activeMunicipalityId)) {
      return;
    }
    final AppLocalizations l10n = AppLocalizations.of(context);
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          content: Semantics(
            liveRegion: true,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(
                  message.title.isEmpty
                      ? l10n.notificationNewNews
                      : message.title,
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                if (message.body.isNotEmpty) Text(message.body),
              ],
            ),
          ),
          duration: const Duration(seconds: 8),
          action: SnackBarAction(
            label: l10n.notificationOpen,
            onPressed: () => _openMessage(message),
          ),
        ),
      );
  }

  @override
  Widget build(BuildContext context) => widget.child;
}
