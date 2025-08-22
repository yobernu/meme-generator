import 'dart:io';

import 'package:flutter/material.dart';
import 'package:memes/core/services/save_media.dart' as SaveMedia;

class MyMemesScreen extends StatefulWidget {
  const MyMemesScreen({super.key});

  @override
  State<MyMemesScreen> createState() => _MyMemesScreenState();
}

class _MyMemesScreenState extends State<MyMemesScreen> {
  late Future<List<String>> _pathsFuture;

  @override
  void initState() {
    super.initState();
    _pathsFuture = SaveMedia.listAppGalleryMemes();
  }

  Future<void> _refresh() async {
    setState(() {
      _pathsFuture = SaveMedia.listAppGalleryMemes();
    });
    await _pathsFuture;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('My Memes'),
        actions: [
          IconButton(
            tooltip: 'Refresh',
            onPressed: _refresh,
            icon: const Icon(Icons.refresh),
          ),
        ],
      ),
      body: FutureBuilder<List<String>>(
        future: _pathsFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          final paths = snapshot.data ?? const <String>[];
          if (paths.isEmpty) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(24.0),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: const [
                    Icon(Icons.photo_library_outlined, size: 48),
                    SizedBox(height: 12),
                    Text('No memes saved yet'),
                    SizedBox(height: 8),
                    Text(
                      'Create a meme and tap Save to add it here.',
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
            );
          }
          return RefreshIndicator(
            onRefresh: _refresh,
            child: GridView.builder(
              padding: const EdgeInsets.all(12),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 3,
                mainAxisSpacing: 8,
                crossAxisSpacing: 8,
              ),
              itemCount: paths.length,
              itemBuilder: (context, index) {
                final path = paths[index];
                return GestureDetector(
                  onTap: () => _showPreview(context, path),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: Image.file(
                      File(path),
                      fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) => const ColoredBox(
                        color: Colors.black12,
                        child: Center(child: Icon(Icons.broken_image)),
                      ),
                    ),
                  ),
                );
              },
            ),
          );
        },
      ),
    );
  }

  void _showPreview(BuildContext context, String path) {
    showDialog(
      context: context,
      builder: (context) => Dialog(
        clipBehavior: Clip.antiAlias,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: Stack(
          children: [
            InteractiveViewer(
              minScale: 1,
              maxScale: 4,
              child: Image.file(File(path), fit: BoxFit.contain),
            ),
            Positioned(
              top: 8,
              right: 8,
              child: IconButton(
                onPressed: () => Navigator.pop(context),
                icon: const Icon(Icons.close),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
