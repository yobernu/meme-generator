import 'package:dartz/dartz.dart';
import 'package:memes/core/failures/failures.dart';
import 'package:memes/memes/data/models/meme_model.dart';
import 'package:memes/memes/domain/entities/meme.dart';
import 'package:memes/memes/domain/entities/meme_caption.dart';

abstract class MemesRepository {
  Future<Either<Failure, List<Meme>>> getMemes();
  Future<Either<Failure, MemeResult>> createMeme(CreateMemeRequest meme);

  // local
  Future<Either<Failure, MemeResult>> cacheMeme(MemeModel meme);
  Future<Either<Failure, MemeModel>> getChachedMeme();
}
