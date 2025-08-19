// core/errors/failures.dart
import 'package:equatable/equatable.dart';

abstract class Failure extends Equatable {
  final String message;

  const Failure(this.message);

  @override
  List<Object?> get props => [message];
}

// Network failures
class NetworkFailure extends Failure {
  const NetworkFailure([super.message = 'Network error occurred']);
}

// Server failures
class ServerFailure extends Failure {
  const ServerFailure([super.message = 'Server error occurred']);
}

// Cache failures
class CacheFailure extends Failure {
  const CacheFailure([super.message = 'Cache error occurred']);
}

// Specific domain failures
class MemeNotFoundFailure extends Failure {
  final String Id;

  const MemeNotFoundFailure(this.Id) : super('Meme $Id not found');

  @override
  List<Object?> get props => [Id, message];
}

class InvalidMemeFailure extends Failure {
  const InvalidMemeFailure([super.message = 'Invalid meme data']);
}
