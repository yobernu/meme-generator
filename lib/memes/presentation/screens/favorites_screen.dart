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
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.pop(context);
        },
        tooltip: 'Home',
        elevation: 6,
        child: const Icon(Icons.home, size: 32),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      bottomNavigationBar: BottomAppBar(
        shape: const CircularNotchedRectangle(),
        notchMargin: 8.0,
        height: 64,
        color: Colors.white,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              IconButton(
                tooltip: 'Favorites',
                icon: const Icon(Icons.favorite),
                onPressed: () {
                  // already on favorites; optionally pop to avoid duplicates
                },
              ),
              IconButton(
                tooltip: 'Share',
                icon: const Icon(Icons.share),
                onPressed: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Share coming soon')),
                  );
                },
              ),
            ],
          ),
        ),
      ),
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
                    return FavoriteMemeCard(
                      id: meme.id,
                      name: meme.name,
                      url: meme.url,
                      onTap: () {
                        Navigator.pushNamed(
                          context,
                          '/create-meme',
                          arguments: meme,
                        );
                      },
                      onToggleFavorite: () {
                        context.read<MemeBloc>().add(ToggleFavorite(meme.id));
                      },
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

class FavoriteMemeCard extends StatelessWidget {
  final String id;
  final String name;
  final String url;
  final VoidCallback onTap;
  final VoidCallback onToggleFavorite;

  const FavoriteMemeCard({
    super.key,
    required this.id,
    required this.name,
    required this.url,
    required this.onTap,
    required this.onToggleFavorite,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
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
                  url,
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
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    name,
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
                        onTap: onToggleFavorite,
                        child: Icon(
                          Icons.favorite,
                          color: Theme.of(context).colorScheme.primary,
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
  }
}

Future<List<String>> _loadFavoriteIds() async {
  final prefs = await SharedPreferences.getInstance();
  return prefs.getStringList('favorite_ids') ?? <String>[];
}
