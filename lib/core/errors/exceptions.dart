// exceptions.dart
class ServerException implements Exception {
  final String message;
  final int? statusCode;

  ServerException({
    required this.message,
    this.statusCode,
  });
}

class NetworkException implements Exception {
  final String message;

  NetworkException({
    this.message = 'No internet connection',
  });
}

class CacheException implements Exception {
  final String message;

  CacheException({
    this.message = 'Cache error',
  });
}

class AuthException implements Exception {
  final String message;
  final String? code;

  AuthException({
    required this.message,
    this.code,
  });
}

class ValidationException implements Exception {
  final String message;
  final Map<String, String>? errors;

  ValidationException({
    required this.message,
    this.errors,
  });
}

class UnauthorizedException implements Exception {
  final String message;
  final String? code;

  UnauthorizedException({
    required this.message,
    this.code,
  });
}