import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:memes/memes/presentation/provider%5Bbloc%5D/meme_event.dart';
import 'package:memes/memes/presentation/provider[bloc]/meme_bloc.dart';
import 'package:memes/memes/presentation/provider%5Bbloc%5D/meme.state.dart';
import 'package:memes/memes/presentation/screens/meme_card.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  @override
  void initState() {
    super.initState();
    // Load memes when screen initializes
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<MemeBloc>().add(const GetMemesEvent());
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[200],
      body: RefreshIndicator(
        onRefresh: () async {
          // trigger reload
          context.read<MemeBloc>().add(const GetMemesEvent());
          // wait until loaded or error state is emitted
          await context.read<MemeBloc>().stream.firstWhere(
            (state) => state is MemeLoaded || state is MemeError,
          );
        },
        triggerMode: RefreshIndicatorTriggerMode.onEdge,
        backgroundColor: Colors.amber,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 36, 16, 36),
          child: ListView(
            physics: const AlwaysScrollableScrollPhysics(),
            children: [
              Padding(
                padding: EdgeInsets.fromLTRB(16, 36, 16, 0),
                child: SizedBox(
                  // height: 210,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Text(
                            "Memecita",
                            style: TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                              color: Color.fromARGB(255, 130, 61, 199),
                            ),
                            textAlign: TextAlign.start,
                          ),
                          Spacer(),
                          PopUp(),
                        ],
                      ),
                      Row(
                        children: [
                          Text(
                            "Find the ",
                            style: TextStyle(
                              fontSize: 40,
                              fontWeight: FontWeight.bold,
                              color: Color.fromARGB(255, 25, 7, 43),
                            ),
                          ),
                          Text(
                            "Perfect",
                            style: TextStyle(
                              fontSize: 40,
                              fontWeight: FontWeight.bold,
                              color: Color.fromARGB(255, 117, 37, 198),
                            ),
                          ),
                        ],
                      ),
                      Row(
                        children: [
                          Text(
                            "memes for ",
                            style: TextStyle(
                              fontSize: 40,
                              fontWeight: FontWeight.bold,
                              color: Color.fromARGB(255, 25, 7, 43),
                            ),
                          ),
                          Text(
                            "your",
                            style: TextStyle(
                              fontSize: 40,
                              fontWeight: FontWeight.bold,
                              color: Color.fromARGB(255, 117, 37, 198),
                            ),
                          ),
                        ],
                      ),
                      Text(
                        "Content",
                        style: TextStyle(
                          fontSize: 40,
                          fontWeight: FontWeight.bold,
                          color: Color.fromARGB(255, 0, 0, 0),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 30),
              MemesCard(),
            ],
          ),
        ),
      ),
    );
  }
}

class PopUp extends StatefulWidget {
  const PopUp({super.key});

  @override
  State<PopUp> createState() => _PopUpState();
}

class _PopUpState extends State<PopUp> {
  final Set<int> favoriteIndices = {};

  @override
  Widget build(BuildContext context) {
    return PopupMenuButton<String>(
      color: const Color.fromARGB(255, 131, 14, 114),
      borderRadius: BorderRadius.circular(25),
      icon: Icon(Icons.more_vert),
      onSelected: (value) {
        print('Selected: $value');
      },
      itemBuilder: (BuildContext context) => [
        PopupMenuItem(
          value: 'addmeme',
          child: GestureDetector(
            onTap: () {
              Navigator.pushNamed(context, '/create-meme', arguments: null);
            },
            child: Row(
              children: [
                Icon(Icons.person),
                SizedBox(width: 20),
                Text('Add Meme', style: TextStyle(color: Colors.white)),
              ],
            ),
          ),
        ),
        PopupMenuItem(
          value: 'Favorites',
          child: GestureDetector(
            onTap: () {
              Navigator.pushNamed(context, '/favorites');
            },
            child: Row(
              children: [
                Icon(Icons.favorite),
                SizedBox(width: 20),
                Text('see Favorites', style: TextStyle(color: Colors.white)),
              ],
            ),
          ),
        ),
        PopupMenuItem(
          value: 'Share',
          child: Row(
            children: [
              Icon(Icons.share),
              SizedBox(width: 20),
              Text('Share', style: TextStyle(color: Colors.white)),
            ],
          ),
        ),
      ],
    );
  }
}
