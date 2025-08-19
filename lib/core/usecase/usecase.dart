import 'package:equatable/equatable.dart';
import 'package:memes/core/failures/failures.dart';
import 'package:dartz/dartz.dart';

abstract class UseCase<Type, Params> {
  Future<Either<Failure, Type>> call(Params params);
}

abstract class Params extends Equatable {
  const Params();

  @override
  List<Object?> get props => [];
}

class NoParams extends Params {
  const NoParams();
  @override
  List<Object?> get props => [];
}
