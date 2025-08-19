import 'package:equatable/equatable.dart';
import 'package:memes/core/usecase/usecase.dart';
import 'package:memes/memes/data/models/meme_model.dart';
import 'package:memes/memes/domain/entities/meme.dart';
import 'package:memes/memes/domain/repository/repository.dart';
import 'package:dartz/dartz.dart';
import 'package:memes/core/failures/failures.dart';

class CacheMemeParams extends Params with EquatableMixin {
  final MemeModel meme;

  const CacheMemeParams({required this.meme});

  @override
  List<Object?> get props => [meme];
}

class CacheMemeUseCase extends UseCase<MemeResult, CacheMemeParams> {
  final MemesRepository repository;

  CacheMemeUseCase(this.repository);

  @override
  Future<Either<Failure, MemeResult>> call(CacheMemeParams params) async {
    return repository.cacheMeme(params.meme);
  }
}
