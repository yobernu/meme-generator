import 'package:dartz/dartz.dart';
import 'package:memes/core/failures/failures.dart';

class InputConverter {
  Future<Either<Failure, String>> stringToUnsignedInteger(String str) async {
    try {
      final unsignedInteger = int.parse(str);
      if (unsignedInteger < 0) throw FormatException();
      return Right(unsignedInteger.toString());
    } on FormatException catch (e) {
      return Left(InvalidInputFailure(e.toString()));
    }
  }
}

class InvalidInputFailure extends Failure {
  @override
  final String message;

  const InvalidInputFailure(this.message) : super(message);
}
