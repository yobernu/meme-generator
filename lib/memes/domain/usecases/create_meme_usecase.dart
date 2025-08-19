import 'package:equatable/equatable.dart';
import 'package:memes/core/usecase/usecase.dart';
import 'package:memes/memes/domain/entities/meme.dart';
import 'package:memes/memes/domain/entities/meme_caption.dart';
import 'package:memes/memes/domain/repository/repository.dart';
import 'package:dartz/dartz.dart';
import 'package:memes/core/failures/failures.dart';

class CreateMemeParams extends Params with EquatableMixin {
  final CreateMemeRequest meme;

  const CreateMemeParams({required this.meme});

  @override
  List<Object?> get props => [meme];
}

class CreateMemeUseCase extends UseCase<MemeResult, CreateMemeParams> {
  final MemesRepository repository;

  CreateMemeUseCase(this.repository);

  @override
  Future<Either<Failure, MemeResult>> call(CreateMemeParams params) {
    return repository.createMeme(params.meme);
  }
}
