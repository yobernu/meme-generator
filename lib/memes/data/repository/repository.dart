import 'package:dartz/dartz.dart';
import 'package:memes/core/constants/api_constants.dart';
import 'package:memes/core/failures/failures.dart';
import 'package:memes/core/network_info/network_info.dart';
import 'package:memes/memes/data/datasources/meme_local_Data_sources.dart';
import 'package:memes/memes/data/datasources/meme_remote_data_sources.dart';
import 'package:memes/memes/data/models/meme_model.dart';
import 'package:memes/memes/domain/entities/meme.dart';
import 'package:memes/memes/domain/entities/meme_caption.dart';
import 'package:memes/memes/domain/repository/repository.dart';

class MemesRepositoryImpl implements MemesRepository {
  final MemeRemoteDataSourcesImpl remoteDataSource;
  final MemeLocalDataSourcesImpl localDataSource;
  final NetworkInfo networkInfo;

  MemesRepositoryImpl({
    required this.remoteDataSource,
    required this.localDataSource,
    required this.networkInfo,
  });

  final baseUrl = ApiConstants.baseUrl;
  final headers = ApiConstants.headers;
  final queryParameters = ApiConstants.queryParameters;
  final endpoint = ApiConstants.getMemesEndpoint;
  @override
  Future<Either<Failure, List<Meme>>> getMemes() async {
    final remoteEither = await remoteDataSource.getMemes();
    return await remoteEither.fold(
      (failure) async {
        // fallback to cached list
        try {
          final cached = await localDataSource.getCachedMemes();
          if (cached.isNotEmpty) {
            return Right<Failure, List<Meme>>(cached);
          }
          return Left(failure);
        } catch (e) {
          return Left(CacheFailure());
        }
      },
      (memes) async {
        // cache successful fetch
        try {
          final models = memes
              .map((m) => m is MemeModel ? m : MemeModel.fromEntity(m))
              .toList();
          await localDataSource.cacheMemes(models);
        } catch (_) {}
        return Right<Failure, List<Meme>>(memes);
      },
    );
  }

  @override
  Future<Either<Failure, MemeResult>> cacheMeme(MemeModel meme) async {
    try {
      await localDataSource.cacheMeme(meme);
      return Right<Failure, MemeResult>(
        MemeResult(url: meme.url, success: true),
      );
    } catch (e) {
      return Left(CacheFailure());
    }
  }

  @override
  Future<Either<Failure, MemeResult>> createMeme(CreateMemeRequest meme) async {
    return await remoteDataSource.createMeme(meme);
  }

  @override
  Future<Either<Failure, MemeModel>> getChachedMeme() async {
    try {
      final meme = await localDataSource.getChachedMeme();
      if (meme != null) return Right<Failure, MemeModel>(meme);
      return Left(MemeNotFoundFailure('cached'));
    } catch (e) {
      return Left(CacheFailure());
    }
  }
}
