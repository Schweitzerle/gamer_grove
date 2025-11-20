// exceptions.dart
class ServerException implements Exception {

  ServerException(
    {
    required this.message,
    this.statusCode,
  });
  final String message;
  final int? statusCode;
}

class NetworkException implements Exception {

  NetworkException({
    this.message = 'No internet connection',
  });
  final String message;
}

class CacheException implements Exception {

  CacheException({
    this.message = 'Cache error',
  });
  final String message;
}

class AuthException implements Exception {

  AuthException({
    required this.message,
    this.code,
  });
  final String message;
  final String? code;
}

class ValidationException implements Exception {

  ValidationException({
    required this.message,
    this.errors,
  });
  final String message;
  final Map<String, String>? errors;
}

class UnauthorizedException implements Exception {

  UnauthorizedException({
    required this.message,
    this.code,
  });
  final String message;
  final String? code;
}

class NotFoundException implements Exception {

  NotFoundException({
    required this.message,
    this.code,
  });
  final String message;
  final String? code;

  @override
  String toString() => 'NotFoundException: $message';
}
