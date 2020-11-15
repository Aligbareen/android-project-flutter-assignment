import 'package:flutter/material.dart';
import 'package:english_words/english_words.dart';

class SavedPage extends StatefulWidget {
  final Set<WordPair> saved;
  SavedPage(this.saved);
  @override
  _SavedPageState createState() => _SavedPageState(saved);
}


class _SavedPageState extends State<SavedPage> {

  final Set<WordPair> saved;
  final TextStyle _biggerFont = const TextStyle(fontSize: 18);
  _SavedPageState(this.saved);

  @override
  Widget build(BuildContext context) {
    final tiles =saved.map(
          (WordPair pair) {
        return ListTile(
          title: Text(
            pair.asPascalCase,
            style: _biggerFont,
          ),
          trailing: IconButton(
              icon: Icon(Icons.delete),
              onPressed: () => _deletionNotImplemented(pair)
          ),
        );
      },
    );
    final divided = ListTile.divideTiles(
      context: context,
      tiles: tiles,
    ).toList();
    return Scaffold(
      appBar: AppBar(
        title: Text('Saved Suggestions'),
      ),
      body: ListView(children: divided),
    );
  }

  _deletionNotImplemented(WordPair pair){
    setState(() {
      saved.remove(pair);
    });
  }

}
