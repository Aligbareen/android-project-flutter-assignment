import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:english_words/english_words.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:hello_me/LogInPage.dart';
import 'package:hello_me/SavedPage.dart';
import 'package:snapping_sheet/snapping_sheet.dart';
import 'dart:ui' as ui;

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
  var _controller = SnappingSheetController();
  final TextStyle _biggerFont = const TextStyle(fontSize: 18);
  double _blur = 0.0;
  bool _loggedIn = false;
  bool processing = false;
  final List<WordPair> _suggestions =  <WordPair>[];
  var _saved = Set<WordPair>();
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
      body:
      (processing)?
      Center(child: Column(children: [CircularProgressIndicator(backgroundColor: Colors.lightGreenAccent)], crossAxisAlignment: CrossAxisAlignment.center, mainAxisAlignment: MainAxisAlignment.center))
          :
      (_loggedIn)?
      SnappingSheet(
        snappingSheetController: _controller,
        //initSnapPosition: ,
        child: Stack(
          fit: StackFit.expand,
          children: [
            _buildSuggestions(),
            BackdropFilter(
              filter: ui.ImageFilter.blur(
                sigmaX: _blur,
                sigmaY: _blur,
              ),
              child: Container(
                color: Colors.transparent,
              ),
            )
          ],
        ),
        //sheetAbove: SnappingSheetContent(child: _buildSuggestions()),
        sheetBelow: SnappingSheetContent(child: Container(
            color: Colors.white, child: Text("welcome)"),),draggable: true),
        grabbing: Container(
          color: Colors.grey,
          child: Padding(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children:[
                    Text("Welcome back, " + FirebaseAuth.instance.currentUser.email, style: TextStyle(fontSize: 18.0),textAlign: TextAlign.left,),
                    Align(child:Icon(Icons.keyboard_arrow_up_rounded,size: 30.0,), alignment: Alignment.centerRight,)
                  ]

              ),
            padding: EdgeInsets.fromLTRB(10, 0, 10, 0 ),
          ),
        ),
        onMove: (moveAmount){
          if(moveAmount > 5 && _blur == 0.0) {
            setState(() {
              _blur = 8.0;
            });
          }
          else if(moveAmount <= 5 && _blur != 0.0){
            setState(() {
              _blur = 0.0;
            });
          }
        },
        onSnapBegin: (){
        },
        onSnapEnd: (){
        },
        snapPositions: const [
          SnapPosition(positionFactor: 0, snappingCurve: Curves.elasticOut, snappingDuration: Duration(milliseconds: 750)),
          SnapPosition(positionFactor: 0.2),
        ],
        initSnapPosition: SnapPosition(positionFactor: 0),
      )
          :
      _buildSuggestions(),
    );
  }

  void _pushSaved() async {
    await Navigator.of(context).push(
        MaterialPageRoute(
          // NEW lines from here...
            builder: (BuildContext context)
            {
              return SavedPage(_saved);
            }
        ));
    setState(() {

    });
  }

  void _logOut() async {
    setState(() {
      processing = true;
    });
    List<Map<String,String>> myFavorites = _saved.map((e) => {"first" : e.first, "second" : e.second}).toList();
    await FirebaseFirestore.instance.collection('users').doc(FirebaseAuth.instance.currentUser.uid).set({"favorites" : myFavorites});
    await FirebaseAuth.instance.signOut();
    setState(() {
      _saved.clear();
      _loggedIn = false;
      processing = false;
    });
  }
  void _pushLogin()  async {
    _loggedIn = await Navigator.of(context).push(
      MaterialPageRoute(
        builder: (BuildContext context) {
          return LoginScreen(_saved);
        },
      ),
    );
    setState(() {
    }
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

