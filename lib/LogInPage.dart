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
  String _password, _username, _otherPassword;
  bool processing = false;
  bool loggedIn = false;
  final formKey = GlobalKey<FormState>();
  final GlobalKey<ScaffoldState> _scaffoldKeyLog = new GlobalKey<ScaffoldState>();
  _LoginScreenState();

  @override
  Widget build(BuildContext context) {
    return WillPopScope(child:Scaffold(
      key: _scaffoldKeyLog,
      //resizeToAvoidBottomPadding: false,
      appBar: AppBar(
        centerTitle: true,
        title: Text('Login'),
      ),
      body: Builder(
          builder: (BuildContext context)
          {
            return
              (processing)?
              Center(
                  child: Column(
                      children: [
                        CircularProgressIndicator(backgroundColor: Colors.lightGreenAccent)
                      ],
                      crossAxisAlignment: CrossAxisAlignment.center,
                      mainAxisAlignment: MainAxisAlignment.center
                  )
              )
                  :
              SingleChildScrollView(
                child:
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Container(
                      child: Container(
                        padding: EdgeInsets.fromLTRB(15.0, 35.0, 0.0, 0.0),
                        child: Text(
                            'Welcome to StartupNames Generator, please log in below',
                            style: TextStyle(
                                fontSize: 16.0)),
                      ),
                    ),
                    Container(
                        padding: EdgeInsets.only(top: 35.0, left: 20.0, right: 20.0),
                        child: Column(
                          children: <Widget>[
                            TextField(
                              decoration: InputDecoration(
                                  labelText: 'Email',
                                  labelStyle: TextStyle(
                                      fontFamily: 'Montserrat',
                                      color: Colors.grey),
                                  focusedBorder: UnderlineInputBorder(
                                      borderSide: BorderSide(color: Colors.red)
                                  )
                              ),
                              onChanged: (String str) {
                                _username = str;
                              },
                            ),
                            SizedBox(height: 20.0),
                            TextField(
                              decoration: InputDecoration(
                                  labelText: 'Password',
                                  labelStyle: TextStyle(
                                      fontFamily: 'Montserrat',
                                      color: Colors.grey),
                                  focusedBorder: UnderlineInputBorder(
                                      borderSide: BorderSide(color: Colors.red)
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
                                child: Row(
                                  children: [
                                    Expanded(
                                      child: FlatButton(
                                        color: Colors.red,
                                        shape: RoundedRectangleBorder(
                                            borderRadius: BorderRadius.circular(20.0)),
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
                                    )
                                  ],
                                ),
                              ),
                            ),
                            Container(
                              height: 40.0,
                              child: Center(
                                child: Row(
                                  children: [
                                    Expanded(
                                      child: FlatButton(
                                        color: Colors.green,
                                        shape: RoundedRectangleBorder(
                                            borderRadius: BorderRadius.circular(20.0)
                                        ),
                                        onPressed: () {
                                          _showConfirmation();
                                        },
                                        child: Text(
                                          'New user? Click to sign up',
                                          style: TextStyle(
                                              color: Colors.white,
                                              fontWeight: FontWeight.bold,
                                              fontFamily: 'Montserrat'
                                          ),
                                        ),
                                      ),
                                    )
                                  ],
                                )
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

  void _showConfirmation(){
    showModalBottomSheet(context: context, builder: (context){
      return Form(
        key: formKey,
        child: Padding(
            padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
            child: Container(
                height: 200,
                padding: EdgeInsets.only(top: 0, left: 20.0, right: 20.0),
                child: Column(
                  children: [
                    Container(
                      padding: EdgeInsets.fromLTRB(15.0, 10, 0.0, 0.0),
                      child: Text(
                          'Please confirm your password below:',
                          style: TextStyle(
                              fontSize: 15.0)),
                    ),
                    Divider(),
                    TextFormField(
                      decoration: InputDecoration(
                          labelText: 'Password',
                          labelStyle: TextStyle(
                              fontFamily: 'Montserrat',
                              fontWeight: FontWeight.bold,
                              color: Colors.red),
                          focusedBorder: UnderlineInputBorder(
                              borderSide: BorderSide(color: Colors.red)
                          )
                      ),
                      validator: (val) => val != _password ? 'Passwords must match' : null,
                      obscureText: true,
                      onSaved: (val) {},
                    ),
                    SizedBox(height: 1),
                    Container(
                      height: 40.0,
                      width: 100.0,
                      child: Center(
                          child: Row(
                            children: [
                              Expanded(
                                child: FlatButton(
                                  color: Colors.teal,
                                  onPressed: () async {
                                    final form = formKey.currentState;
                                    if (form.validate()) {
                                      form.save();
                                      Navigator.pop(context, loggedIn);
                                      setState(() {
                                        processing = true;
                                      });
                                      await FirebaseAuth.instance.createUserWithEmailAndPassword(email: _username, password: _password);
                                      await FirebaseAuth.instance.signInWithEmailAndPassword(email: _username, password: _password);
                                      setState(() {
                                        processing = false;
                                      });
                                      whenLoggedIn();
                                    }
                                  },
                                  child: Text(
                                    'Confirm',
                                    style: TextStyle(
                                        color: Colors.white,
                                        fontFamily: 'Montserrat'
                                    ),
                                  ),
                                ),
                              )
                            ],
                          )
                      ),
                    ),
                  ],
                )
            )
        ),
      );
    },
    );
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


