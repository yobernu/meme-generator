import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:memes/memes/injection_container.dart' as di;
import 'package:memes/memes/presentation/navigation/meme_navigation.dart';
import 'package:memes/memes/presentation/provider[bloc]/meme_bloc.dart';
import 'package:get_it/get_it.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await di.init();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => GetIt.instance<MemeBloc>(),
      child: MaterialApp(
        title: 'Flutter Demo',
        theme: ThemeData(
          primaryColor: Color.fromARGB(255, 117, 37, 198),
          colorScheme: ColorScheme.fromSeed(
            seedColor: Color.fromARGB(255, 117, 37, 198),
          ),
        ),
        debugShowCheckedModeBanner: false,
        onGenerateRoute: Navigation.generateRoute,
        initialRoute: '/',
      ),
    );
  }
}



// plans
/* 
1. finish loading-memes , favorites section, and add memes[from local]
2. work on downloading photos on local device ---- let em screenshot 😁

>>>>>>Future<<<<<<
  - share functionality   
  - local cache           ---- done
  - work on other API endpoints

*/