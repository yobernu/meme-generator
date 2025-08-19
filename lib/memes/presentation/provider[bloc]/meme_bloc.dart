import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:memes/core/usecase/usecase.dart';
import 'package:memes/memes/presentation/provider%5Bbloc%5D/meme.state.dart';
import 'package:memes/memes/presentation/provider%5Bbloc%5D/meme_event.dart';
import 'package:memes/memes/domain/usecases/get_memes_usecases.dart';
import 'package:memes/memes/domain/usecases/create_meme_usecase.dart';
import 'package:memes/memes/domain/usecases/cache_meme.dart';
import 'package:shared_preferences/shared_preferences.dart';

class MemeBloc extends Bloc<MemeEvent, MemeState> {
  final GetMemesUseCase getMemesUseCase;
  final CreateMemeUseCase createMemeUseCase;
  final CacheMemeUseCase cacheMemeUseCase;

  MemeBloc({
    required this.getMemesUseCase,
    required this.createMemeUseCase,
    required this.cacheMemeUseCase,
  }) : super(MemeInitial()) {
    on<GetMemesEvent>(_onGetMemesEvent);
    on<CreateMemeEvent>(_onCreateMemeEvent);
    on<CachedMemeEvent>(_onCachedMemeEvent);
    on<ToggleFavorite>(_onToggleFavorite);
    on<LoadFavorites>(_onLoadFavorites);
  }

  Future<void> _onGetMemesEvent(
    GetMemesEvent event,
    Emitter<MemeState> emit,
  ) async {
    emit(const MemeLoading());
    final result = await getMemesUseCase(const NoParams());
    result.fold(
      (failure) => emit(MemeError(failure.message)),
      (memes) => emit(MemeLoaded(memes: memes)),
    );
  }

  Future<void> _onCreateMemeEvent(
    CreateMemeEvent event,
    Emitter<MemeState> emit,
  ) async {
    emit(const MemeLoading());
    final result = await createMemeUseCase(CreateMemeParams(meme: event.meme));
    result.fold(
      (failure) => emit(MemeError(failure.message)),
      (_) => emit(const MemeLoaded()),
    );
  }

  Future<void> _onCachedMemeEvent(
    CachedMemeEvent event,
    Emitter<MemeState> emit,
  ) async {
    emit(const MemeLoading());
    final result = await cacheMemeUseCase(CacheMemeParams(meme: event.meme));
    result.fold(
      (failure) => emit(MemeError(failure.message)),
      (_) => emit(const MemeCached()),
    );
  }

  Future<void> _onToggleFavorite(
    ToggleFavorite event,
    Emitter<MemeState> emit,
  ) async {
    final prefs = await SharedPreferences.getInstance();
    final ids = prefs.getStringList('favorite_ids') ?? <String>[];
    if (ids.contains(event.id)) {
      ids.remove(event.id);
    } else {
      ids.add(event.id);
    }
    await prefs.setStringList('favorite_ids', ids);

    // Re-emit to trigger UI rebuild if we're on MemeLoaded
    final current = state;
    if (current is MemeLoaded) {
      emit(MemeLoaded(memes: List.of(current.memes)));
    }
  }

  Future<void> _onLoadFavorites(
    LoadFavorites event,
    Emitter<MemeState> emit,
  ) async {
    // This event ensures favorites are available in prefs; nothing to emit here
    // since FavoritesScreen reads prefs directly. Keep for future extension.
    await SharedPreferences.getInstance();
    final current = state;
    if (current is MemeLoaded) {
      // No state change, but we can re-emit to refresh UI if needed.
      emit(MemeLoaded(memes: List.of(current.memes)));
    }
  }

}
