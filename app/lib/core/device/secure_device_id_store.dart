import 'package:flutter/foundation.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:uuid/uuid.dart';

import 'device_id_store.dart';

const String _deviceIdKey = 'poblex_device_id';

class SecureDeviceIdStore implements DeviceIdStore {
  SecureDeviceIdStore({FlutterSecureStorage? storage, Uuid? uuid})
    : _storage = storage ?? const FlutterSecureStorage(),
      _uuid = uuid ?? const Uuid();

  final FlutterSecureStorage _storage;
  final Uuid _uuid;

  /// Guards against the identifier being generated twice when two callers race
  /// on first launch.
  Future<String>? _pending;

  @override
  Future<String?> read() async {
    try {
      return await _storage.read(key: _deviceIdKey);
    } on Object catch (error) {
      // On Android this throws when the device is restored from a backup: the
      // encrypted preferences come back but their Keystore key does not. Losing
      // the identifier only costs the one-vote-per-device guarantee; crashing
      // on launch is not acceptable.
      debugPrint('Could not read the device id, treating it as absent: $error');
      return null;
    }
  }

  @override
  Future<String> getOrCreate() {
    return _pending ??= _getOrCreate()
      ..whenComplete(() => _pending = null).ignore();
  }

  Future<String> _getOrCreate() async {
    final String? stored = await read();
    if (stored != null && stored.isNotEmpty) return stored;

    // v4 strictly: the backend validates the version digit and rejects
    // anything else with a 400.
    final String created = _uuid.v4();
    try {
      await _storage.write(key: _deviceIdKey, value: created);
    } on Object catch (error) {
      // Same reasoning: a device that cannot persist the identifier still has
      // to work. It will register again on the next launch.
      debugPrint('Could not persist the device id: $error');
    }
    return created;
  }
}
