import 'package:equatable/equatable.dart';
import 'package:memes/memes/domain/entities/meme.dart';

abstract class MemeState extends Equatable {
  const MemeState();

  @override
  List<Object?> get props => [];
}

class MemeInitial extends MemeState {
  const MemeInitial();
}

class MemeLoading extends MemeState {
  const MemeLoading();
}

class MemeLoaded extends MemeState {
  final List<Meme> memes;

  const MemeLoaded({this.memes = const []});

  @override
  List<Object?> get props => [memes];
}

class MemeError extends MemeState {
  final String message;

  const MemeError(this.message);

  @override
  List<Object?> get props => [message];
}

class MemeCached extends MemeState {
  const MemeCached();
}

class ImageDownloadedSuccess extends MemeState {
  const ImageDownloadedSuccess();
}

class ImageDownloadFailure extends MemeState {
  final String message;

  const ImageDownloadFailure(this.message);

  @override
  List<Object?> get props => [message];
}
