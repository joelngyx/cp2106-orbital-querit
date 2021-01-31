import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:orbital_2020_usono_my_ver/Pages/AnonSignIn.dart';
import 'package:orbital_2020_usono_my_ver/Services/auth.dart';
import 'package:orbital_2020_usono_my_ver/Shared/constants.dart';

class SignIn extends StatefulWidget {
  final Function toggleView;
  SignIn({this.toggleView});

  @override
  _SignInState createState() => _SignInState();
}

class _SignInState extends State<SignIn> {
  AuthService _auth = AuthService();
  final _formKey = GlobalKey<FormState>();
  bool loading = false; // show loading widget if true

  // text field state
  String email = '';
  String password = '';
  String error = '';

  bool anon = false;

  void _popUp() {
    // flutter defined function
    showDialog(
      context: context,
      builder: (BuildContext context) {
        // return object of type Dialog
        return AlertDialog(
          title: new Text("Could not sign in"),
          content: new Text(
              "The email or password entered is not valid. Try again!"),
          actions: <Widget>[
            // usually buttons at the bottom of the dialog
            new FlatButton(
              child: new Text(
                "Close",
              ),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return loading
        ? Loading()
        : anon // checks if the user wants to sign in anoynymously or not
            ? AnonSignIn()
            : Theme(
                data: new ThemeData(
                  brightness: Brightness.light,
                  primaryColor: Colors.brown[400],
                  inputDecorationTheme: new InputDecorationTheme(
                    labelStyle: new TextStyle(
                      fontSize: 100,
                    ),
                  ),
                ),
                child: Scaffold(
                  backgroundColor: Colors.white,
                  // 2nd solution: https://medium.com/zipper-studios/the-keyboard-causes-the-bottom-overflowed-error-5da150a1c660
                  body: SingleChildScrollView(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: <Widget>[
                        Container(
                            margin:
                                const EdgeInsets.fromLTRB(0.0, 50.0, 0.0, 0.0),
                            height: MediaQuery.of(context).size.height / 2.4,
                            width: MediaQuery.of(context).size.width,
                            decoration: BoxDecoration(
                                image: DecorationImage(
                                    image: AssetImage(
                              'images/logoforapp.PNG',
                            )))),
                        Padding(
                            padding: EdgeInsets.symmetric(
                                vertical: 0.0, horizontal: 50.0)),
                        Flexible(
                          child: Padding(
                            padding: EdgeInsets.symmetric(
                                vertical: 0.0, horizontal: 50.0),
                            child: Form(
                              key: _formKey,
                              child: Column(
                                children: [
                                  // SizedBox(height: 0.0),
                                  TextFormField(
                                      decoration: textInputDecoration.copyWith(
                                          hintText: 'Email',
                                          hintStyle: TextStyle(
                                              fontWeight: FontWeight.w400,
                                              color: Colors.grey)),
                                      validator: (val) =>
                                          val.isEmpty ? 'Enter an email' : null,
                                      onChanged: (val) {
                                        setState(() => email = val);
                                      }),
                                  SizedBox(height: 5.0),
                                  TextFormField(
                                      decoration: textInputDecoration.copyWith(
                                          hintText: 'Password',
                                          hintStyle: TextStyle(
                                              fontWeight: FontWeight.w400,
                                              color: Colors.grey)),
                                      obscureText: true,
                                      validator: (val) => val.length < 6
                                          ? 'Enter a password 6+ chars long'
                                          : null,
                                      onChanged: (val) {
                                        setState(() => password = val);
                                      }),
                                  FlatButton.icon(
                                    onPressed: widget.toggleView,
                                    icon: Icon(Icons.person_add),
                                    label: Text(
                                      'No account? Register here!',
                                      style: TextStyle(
                                          color: Colors.black45,
                                          fontWeight: FontWeight.w400),
                                    ),
                                  ),
                                  SizedBox(height: 10),
                                  Column(children: [
                                    RaisedButton(
                                        color: Colors.grey[200],
                                        child: Text('Sign In',
                                            style: TextStyle(
                                                fontWeight: FontWeight.w500,
                                                color: Colors.black54)),
                                        onPressed: () async {
                                          if (_formKey.currentState
                                              .validate()) {
                                            // validates form based on form's state, using the validator properties in each FormField
                                            setState(() {
                                              _popUp();
                                              loading =
                                                  false; // no longer display loading widget if ...
                                            });

                                            // entire Form is valid if all validators return null
                                            dynamic result = await _auth
                                                .signInWithEmailAndPassword(
                                                    email, password);

                                            if (result == null) {
                                              print("No record of this user");
                                              setState(() {
                                                _popUp();
                                                loading =
                                                    false; // no longer display loading widget if ...
                                              });
                                            }
                                          }
                                        }),
                                    SizedBox(height: 12),
                                    RaisedButton(
                                        color: Colors.grey[200],
                                        child: Text('Guest Sign In',
                                            style: TextStyle(
                                                fontWeight: FontWeight.w500,
                                                color: Colors.black54)),
                                        onPressed: () {
                                          setState(() {
                                            anon = true;
                                          });
                                        }),
                                  ]),
                                  SizedBox(height: 12),
                                  Text(
                                    error,
                                    style: TextStyle(
                                        color: Colors.red, fontSize: 14),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              );
  }
}
