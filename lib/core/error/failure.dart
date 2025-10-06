// lib/core/error/failure.dart
abstract class Failure {
  final String message;
  
  const Failure(this.message);
}

// Server/API failures
class ServerFailure extends Failure {
  const ServerFailure(super.message);
}

// Cache/Local database failures
class CacheFailure extends Failure {
  const CacheFailure(super.message);
}

// Network failures
class NetworkFailure extends Failure {
  const NetworkFailure(super.message);
}

// Validation failures
class ValidationFailure extends Failure {
  const ValidationFailure(super.message);
}

// Unknown failures
class UnknownFailure extends Failure {
  const UnknownFailure(super.message);
}
