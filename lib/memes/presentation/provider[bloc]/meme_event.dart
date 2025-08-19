import 'package:equatable/equatable.dart';
import 'package:memes/memes/data/models/meme_model.dart';
import 'package:memes/memes/domain/entities/meme_caption.dart';

abstract class MemeEvent extends Equatable {
  const MemeEvent();

  @override
  List<Object?> get props => [];
}

class MemeEventInitialEvent extends MemeEvent {
  const MemeEventInitialEvent();
}

class GetMemesEvent extends MemeEvent {
  const GetMemesEvent();
}

class CreateMemeEvent extends MemeEvent {
  final CreateMemeRequest meme;

  const CreateMemeEvent({required this.meme});

  @override
  List<Object?> get props => [meme];
}

class CachedMemeEvent extends MemeEvent {
  final MemeModel meme;

  const CachedMemeEvent({required this.meme});

  @override
  List<Object?> get props => [meme];
}

abstract class FavoritesEvent extends MemeEvent {
  const FavoritesEvent();
}

class ToggleFavorite extends FavoritesEvent {
  final String id;
  const ToggleFavorite(this.id);

  @override
  List<Object?> get props => [id];
}

class LoadFavorites extends FavoritesEvent {
  const LoadFavorites();
}

// Download feature removed
