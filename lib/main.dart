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

// another way to provite a state/variablestorage to widgets.
// this creates a state for this MyHomePage widget only
// this also create a new private class _MyHomePageState widget (_ means private in dart)
// by creating this // state change method setState will be accessable
class MyHomePage extends StatefulWidget {
  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

// private state class for MyHomePage widget
// it has both the UI/Widgets and variables+methodToChangeVariables(GetterSetters)
// this is only accessable here and not in its child??? //TODO??
// setState is like notifyListeners in stateless app's shared state, to let ui render the new changes
// (unlike a stateless widget, where an nameIndependent state class is created
// and is accessed by all child elements via the changenotifier's notifylisteners)
class _MyHomePageState extends State<MyHomePage> {
  // variables tracked in state
  var selectedIndex = 0;

  @override
  Widget build(BuildContext context) {
    // some helper code to generate ui elements for this widget
    Widget page;
    switch (selectedIndex) {
      case 0:
        page = RandomWordGeneratorPage();
        break;
      case 1:
        // page = Placeholder(); // used while development // draws a rect with cross on place intended to be filled with a meaningful widget later
        page = SelectedFavoutitesPage();
        break;
      default:
        //Applying the fail-fast principle, the switch statement also makes sure to throw an error if selectedIndex is neither 0 or 1. This helps prevent bugs down the line. If you ever add a new destination to the navigation rail and forget to update this code, the program crashes in development (as opposed to letting you guess why things don't work, or letting you publish a buggy code into production).
        throw UnimplementedError('no widget for $selectedIndex');
    }

    // wrapping with layout builder here to find out screen constraints and space available to this widget
    return LayoutBuilder(builder: (context, constraints) {
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
                selectedIndex: selectedIndex,
                extended: constraints.maxWidth >= 400,
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
            )
          ],
        ),
      );
    });
  }
}

class SelectedFavoutitesPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    var appState = context.watch<MyAppState>();

    if (appState.favouriteWords.isEmpty) {
      return Center(
        child: Text('No favourites words yet!'),
      );
    }

    return Center(
      child: ListView(children: [
        Padding(
          padding: EdgeInsets.all(7),
          child: Text(
            'You have ${appState.favouriteWords.length} favourite words so far!',
          ),
        ),
        for (var favWord in appState.favouriteWords)
          ListTile(
            leading: Icon(Icons.local_florist),
            title: Text(favWord.asSnakeCase),
          ),
      ]),
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
