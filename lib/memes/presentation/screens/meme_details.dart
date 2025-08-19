import 'package:flutter/material.dart';
import 'package:memes/memes/domain/entities/meme.dart';
import 'package:memes/memes/presentation/screens/meme_card.dart';

class MemeDetails extends StatelessWidget {
  const MemeDetails({super.key, required this.favoriteIds});

  final Set<String> favoriteIds;

  @override
  Widget build(BuildContext context) {
    final meme = ModalRoute.of(context)!.settings.arguments as Meme;
    return Scaffold(
      appBar: AppBar(title: const Text('about the meme')),
      body: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          children: [
            MemeCardItem(meme: meme, favoriteIds: favoriteIds, onPress: () {}),
            SizedBox(height: 40),
            ElevatedButton(
              onPressed: () {
                Navigator.pushNamed(context, "/create-meme", arguments: meme);
              },
              child: const Text("Make Your own Meme"),
            ),
          ],
        ),
      ),
    );
  }
}
