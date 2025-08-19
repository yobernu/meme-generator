import 'package:flutter_test/flutter_test.dart';
import 'package:memes/core/usecase/usecase.dart';
import 'package:memes/memes/data/models/meme_model.dart';
import 'package:memes/memes/domain/entities/meme.dart';
import 'package:memes/memes/domain/entities/meme_caption.dart';
import 'package:memes/memes/domain/repository/repository.dart';
import 'package:memes/memes/domain/usecases/create_meme_usecase.dart';
import 'package:memes/memes/domain/usecases/get_memes_usecases.dart';
import 'package:mocktail/mocktail.dart';
import 'package:dartz/dartz.dart';

class MockMemesRepository extends Mock implements MemesRepository {}

void main() {
  final repository = MockMemesRepository();
  final usecaseGetmeme = GetMemesUseCase(repository);
  final usecaseCreatememe = CreateMemeUseCase(repository);
  final meme = MemeModel(
    id: 'id',
    name: 'name',
    url: 'url',
    width: 1,
    height: 1,
    boxCount: 1,
    captions: 1,
  );
  final tmeme = [meme];
  final memeRequest = CreateMemeRequest(
    templateId: 'id',
    username: 'username',
    password: 'password',
    boxes: [
      MemeCaption(
        text: 'text',
        x: 1,
        y: 1,
        width: 1,
        height: 1,
        color: '',
        outlineColor: '',
      ),
    ],
  );

  test('Should create Meme successfully', () async {
    when(
      () => repository.createMeme(memeRequest),
    ).thenAnswer((_) async => Right(MemeResult(url: 'url', success: true)));
    final result = await usecaseCreatememe.call(
      CreateMemeParams(meme: memeRequest),
    );
    expect(result, Right(MemeResult(url: 'url', success: true)));
    expect(result.isRight(), true);
    expect(result.fold((l) => l, (r) => r), isA<MemeResult>());
  });

  test('Should get Meme successfully', () async {
    when(() => repository.getMemes()).thenAnswer((_) async => Right(tmeme));
    final result = await usecaseGetmeme.call(NoParams());
    expect(result, Right(tmeme));
    expect(result.isRight(), true);
    expect(result.fold((l) => l, (r) => r), isA<List<Meme>>());
  });
}
