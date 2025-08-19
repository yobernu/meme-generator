import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:memes/memes/domain/entities/meme.dart';
import 'package:memes/memes/presentation/provider%5Bbloc%5D/meme.state.dart';
import 'package:memes/memes/presentation/provider%5Bbloc%5D/meme_bloc.dart';
import 'package:memes/memes/presentation/provider%5Bbloc%5D/meme_event.dart';
import 'package:shared_preferences/shared_preferences.dart';

class MemesCard extends StatefulWidget {
  const MemesCard({super.key});

  @override
  State<MemesCard> createState() => _MemesCardState();
}

class _MemesCardState extends State<MemesCard> {
  final Set<String> favoriteIds = {};

  @override
  void initState() {
    super.initState();
    _loadFavoriteIds();
  }

  Future<void> _loadFavoriteIds() async {
    final prefs = await SharedPreferences.getInstance();
    final ids = prefs.getStringList('favorite_ids') ?? <String>[];
    setState(() {
      favoriteIds
        ..clear()
        ..addAll(ids);
    });
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<MemeBloc, MemeState>(
      builder: (context, state) {
        if (state is MemeLoading) {
          return const Center(child: CircularProgressIndicator());
        }
        if (state is MemeLoaded) {
          return buildMemeList(state.memes);
        } else if (state is MemeError) {
          return Center(child: _buildError(state.message));
        }
        return Container();
      },
    );
  }

  Widget buildMemeList(List<Meme> memes) {
    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: memes.length,
      itemBuilder: (context, index) {
        final meme = memes[index];
        final isFavorite = favoriteIds.contains(meme.id);
        void onPress() {
          Navigator.pushNamed(context, '/meme-details', arguments: meme);
        }

        return MemeCardItem(
          meme: meme,
          favoriteIds: favoriteIds,
          onPress: onPress,
        );
      },
    );
  }

  Widget _buildError(String message) {
    return Text(message);
  }
}

class MemeCardItem extends StatelessWidget {
  final Meme meme;
  final Set<String> favoriteIds;
  final VoidCallback onPress;
  const MemeCardItem({
    super.key,
    required this.meme,
    required this.favoriteIds,
    required this.onPress,
  });
  // build() renders the same card and can use Bloc to dispatch ToggleFavorite

  @override
  Widget build(BuildContext context) {
    final isFavorite = favoriteIds.contains(meme.id);
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: Colors.grey[200],
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          GestureDetector(
            onTap: onPress,
            child: SizedBox(
              height: 240,
              width: double.infinity,
              child: Image.network(
                meme.url,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) =>
                    const Icon(Icons.broken_image),
              ),
            ),
          ),
          const SizedBox(height: 8),
          Text(meme.name, style: const TextStyle(fontSize: 20)),
          Row(
            children: [
              ElevatedButton(
                onPressed: () {
                  context.read<MemeBloc>().add(ToggleFavorite(meme.id));
                  if (isFavorite) {
                    favoriteIds.remove(meme.id);
                  } else {
                    favoriteIds.add(meme.id);
                  }
                },
                child: Icon(
                  isFavorite ? Icons.favorite : Icons.favorite_border,
                  color: isFavorite
                      ? Theme.of(context).colorScheme.primary
                      : Colors.grey,
                ),
              ),
              const Spacer(),
              ElevatedButton(onPressed: () {}, child: const Icon(Icons.share)),
            ],
          ),
        ],
      ),
    );
  }
}
