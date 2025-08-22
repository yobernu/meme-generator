import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:memes/core/services/download_meme.dart' as download_service;
import 'package:memes/core/widgets/download_progress_dialog.dart';
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

  // Update the buildMemeList method in _MemesCardState
  Widget buildMemeList(List<Meme> memes) {
    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: memes.length,
      itemExtent: 300, // Fixed height for better performance
      addAutomaticKeepAlives: true, // Maintains state of off-screen items
      itemBuilder: (context, index) {
        final meme = memes[index];
        return MemeCardItem(
          key: ValueKey(meme.id), // Important for list diffing
          meme: meme,
          favoriteIds: favoriteIds,
          onPress: () =>
              Navigator.pushNamed(context, '/create-meme', arguments: meme),
        );
      },
    );
  }

  Widget _buildError(String message) {
    return Text(message);
  }
}

Future<download_service.DownloadResult> _downloadMemeWithRetry(
  String url,
  BuildContext context, {
  int maxRetries = 2,
}) async {
  int attempt = 0;
  download_service.DownloadResult? result;

  while (attempt < maxRetries) {
    attempt++;
    result = await download_service.downloadMeme(
      url,
      onProgress: (received, total) {
        // Progress updates are handled by the dialog
      },
    );

    // If successful or not a network error, return the result
    if (result.status == download_service.DownloadStatus.success ||
        result.status == download_service.DownloadStatus.permissionDenied ||
        result.status == download_service.DownloadStatus.saveFailed) {
      break;
    }

    // If it's the last attempt, don't wait before returning
    if (attempt >= maxRetries) break;

    // Wait before retrying
    await Future.delayed(const Duration(seconds: 1));
  }

  return result!;
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
          _buildMemeImage(),
          const SizedBox(height: 8),
          _buildMemeName(),
          const SizedBox(height: 8),
          _buildActionButtons(context, isFavorite),
        ],
      ),
    );
  }

  Widget _buildMemeImage() {
    return GestureDetector(
      onTap: onPress,
      child: SizedBox(
        height: 240,
        width: double.infinity,
        child: Image.network(
          meme.url,
          fit: BoxFit.cover,
          cacheWidth: 800, // Optimize memory usage
          loadingBuilder: (context, child, loadingProgress) {
            if (loadingProgress == null) return child;
            return const Center(child: CircularProgressIndicator());
          },
          errorBuilder: (context, error, stackTrace) =>
              const Center(child: Icon(Icons.broken_image, size: 48)),
        ),
      ),
    );
  }

  Widget _buildMemeName() {
    return Text(
      meme.name,
      style: const TextStyle(fontSize: 20),
      maxLines: 1,
      overflow: TextOverflow.ellipsis,
    );
  }

  Widget _buildActionButtons(BuildContext context, bool isFavorite) {
    return Row(
      children: [
        IconButton(
          icon: Icon(
            isFavorite ? Icons.favorite : Icons.favorite_border,
            color: isFavorite
                ? Theme.of(context).colorScheme.primary
                : Colors.grey,
          ),
          onPressed: () => _toggleFavorite(context, isFavorite),
        ),
        const Spacer(),
        IconButton(
          icon: const Icon(Icons.download),
          onPressed: () => _downloadMeme(context),
        ),
        const SizedBox(width: 8),
        IconButton(icon: const Icon(Icons.share), onPressed: () {}),
      ],
    );
  }

  void _toggleFavorite(BuildContext context, bool isFavorite) {
    context.read<MemeBloc>().add(ToggleFavorite(meme.id));
    // Local state update for immediate feedback
    if (isFavorite) {
      favoriteIds.remove(meme.id);
    } else {
      favoriteIds.add(meme.id);
    }
  }

  Future<void> _downloadMeme(BuildContext context) async {
    final success = await showDownloadProgressDialog(
      context: context,
      downloadFuture: _downloadMemeWithRetry(meme.url, context).then((result) {
        if (result.status == download_service.DownloadStatus.permissionDenied) {
          throw Exception('Permission denied');
        } else if (!result.isSuccess) {
          throw Exception(result.errorMessage ?? 'Download failed');
        }
        return result;
      }),
      fileName: 'meme_${DateTime.now().millisecondsSinceEpoch}.jpg',
    );

    if (context.mounted && success == true) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Meme saved to gallery ✅')));
    }
  }
}
