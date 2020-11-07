import 'package:firebase_core/firebase_core.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:english_words/english_words.dart';
import 'package:firebase_auth/firebase_auth.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(App());
}

class App extends StatelessWidget {
  final Future<FirebaseApp> _initialization = Firebase.initializeApp();
  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
        future: _initialization,
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return Scaffold(
                body: Center(
                    child: Text(snapshot.error.toString(),
                        textDirection: TextDirection.ltr)));
          }
          if (snapshot.connectionState == ConnectionState.done) {
            return MyApp();
          }
          return Center(child: CircularProgressIndicator());
        },
    );
  }
}

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
  String _password, _username;
  FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final List<WordPair> _suggestions =  <WordPair>[];
  final _saved = Set<WordPair>();
  final TextStyle _biggerFont = const TextStyle(fontSize: 18);
  final GlobalKey<ScaffoldState> _scaffoldKeyDel = new GlobalKey<ScaffoldState>();
  final GlobalKey<ScaffoldState> _scaffoldKeyLog = new GlobalKey<ScaffoldState>();
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
  _deletionNotImplemented(){
    final snackBar = new SnackBar(
      content: new Text("Deletion is not implemented yet"),
      duration: new Duration(seconds: 2),
      backgroundColor: Colors.blue,
    );
    _scaffoldKeyDel.currentState.showSnackBar(snackBar);
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
                trailing: IconButton(icon: Icon(Icons.delete), onPressed: _deletionNotImplemented),
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

  void _logOut(){

  }
  void _pushLogin(){
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        // NEW lines from here...
        builder: (BuildContext context) {
          return Scaffold(
            key: _scaffoldKeyLog,
            appBar: AppBar(
              title: Center(child: Text('Login')),
            ),
            body: _buildLoginScreen(),
          );
        }, // ...to here.
      ),
    );
  }

  Scaffold _buildLoginScreen(){
    return Scaffold(
        resizeToAvoidBottomPadding: false,
        body: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Container(
              child: Container(
                padding: EdgeInsets.fromLTRB(15.0, 50.0, 0.0, 0.0),
                child: Text('Welcome to StartupNames Generator, please log in below',
                    style: TextStyle(
                        fontSize: 20.0, fontWeight: FontWeight.bold)),
              ),
            ),
            Container(
                padding: EdgeInsets.only(top: 35.0, left: 20.0, right: 20.0),
                child: Column(
                  children: <Widget>[
                    TextField(
                      decoration: InputDecoration(
                          labelText: 'EMAIL',
                          labelStyle: TextStyle(
                              fontFamily: 'Montserrat',
                              fontWeight: FontWeight.bold,
                              color: Colors.grey),
                          focusedBorder: UnderlineInputBorder(
                              borderSide: BorderSide(color: Colors.green)
                          )
                      ),
                      onChanged: (String str){
                        _username = str;
                      },
                    ),
                    SizedBox(height: 20.0),
                    TextField(
                      decoration: InputDecoration(
                          labelText: 'PASSWORD',
                          labelStyle: TextStyle(
                              fontFamily: 'Montserrat',
                              fontWeight: FontWeight.bold,
                              color: Colors.grey),
                          focusedBorder: UnderlineInputBorder(
                              borderSide: BorderSide(color: Colors.green)
                          )
                      ),
                      obscureText: true,
                      onChanged: (String str){
                        _password = str;
                      },
                    ),
                    SizedBox(height: 40.0),
                    Container(
                      height: 40.0,
                      child: Center(
                        child: FlatButton(
                          color: Colors.red,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20.0)),
                          padding: EdgeInsets.symmetric(horizontal: 164),
                          onPressed: _loginNotImplemented,
                          child: Text(
                            'Log in',
                            style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                                fontFamily: 'Montserrat'
                            ),
                          ),
                        ),
                      ),
                    ),
                    SizedBox(height: 20.0),
                  ],
                )
            ),
            SizedBox(height: 15.0),
          ],
        )
    );
  }

  Future<void> _loginNotImplemented() async {
    try{
      print("we are here !!!!!!!!!");
      print("user name: ${_username} password: ${_password}");
      UserCredential user = await FirebaseAuth.instance.signInWithEmailAndPassword(email: _username, password: _password);
      print("the user we recived from server is : ${user.toString()}");
      print("*****************************");
      loggedIn();
    }catch(e){
      print("your credentials are incorrect");
      print(e.message);
      final snackBar = new SnackBar(
        content: new Text("There was an error logging into the app"),
        duration: new Duration(seconds: 2),
        backgroundColor: Colors.blue,
      );
      _scaffoldKeyLog.currentState.showSnackBar(snackBar);
    }
  }
  void loggedIn(){
    Navigator.pop(context);
    setState(() {
      _loggedIn = true;
    });
  }

  Widget _buildSuggestions() {
    return ListView.builder(
        padding: const EdgeInsets.all(16),
        // The itemBuilder callback is called once per suggested
        // word pairing, and places each suggestion into a ListTile
        // row. For even rows, the function adds a ListTile row for
        // the word pairing. For odd rows, the function adds a
        // Divider widget to visually separate the entries. Note that
        // the divider may be difficult to see on smaller devices.
        itemBuilder: (BuildContext _context, int i) {
          // Add a one-pixel-high divider widget before each row
          // in the ListView.
          if (i.isOdd) {
            return Divider();
          }

          // The syntax "i ~/ 2" divides i by 2 and returns an
          // integer result.
          // For example: 1, 2, 3, 4, 5 becomes 0, 1, 1, 2, 2.
          // This calculates the actual number of word pairings
          // in the ListView,minus the divider widgets.
          final int index = i ~/ 2;
          // If you've reached the end of the available word
          // pairings...
          if (index >= _suggestions.length) {
            // ...then generate 10 more and add them to the
            // suggestions list.
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