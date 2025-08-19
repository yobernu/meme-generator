// core/errors/exceptions.dart
class AppException implements Exception {
  final String message;

  const AppException([this.message = 'An unexpected error occurred']);
}

class NetworkException extends AppException {
  const NetworkException([super.message = 'No internet connection']);
}

class TimeoutException extends AppException {
  const TimeoutException([super.message = 'Request timed out']);
}

// Server-related exceptions
class ServerException extends AppException {
  const ServerException([super.message = 'Server error occurred']);
}

class BadRequestException extends AppException {
  const BadRequestException([super.message = 'Invalid request']);
}

class UnauthorizedException extends AppException {
  const UnauthorizedException([super.message = 'Authentication required']);
}

class ForbiddenException extends AppException {
  const ForbiddenException([super.message = 'Access denied']);
}

class NotFoundException extends AppException {
  const NotFoundException([super.message = 'Resource not found']);
}

// Data-related exceptions
class CacheException extends AppException {
  const CacheException([super.message = 'Cache error occurred']);
}

class ProductNotFoundException extends AppException {
  const ProductNotFoundException([super.message = 'Product not found']);
}
