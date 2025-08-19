import 'package:memes/core/usecase/usecase.dart';
import 'package:memes/memes/domain/entities/meme.dart';
import 'package:memes/memes/domain/repository/repository.dart';
import 'package:dartz/dartz.dart';
import 'package:memes/core/failures/failures.dart';

class GetMemesUseCase extends UseCase<List<Meme>, NoParams> {
  final MemesRepository repository;

  GetMemesUseCase(this.repository);

  @override
  Future<Either<Failure, List<Meme>>> call(NoParams params) {
    return repository.getMemes();
  }
}
