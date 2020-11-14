import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:english_words/english_words.dart';
import 'package:firebase_auth/firebase_auth.dart';

class LoginScreen extends StatefulWidget {
  final saved;
  LoginScreen(this.saved);
  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  String _password, _username;
  bool processing = false;
  bool loggedIn = false;
  final GlobalKey<ScaffoldState> _scaffoldKeyLog = new GlobalKey<ScaffoldState>();
  _LoginScreenState();
  @override
  Widget build(BuildContext context) {
    return WillPopScope(child:Scaffold(
      key: _scaffoldKeyLog,
      //resizeToAvoidBottomPadding: false,
      appBar: AppBar(
        title: Center(child: Text('Login')),
      ),
      body: Builder(
          builder: (BuildContext context)
          {
            return
              (processing)?
              Center(child: Column(children: [CircularProgressIndicator(backgroundColor: Colors.lightGreenAccent)], crossAxisAlignment: CrossAxisAlignment.center, mainAxisAlignment: MainAxisAlignment.center))
                  :
              SingleChildScrollView(
                child:
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Container(
                      child: Container(
                        padding: EdgeInsets.fromLTRB(15.0, 50.0, 0.0, 0.0),
                        child: Text(
                            'Welcome to StartupNames Generator, please log in below',
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
                              onChanged: (String str) {
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
                              onChanged: (String str) {
                                _password = str;
                              },
                            ),
                            SizedBox(height: 40.0),
                            Container(
                              height: 40.0,
                              child: Center(
                                child: FlatButton(
                                  color: Colors.red,
                                  shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(20.0)),
                                  padding: EdgeInsets.symmetric(horizontal: (MediaQuery.of(context).size.width)/3),
                                  onPressed: ()=>_loginNotImplemented(context),
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
      ),
    ),
        onWillPop: (){
            Navigator.pop(context,loggedIn);
            return Future.value(false);
        });
  }


  Future<void> _loginNotImplemented(context) async {
    try{
      setState(() {
        processing = true;
      });
      await FirebaseAuth.instance.signInWithEmailAndPassword(email: _username, password: _password);
      whenLoggedIn();
    }catch(e){
      setState(() {
        processing = false;
      });
      final snackBar = new SnackBar(
        content: new Text("There was an error logging into the app"),
        duration: new Duration(seconds: 2),
        backgroundColor: Colors.blue,
      );
      _scaffoldKeyLog.currentState.showSnackBar(snackBar);
    }
  }


  void whenLoggedIn() async {
    DocumentSnapshot snapshot;
    try{
      snapshot =  await FirebaseFirestore.instance.collection('users').doc(FirebaseAuth.instance.currentUser.uid).get();
      snapshot.get("favorites");
    }catch(e){
      await FirebaseFirestore.instance.collection('users').doc(FirebaseAuth.instance.currentUser.uid).set({"favorites" : []});
      snapshot = await FirebaseFirestore.instance.collection('users').doc(FirebaseAuth.instance.currentUser.uid).get();
    }
    List<dynamic> myFavorites = snapshot.get("favorites");
    Iterable mySavedSuggestions = myFavorites.map((e) => WordPair(e.values.toList()[0],e.values.toList()[1])).toSet();
    widget.saved.addAll(mySavedSuggestions);
    loggedIn = true;
    setState(() {
      processing = false;
    });
    Navigator.pop(context, loggedIn);

  }

}