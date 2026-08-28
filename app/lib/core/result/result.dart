import '../errors/failure.dart';

/// Explicit success/failure return type. Mirrors the backend's `Result<T>`.
///
/// `sealed` so that presentation is forced into an exhaustive switch:
///
/// ```dart
/// switch (result) {
///   Success(:final value) => _renderContent(value),
///   Failed(:final failure) => _renderError(failure),
/// }
/// ```
///
/// The failure branch is not optional and cannot be forgotten — which is the
/// whole point, because every screen owes the user a readable error state.
sealed class Result<T> {
  const Result();

  bool get isSuccess => this is Success<T>;
  bool get isFailure => this is Failed<T>;

  /// Value when successful, `null` otherwise. Convenience for tests; screens
  /// should switch instead of reaching for this.
  T? get valueOrNull => switch (this) {
    Success<T>(:final T value) => value,
    Failed<T>() => null,
  };
}

final class Success<T> extends Result<T> {
  const Success(this.value);

  final T value;
}

/// Named `Failed` and not `Failure` to avoid colliding with [AppFailure]
/// subclasses at the call site.
final class Failed<T> extends Result<T> {
  const Failed(this.failure);

  final AppFailure failure;
}
