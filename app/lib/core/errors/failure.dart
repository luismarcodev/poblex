import 'package:equatable/equatable.dart';

/// Typed domain errors.
///
/// `sealed` on purpose: presentation must switch exhaustively, so adding a new
/// failure breaks compilation everywhere it is not handled instead of falling
/// through to a generic message at runtime.
///
/// Nothing here knows about HTTP, Dio or status codes. The translation from
/// transport errors happens once, in `core/network/dio_error_mapper.dart`.
sealed class AppFailure extends Equatable {
  const AppFailure();

  @override
  List<Object?> get props => <Object?>[];
}

/// No usable connection, or the request exceeded the hard time budget.
///
/// There is no offline mode, so this is a common state and not an exceptional
/// one: every screen that loads data must render it properly.
final class NetworkFailure extends AppFailure {
  const NetworkFailure({this.timedOut = false});

  final bool timedOut;

  @override
  List<Object?> get props => <Object?>[timedOut];
}

final class NotFoundFailure extends AppFailure {
  const NotFoundFailure();
}

/// The server rejected the request payload. [serverMessage] is the backend's
/// own explanation, useful for forms; never shown raw as a headline.
final class ValidationFailure extends AppFailure {
  const ValidationFailure({this.serverMessage});

  final String? serverMessage;

  @override
  List<Object?> get props => <Object?>[serverMessage];
}

final class UnauthorizedFailure extends AppFailure {
  const UnauthorizedFailure();
}

final class ForbiddenFailure extends AppFailure {
  const ForbiddenFailure();
}

final class ConflictFailure extends AppFailure {
  const ConflictFailure();
}

/// Rate limit. Deserves its own case: with a generic server message the user
/// retries in a loop and makes the block worse.
final class TooManyRequestsFailure extends AppFailure {
  const TooManyRequestsFailure();
}

final class ServerFailure extends AppFailure {
  const ServerFailure({this.statusCode});

  final int? statusCode;

  @override
  List<Object?> get props => <Object?>[statusCode];
}

/// The request was cancelled on purpose — the user switched filter or tab
/// before it finished. Never rendered as an error.
final class CancelledFailure extends AppFailure {
  const CancelledFailure();
}

final class UnknownFailure extends AppFailure {
  const UnknownFailure();
}
