import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:memes/memes/presentation/provider%5Bbloc%5D/meme.state.dart';
import 'package:memes/memes/presentation/provider%5Bbloc%5D/meme_bloc.dart';
import 'package:memes/memes/presentation/provider[bloc]/meme_event.dart';
import 'package:shared_preferences/shared_preferences.dart';

class FavoritesScreen extends StatelessWidget {
  const FavoritesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<MemeBloc>().add(const LoadFavorites());
    });
    return Scaffold(
      appBar: AppBar(title: const Text('Favorites')),
      body: FutureBuilder<List<String>>(
        future: _loadFavoriteIds(),
        builder: (context, favSnap) {
          if (favSnap.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          final favoriteIds = favSnap.data ?? const <String>[];
          if (favoriteIds.isEmpty) {
            return const Center(child: Text('No favorites yet'));
          }
          return BlocBuilder<MemeBloc, MemeState>(
            builder: (context, state) {
              if (state is MemeLoading) {
                return const Center(child: CircularProgressIndicator());
              }
              if (state is MemeLoaded) {
                final favorites = state.memes
                    .where((m) => favoriteIds.contains(m.id))
                    .toList();
                if (favorites.isEmpty) {
                  return const Center(child: Text('No favorites found'));
                }
                return ListView.separated(
                  itemCount: favorites.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 12),
                  padding: const EdgeInsets.all(12),
                  itemBuilder: (context, index) {
                    final meme = favorites[index];
                    return GestureDetector(
                      onTap: () {
                        Navigator.pushNamed(
                          context,
                          '/meme-details',
                          arguments: meme,
                        );
                      },
                      child: Container(
                        height: 120,
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: Colors.grey[200],
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            AspectRatio(
                              aspectRatio: 2,
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(8),
                                child: Image.network(
                                  meme.url,
                                  fit: BoxFit.cover,
                                  errorBuilder: (context, error, stackTrace) =>
                                      const Icon(Icons.broken_image),
                                ),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    meme.name,
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: const TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  Row(
                                    children: [
                                      GestureDetector(
                                        onTap: () {
                                          context.read<MemeBloc>().add(
                                            ToggleFavorite(meme.id),
                                          );
                                        },
                                        child: Icon(
                                          Icons.favorite,
                                          color: Theme.of(
                                            context,
                                          ).colorScheme.primary,
                                        ),
                                      ),
                                      const SizedBox(width: 8),
                                      const Spacer(),
                                      const Icon(Icons.share),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                );
              }
              if (state is MemeError) {
                return Center(child: Text(state.message));
              }
              return const SizedBox.shrink();
            },
          );
        },
      ),
    );
  }
}

Future<List<String>> _loadFavoriteIds() async {
  final prefs = await SharedPreferences.getInstance();
  return prefs.getStringList('favorite_ids') ?? <String>[];
}
