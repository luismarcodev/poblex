import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../features/device/domain/usecases/device_registration_usecases.dart';
import '../../features/device/domain/usecases/sync_device_push.dart';
import '../../features/municipalities/domain/entities/municipality.dart';
import '../di/injection_container.dart';
import '../errors/failure.dart';
import '../l10n/app_locales.dart';
import '../l10n/locale_controller.dart';
import '../result/result.dart';
import 'session_state.dart';
import 'session_store.dart';

final sessionViewModelProvider =
    AsyncNotifierProvider<SessionViewModel, SessionState>(SessionViewModel.new);

class SessionViewModel extends AsyncNotifier<SessionState> {
  late final SessionStore _store = getIt<SessionStore>();
  late final RegisterDevice _registerDevice = getIt<RegisterDevice>();
  late final SyncDevicePush _syncPush = getIt<SyncDevicePush>();
  late final UpdateDevicePush _updatePush = getIt<UpdateDevicePush>();
  late final LocaleController _localeController = getIt<LocaleController>();

  @override
  Future<SessionState> build() async {
    final AppLocale deviceLocale = AppLocale.fromDeviceLocale(
      WidgetsBinding.instance.platformDispatcher.locale,
    );
    final StoredSession stored = await _store.read();
    final AppLocale activeLocale = stored.localeOverride ?? deviceLocale;
    _localeController.set(activeLocale);

    final SessionState restored = SessionState(
      deviceId: null,
      municipalityId: stored.municipalityId,
      municipalityName: stored.municipalityName,
      municipalitySlug: stored.municipalitySlug,
      municipalityPrimaryColor: stored.municipalityPrimaryColor,
      localeOverride: stored.localeOverride,
      deviceLocale: deviceLocale,
    );

    if (restored.municipalityId != null) {
      final Result<String> registration = await _register(
        municipalityId: restored.municipalityId!,
        locale: restored.locale,
      );
      if (registration case Success<String>(:final value)) {
        return restored.copyWith(deviceId: value);
      }
    }
    return restored;
  }

  Future<Result<void>> selectMunicipality(Municipality municipality) async {
    final SessionState current = state.value ?? const SessionState.initial();
    final Result<String> registration = await _register(
      municipalityId: municipality.id,
      locale: current.locale,
    );
    if (registration case Failed<String>(:final failure)) {
      return Failed<void>(failure);
    }
    final String deviceId = registration.valueOrNull!;
    await _store.saveMunicipality(
      id: municipality.id,
      name: municipality.name,
      slug: municipality.slug,
      primaryColor: municipality.primaryColor,
    );
    state = AsyncData<SessionState>(
      current.copyWith(
        deviceId: deviceId,
        municipalityId: municipality.id,
        municipalityName: municipality.name,
        municipalitySlug: municipality.slug,
        municipalityPrimaryColor: municipality.primaryColor,
        clearMunicipalityPrimaryColor: municipality.primaryColor == null,
      ),
    );
    return const Success<void>(null);
  }

  Future<void> setLocaleOverride(AppLocale? locale) async {
    final SessionState? current = state.value;
    if (current == null) return;
    await _store.saveLocaleOverride(locale);
    final SessionState updated = current.copyWith(
      localeOverride: locale,
      clearLocaleOverride: locale == null,
    );
    _localeController.set(updated.locale);
    state = AsyncData<SessionState>(updated);

    final String? municipalityId = updated.municipalityId;
    final String? deviceId = updated.deviceId;
    if (municipalityId == null || deviceId == null) return;

    // Best-effort: never throws. See SyncDevicePush's own doc for why.
    await _syncPush(
      deviceId: deviceId,
      municipalityId: municipalityId,
      locale: updated.locale,
    );
  }

  Future<void> refreshPushToken(String token) async {
    final SessionState? current = state.value;
    final String? deviceId = current?.deviceId;
    if (current == null || deviceId == null) return;
    await _updatePush(
      deviceId: deviceId,
      locale: current.locale,
      fcmToken: token,
    );
  }

  Future<Result<String>> _register({
    required String municipalityId,
    required AppLocale locale,
  }) async {
    try {
      final Result<String> result = await _registerDevice(
        municipalityId: municipalityId,
        locale: locale,
      );
      if (result case Success<String>(:final value)) {
        // Push is optional from the user's point of view. Denying the OS
        // permission must never prevent choosing a municipality or reading —
        // SyncDevicePush already swallows every failure on its own.
        await _syncPush(
          deviceId: value,
          municipalityId: municipalityId,
          locale: locale,
        );
      }
      return result;
    } on Object {
      return const Failed<String>(UnknownFailure());
    }
  }
}
