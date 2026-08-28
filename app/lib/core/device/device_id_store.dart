/// Storage for the device identifier sent in `X-Device-Id`.
///
/// It is a UUID v4 generated on first launch, not an identity: it is
/// forgeable, and the backend treats it as such. It only buys one vote per
/// device in surveys, access to your own incidents, and targeted pushes.
abstract interface class DeviceIdStore {
  /// The stored identifier, or `null` if this device was never registered.
  Future<String?> read();

  /// Reads it, or creates and persists a new one. Explicit act of onboarding —
  /// never called from an interceptor, which would silently register devices
  /// on any stray request.
  Future<String> getOrCreate();
}
