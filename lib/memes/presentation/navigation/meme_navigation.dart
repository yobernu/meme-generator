import 'package:flutter/material.dart';
import 'package:memes/memes/domain/entities/meme.dart';
import 'package:memes/memes/presentation/screens/create_meme.dart';
import 'package:memes/memes/presentation/screens/favorites_screen.dart';
import 'package:memes/memes/presentation/screens/home_screen.dart';
import 'package:memes/memes/presentation/screens/meme_details.dart';
import 'package:memes/memes/presentation/screens/search_screen.dart';
import 'package:memes/memes/presentation/screens/my_memes.dart';

class Navigation {
  static Route<dynamic> generateRoute(RouteSettings settings) {
    switch (settings.name) {
      case '/':
        return MaterialPageRoute(
          builder: (_) => const HomeScreen(),
          settings: settings,
        );
      case '/favorites':
        return MaterialPageRoute(
          builder: (_) => const FavoritesScreen(),
          settings: settings,
        );
      case '/meme-details':
        return MaterialPageRoute(
          // If MemeDetails reads the meme via ModalRoute, you don't need to pass it here
          builder: (_) =>
              MemeDetails(favoriteIds: <String>{}), // mutable set for toggling
          settings: settings, // IMPORTANT
        );

      case '/create-meme':
        {
          // Guard against null or wrong-type arguments to avoid runtime cast errors
          final arg = settings.arguments;
          final meme = arg is Meme ? arg : null;
          return MaterialPageRoute(
            builder: (_) => meme != null
                ? CreateMemeScreen(meme: meme)
                : const HomeScreen(),
            settings: settings,
          );
        }
      case '/search':
        return MaterialPageRoute(
          // If MemeDetails reads the meme via ModalRoute, you don't need to pass it here
          builder: (_) => SearchScreen(), // mutable set for toggling
          settings: settings, // IMPORTANT
        );
      case '/my-memes':
        return MaterialPageRoute(
          // If MemeDetails reads the meme via ModalRoute, you don't need to pass it here
          builder: (_) => MyMemesScreen(), // mutable set for toggling
          settings: settings, // IMPORTANT
        );
      default:
        return MaterialPageRoute(
          builder: (_) => const HomeScreen(),
          settings: settings,
        );
    }
  }
}
