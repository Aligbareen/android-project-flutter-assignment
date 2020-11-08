import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:english_words/english_words.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:hello_me/LogInPage.dart';


class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Startup Name Generator',
      theme: ThemeData(
        primaryColor: Colors.red,
      ),
      home: RandomWords(),
    );
  }
}

class RandomWords extends StatefulWidget {
  @override
  _RandomWordsState createState() => _RandomWordsState();
}

class _RandomWordsState extends State<RandomWords> {
  bool _loggedIn = false;
  FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final List<WordPair> _suggestions =  <WordPair>[];
  final _saved = Set<WordPair>();
  final TextStyle _biggerFont = const TextStyle(fontSize: 18);
  final GlobalKey<ScaffoldState> _scaffoldKeyDel = new GlobalKey<ScaffoldState>();
  @override
  Widget build(BuildContext context) {
    return Scaffold (                     // Add from here...
      appBar: AppBar(
        title: Text('Startup Name Generator'),
        actions: [
          IconButton(icon: Icon(Icons.favorite), onPressed: _pushSaved),
          IconButton(icon: Icon(_loggedIn? Icons.exit_to_app : Icons.login), onPressed: _loggedIn? _logOut : _pushLogin),
        ],
      ),
      body: _buildSuggestions(),
    );
  }
  _deletionNotImplemented(WordPair pair){
    setState(() {
      _saved.remove(pair);
    });
  }
  void _pushSaved() {
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        // NEW lines from here...
        builder: (BuildContext context) {
          final tiles = _saved.map(
                (WordPair pair) {
              return ListTile(
                title: Text(
                  pair.asPascalCase,
                  style: _biggerFont,
                ),
                trailing: IconButton(icon: Icon(Icons.delete), onPressed: () => _deletionNotImplemented(pair)),
              );
            },
          );
          final divided = ListTile.divideTiles(
            context: context,
            tiles: tiles,
          ).toList();

          return Scaffold(
            key: _scaffoldKeyDel,
            appBar: AppBar(
              title: Text('Saved Suggestions'),
            ),
            body: ListView(children: divided),
          );
        }, // ...to here.
      ),
    );
  }

  void _logOut() async {
    List<Map<String,String>> myFavorites = _saved.map((e) => {"first" : e.first, "second" : e.second}).toList();
    print("********************** new\n");
    print("myFavorites type is : ${myFavorites.runtimeType}");
    await FirebaseFirestore.instance.collection('users').doc(FirebaseAuth.instance.currentUser.uid).set({"favorites" : myFavorites});

    print(myFavorites.runtimeType.toString());
    print(myFavorites.toString());
    await FirebaseAuth.instance.signOut();
    setState(() {
      _saved.clear();
      _loggedIn = false;
    });
  }
  void _pushLogin(){
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        // NEW lines from here...
        builder: (BuildContext context) {
          return LoginScreen(_loggedIn, _saved);
        }, // ...to here.
      ),
    );
  }








  Widget _buildSuggestions() {
    return ListView.builder(
        padding: const EdgeInsets.all(16),
        itemBuilder: (BuildContext _context, int i) {
          if (i.isOdd) {
            return Divider();
          }
          final int index = i ~/ 2;
          if (index >= _suggestions.length) {
            _suggestions.addAll(generateWordPairs().take(10));
          }
          return _buildRow(_suggestions[index]);
        }
    );
  }
  Widget _buildRow(WordPair pair) {
    final alreadySaved = _saved.contains(pair);
    return ListTile(
      title: Text(
        pair.asPascalCase,
        style: _biggerFont,
      ),
      trailing: Icon(
        alreadySaved ? Icons.favorite : Icons.favorite_border,
        color: alreadySaved ? Colors.red : null,
      ),
      onTap: () {
        setState(() {
          if (alreadySaved) {
            _saved.remove(pair);
          } else {
            _saved.add(pair);
          }
        });
      },
    );
  }
}

