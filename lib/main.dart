import 'package:english_words/english_words.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:provider/provider.dart';

//In its current form, it only tells Flutter to run the app defined in MyApp.
void main() {
  runApp(MyApp());
}

//The code in MyApp sets up the whole app. It creates the app-wide state (more on this later), 
//names the app, defines the visual theme, and sets the "home" widget—the starting point of your app.
class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => MyAppState(),
      child: MaterialApp(
        title: 'Namer App',
        theme: ThemeData(
          useMaterial3: true,
          colorScheme: ColorScheme.fromSeed(seedColor: Colors.green),
        ),
        home: MyHomePage(),
      ),
    );
  }
}

//MyAppState defines the data the app needs to function.
//The state class extends ChangeNotifier, which means that it can notify others about its own changes. For example, 
//if the current word pair changes, some widgets in the app need to know.
//The state is created and provided to the whole app using a ChangeNotifierProvider
//This allows any widget in the app to get hold of the state.

class MyAppState extends ChangeNotifier {
  var current = WordPair.random();

  //Add
  void getNext(){
    current = WordPair.random();
    notifyListeners();
  }

  //add like fav method
  var favorites = <WordPair> [];

  void toogleFavorite(){
    if (favorites.contains(current)) {
      favorites.remove(current);
    } else{
      favorites.add(current);
    }
    notifyListeners();
  }
}
// ...

class MyHomePage extends StatefulWidget {
  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  var selectedIndex = 0; //add pro to track 

  @override
  Widget build(BuildContext context) {
    //for using selectedIndex
    Widget page;
    switch (selectedIndex){
      case 0:
      page = GeneratorPage();
      
      case 1:
      page = FavoritesPage();
      
      default:
      throw UnimplementedError('no widget for $selectedIndex');
    }

    return LayoutBuilder(
      builder: (context,Constraints) {
        return Scaffold(
          body: Row(
            children: [
              SafeArea(
                child: NavigationRail(
                  extended: Constraints.maxWidth >=600,
                  destinations: [
                    NavigationRailDestination(
                      icon: Icon(Icons.home),
                      label: Text('Home'),
                    ),
                    NavigationRailDestination(
                      icon: Icon(Icons.favorite),
                      label: Text('Favorites'),
                    ),
                  ],
                  selectedIndex: selectedIndex,
                  onDestinationSelected: (value) {
                    setState(() {
                      selectedIndex = value;
                    });
                  },
                ),
              ),
              Expanded(
                child: Container(
                  color: Theme.of(context).colorScheme.primaryContainer,
                  child: page,
                  
                ),
              ),
            ],
          ),
        );
      }
    );
  }
}

// ...

class FavoritesPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    var appState = context.watch<MyAppState>();

    if (appState.favorites.isEmpty) {
      return Center(
        child: Text('No favorites yet.'),
      );
    }

    return ListView(
      children: [
        Padding(
          padding: const EdgeInsets.all(20),
          child: Text('You have '
              '${appState.favorites.length} favorites:'),
        ),
        for (var pair in appState.favorites)
          ListTile(
            leading: Icon(Icons.favorite),
            title: Text(pair.asLowerCase),
          ),
      ],
    );
  }
}


class GeneratorPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    var appState = context.watch<MyAppState>();
    var pair = appState.current;

    IconData icon;
    if (appState.favorites.contains(pair)) {
      icon = Icons.favorite;
    } else {
      icon = Icons.favorite_border;
    }

    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          BigCard(pair: pair),
          SizedBox(height: 10),
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              ElevatedButton.icon(
                onPressed: () {
                  appState.toogleFavorite();
                },
                icon: Icon(icon),
                label: Text('Like'),
              ),
              SizedBox(width: 10),
              ElevatedButton(
                onPressed: () {
                  appState.getNext();
                },
                child: Text('Next'),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// ...

//text randomnya
class BigCard extends StatelessWidget {
  const BigCard({
    super.key,
    required this.pair,
  });

  final WordPair pair;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);       // ← Add this.

    final style = theme.textTheme.displayLarge!.copyWith(
      color: theme.colorScheme.onPrimary,); // fix  color hard to read

    return Card(
      elevation: 15,
      color: theme.colorScheme.primary,    // ← And also this.
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Text(
          pair.asLowerCase,
           style: style,
           semanticsLabel: "${pair.first} ${pair.second}",),
      ),
    );
  }
}