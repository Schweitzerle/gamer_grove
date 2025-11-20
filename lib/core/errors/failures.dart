// failures.dart
import 'package:equatable/equatable.dart';

abstract class Failure extends Equatable {

  const Failure({
    required this.message,
    this.code,
  });
  final String message;
  final String? code;

  @override
  List<Object?> get props => [message, code];
}

class ServerFailure extends Failure {
  const ServerFailure({
    super.message = 'Server error occurred',
    super.code,
  });
}

class NetworkFailure extends Failure {
  const NetworkFailure({
    super.message = 'Network connection error',
    super.code,
  });
}

class CacheFailure extends Failure {
  const CacheFailure({
    super.message = 'Cache error occurred',
    super.code,
  });
}

class AuthenticationFailure extends Failure {
  const AuthenticationFailure({
    super.message = 'Authentication failed',
    super.code,
  });
}

class ValidationFailure extends Failure {
  const ValidationFailure({
    required super.message,
    super.code,
  });
}


class NotFoundFailure extends Failure {
  const NotFoundFailure({
    super.message = 'Requested resource was not found',
    super.code,
  });
}

class AuthorizationFailure extends Failure {
  const AuthorizationFailure({
    super.message = 'Not authorized to access this resource',
    super.code,
  });
}