// Import necessary packages
import 'package:english_words/english_words.dart'; // Provides random word pairs
import 'package:flutter/material.dart'; // Flutter framework for UI development
import 'package:provider/provider.dart'; // State management package

void main() {
  runApp(MyApp()); // Entry point of the app, runs the MyApp widget
}

// Root widget of the app
class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => MyAppState(), // Provides app state to the widget tree
      child: MaterialApp(
        title: 'Namer App', // App title
        theme: ThemeData(
          useMaterial3: true, // Enables Material Design 3
          colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue), // Sets theme colors
        ),
        home: MyHomePage(), // Sets the home screen of the app
      ),
    );
  }
}

// Manages the app's state
class MyAppState extends ChangeNotifier {
  var current = WordPair.random(); // Holds the current random word pair

  // Generates a new random word pair
  void getNext() {
    current = WordPair.random();
    notifyListeners(); // Notifies widgets to rebuild
  }

  var favorites = <WordPair>[]; // List of favorite word pairs

  // Adds or removes the current word pair from favorites
  void toggleFavorite() {
    if (favorites.contains(current)) {
      favorites.remove(current);
    } else {
      favorites.add(current);
    }
    notifyListeners(); // Notifies widgets to rebuild
  }
}

// Main screen of the app
class MyHomePage extends StatefulWidget {
  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {

  var selectedIndex = 0; // Tracks the selected tab (Home or Favorites)

  @override
  Widget build(BuildContext context) {

      Widget page; // Determines which page to display
      switch (selectedIndex) {
        case 0:
          page = GeneratorPage(); // Home page
          break;
        case 1:
          page = FavoritesPage(); // Favorites page
          break;
        default:
          throw UnimplementedError('no widget for $selectedIndex');
      }

    return LayoutBuilder(
      builder: (context, constraints) {
        return Scaffold(
          body: Row(
            children: [
              SafeArea(
                child: NavigationRail(
                  extended: constraints.maxWidth >= 600, // Expands navigation rail on wide screens
                  destinations: [
                    NavigationRailDestination(
                      icon: Icon(Icons.home), // Home icon
                      label: Text('Home'), // Home label
                    ),
                    NavigationRailDestination(
                      icon: Icon(Icons.favorite), // Favorites icon
                      label: Text('Favorites'), // Favorites label
                    ),
                  ],
                  selectedIndex: selectedIndex, // Highlights the selected tab
                  onDestinationSelected: (value) {
                    setState(() {
                      selectedIndex = value; // Updates the selected tab
                    });
                  },
                ),
              ),
              Expanded(
                child: Container(
                  color: Theme.of(context).colorScheme.primaryContainer, // Background color
                  child: page, // Displays the selected page
                ),
              ),
            ],
          ),
        );
      }
    );
  }
}

// Displays the home page with random word pairs
class GeneratorPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    var appState = context.watch<MyAppState>(); // Accesses the app state
    var pair = appState.current; // Gets the current word pair

    IconData icon; // Determines the icon to display
    if (appState.favorites.contains(pair)) {
      icon = Icons.favorite; // Filled heart for favorite
    } else {
      icon = Icons.favorite_border; // Empty heart for non-favorite
    }

    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center, // Centers content vertically
        children: [
          BigCard(pair: pair), // Displays the word pair in a styled card
          SizedBox(height: 10), // Adds spacing
          Row(
            mainAxisSize: MainAxisSize.min, // Shrinks row to fit content
            children: [
              ElevatedButton.icon(
                onPressed: () {
                  appState.toggleFavorite(); // Toggles favorite status
                },
                icon: Icon(icon), // Displays the appropriate icon
                label: Text('Like'), // Button label
              ),
              SizedBox(width: 10), // Adds spacing
              ElevatedButton(
                onPressed: () {
                  appState.getNext(); // Generates a new word pair
                },
                child: Text('Next'), // Button label
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// Displays a styled card with the word pair
class BigCard extends StatelessWidget {
  const BigCard({
    super.key,
    required this.pair,
  });

  final WordPair pair; // The word pair to display

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context); // Accesses the app's theme

    final style = theme.textTheme.displayMedium!.copyWith(
      color: theme.colorScheme.onPrimary, // Text color
      fontWeight: FontWeight.w900, // Bold text
      shadows: const [
        Shadow(
          color: Colors.black, // Shadow color
          offset: Offset(2, 2), // Shadow offset
          blurRadius: 3, // Shadow blur
        ),
      ],
      fontSize: 50, // Font size
    );

    return Card(
      color: theme.colorScheme.primary, // Card background color
      child: Padding(
        padding: const EdgeInsets.all(20.0), // Padding inside the card
        child: Text(
          pair.asLowerCase, // Displays the word pair in lowercase
          style: style, // Applies the text style
          semanticsLabel: "${pair.first} ${pair.second}", // Accessibility label
        ),
      ),
    );
  }
}

// Displays a scrollable list of favorite word pairs
class FavoritesPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    var appState = context.watch<MyAppState>(); // Accesses the app state
    var favorites = appState.favorites; // Gets the list of favorites

    if (favorites.isEmpty) {
      return Center(
        child: Text('No favorites yet.'), // Message when no favorites exist
      );
    }

    return ListView(
      children: [
        Padding(
          padding: const EdgeInsets.all(20),
          child: Text(
            'You have ${favorites.length} favorites:'), // Displays the number of favorites
        ),
        for (var pair in favorites) // Loops through the favorites list
          ListTile(
            leading: Icon(Icons.favorite), // Favorite icon
            title: Text(pair.asPascalCase), // Displays the word pair
          ),
      ],
    );
  }
}