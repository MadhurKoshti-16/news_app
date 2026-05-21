class ServerException implements Exception {
  const ServerException({required this.message, required this.statusCode});

  final String message;
  final int statusCode;

  @override
  String toString() => 'ServerException($statusCode): $message';
}

/// Thrown when there is no internet / the request times out.
class NetworkException implements Exception {
  const NetworkException({required this.message});

  final String message;

  @override
  String toString() => 'NetworkException: $message';
}

/// Thrown when local Hive read/write operations fail.
class CacheException implements Exception {
  const CacheException({required this.message});

  final String message;

  @override
  String toString() => 'CacheException: $message';
}

/// Thrown for 401 Unauthorized (missing / invalid API key).
class UnauthorizedException implements Exception {
  const UnauthorizedException({this.message = 'Unauthorized'});

  final String message;

  @override
  String toString() => 'UnauthorizedException: $message';
}
