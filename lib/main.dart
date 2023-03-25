import 'dart:math';

import 'package:english_words/english_words.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

void main() {
  runApp(MyApp());
}

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
          // colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepOrange),
          colorScheme: ColorScheme.fromSeed(seedColor: Colors.pink),
        ),
        home: MyHomePage(),
      ),
    );
  }
}

// this state will store the variables/state that can be
// listened by any child object/widget (for that we need to
// plug a state change notifier(ChangeNotifier widget) in parent,
// and plug a state listeners in childs(watch method) ).
// Also have methods to change variable values
class MyAppState extends ChangeNotifier {
  var current = WordPair.random();
  var randomWordTwo = nouns.elementAt(Random().nextInt(100));

  var randomPreposition = ["on", "in", "over", "through", "of", "at"]
      .elementAt(Random().nextInt(6));

  void getNextRandomWord() {
    current = WordPair.random();
    notifyListeners();
  }

  // var favouriteWords = <WordPair>[];// for list implementation of the collection
  var favouriteWords = <WordPair>{}; // for set implementation of the collection

  void flipFavourite() {
    if (isCurrentMarkedFavourite()) {
      favouriteWords.remove(current);
    } else {
      favouriteWords.add(current);
    }
    notifyListeners();
  }

  bool isCurrentMarkedFavourite() {
    return favouriteWords.contains(current);
  }
}

class MyHomePage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Row(
        children: [
          SafeArea(
            child: NavigationRail(
              destinations: [
                NavigationRailDestination(
                  icon: Icon(Icons.home),
                  label: Text('Home'),
                ),
                NavigationRailDestination(
                  icon: Icon(Icons.favorite),
                  label: Text('Favourites'),
                ),
              ],
              selectedIndex: 0,
              extended: false,
            ),
          ),
          Expanded(
            child: Container(
              color: Theme.of(context).colorScheme.primaryContainer,
              child: RandomWordGeneratorPage(),
            ),
          )
        ],
      ),
    );
  }
}

class RandomWordGeneratorPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    var appState = context.watch<MyAppState>();
    var currentRandomWord = appState.current;
    var currentRandomPreposition = appState.randomPreposition;

    var theme = Theme.of(context);

    IconData currentFavIcon = appState.isCurrentMarkedFavourite()
        ? Icons.favorite_outlined
        : Icons.favorite_border_outlined;

    return Center(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            // color: Colors.amber[400],
            color: theme.colorScheme.primaryContainer,
            child: Text(
                'A random : ${appState.randomWordTwo} ${currentRandomPreposition}'),
          ),
          SizedBox(
            height: 10, //just added to create visual gap
          ),
          Container(
            // color: theme.colorScheme.surface,
            color: theme.colorScheme.primaryContainer,
            child: BigCard(currentRandomWord: currentRandomWord),
          ),
          SizedBox(
            height: 10, //just added to create visual gap
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              ElevatedButton.icon(
                onPressed: appState.flipFavourite,
                icon: Icon(currentFavIcon),
                label: Text('Favourite'),
              ),
              SizedBox(
                width: 10,
              ),
              ElevatedButton(
                  // onPressed: () {
                  //   print('this button is pressed!');
                  // },
                  onPressed: () {
                    appState.getNextRandomWord();
                  },
                  child: Text('Next??')),
            ],
          )
        ],
      ),
    );
  }
}

class BigCard extends StatelessWidget {
  const BigCard({
    super.key,
    required this.currentRandomWord,
  });

  final WordPair currentRandomWord;

  @override
  Widget build(BuildContext context) {
    var theme = Theme.of(context);

    var textStyle = theme.textTheme.displayMedium!
        .copyWith(color: theme.colorScheme.onPrimary);

    return Card(
      color: theme.colorScheme.primary,
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Text(
          currentRandomWord.asSnakeCase,
          style: textStyle,
          semanticsLabel:
              "${currentRandomWord.first} ${currentRandomWord.second}", // this is for accessablity //a reader reads the normal snakecase wala string // but the talkback service will pronunce this string value instead for visually challenged person
        ),
      ),
    );
  }
}
