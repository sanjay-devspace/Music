import 'dart:io';

/// Base class for every application-level exception.
///
/// Controllers must catch these and surface [message] to the user. Raw
/// platform exceptions (e.g. `SocketException`) are converted into
/// [AppException] subclasses at the service layer.
class AppException implements Exception {
  const AppException({
    required this.message,
    this.code = 'app_error',
    this.cause,
  });

  /// User-facing, friendly message.
  final String message;

  /// Stable machine-readable code.
  final String code;

  /// Original wrapped exception, useful for diagnostics.
  final Object? cause;

  @override
  String toString() => message;
}

/// Network / connectivity failures.
class NetworkException extends AppException {
  const NetworkException({
    super.cause,
    super.code = 'network_error',
    super.message =
        'Unable to connect right now.\nPlease check your internet connection.',
  });
}

/// Failures during authentication or authorization.
class AuthenticationException extends AppException {
  const AuthenticationException({
    super.cause,
    super.code = 'auth_error',
    super.message = 'Sign in failed. Please try again.',
  });
}

/// Failures coming from an upstream music provider.
class ProviderException extends AppException {
  const ProviderException({
    super.cause,
    super.code = 'provider_error',
    super.message = 'The music service is unavailable right now.',
  });
}

/// Failures from the audio playback engine.
class PlaybackException extends AppException {
  const PlaybackException({
    super.cause,
    super.code = 'playback_error',
    super.message = 'Playback could not be started for this track.',
  });
}

/// Failures from persistence layers (Supabase, storage).
class DatabaseException extends AppException {
  const DatabaseException({
    super.cause,
    super.code = 'database_error',
    super.message = 'We could not save your changes. Please try again.',
  });
}

/// Converts unknown exceptions thrown by third party code into a safe
/// [AppException]. Used by the service layer as a final guard.
AppException wrapError(Object error) {
  if (error is AppException) return error;
  if (error is SocketException || error is HttpException) {
    return NetworkException(cause: error);
  }
  return AppException(
    message: 'Something went wrong. Please try again.',
    cause: error,
  );
}