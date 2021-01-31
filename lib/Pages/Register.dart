import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/cupertino.dart';
import 'package:hexcolor/hexcolor.dart';
import 'package:orbital_2020_usono_my_ver/Services/auth.dart';
import 'package:orbital_2020_usono_my_ver/Shared/constants.dart';

class Register extends StatefulWidget {
  final Function toggleView;
  Register({this.toggleView});

  @override
  _RegisterState createState() => _RegisterState();
}

class _RegisterState extends State<Register> {
  final AuthService _auth = AuthService();
  final _formKey = GlobalKey<FormState>();

  String email = '';
  String password = '';
  String error = '';
  String name = '';
  bool loading = false;

  @override
  Widget build(BuildContext context) {
    return loading
        ? Loading()
        : Theme(
            data: new ThemeData(
              brightness: Brightness.light,
              primarySwatch: Colors.teal,
              inputDecorationTheme: new InputDecorationTheme(
                labelStyle: new TextStyle(
                  fontSize: 20,
                ),
              ),
            ),
            child: Scaffold(
              appBar: AppBar(
                backgroundColor: Hexcolor('#A38FA3'),
                elevation: 20.0,
                title: Text('Sign up for an account',
                    style: TextStyle(
                      fontWeight: FontWeight.w500,
                      color: Colors.black54,
                    )),
                actions: [
                  // this property is the list of widgets to display in a row AFTER the Title widget in AppBarj
                  FlatButton.icon(
                      icon: Icon(Icons.person),
                      label: Text('Sign In'),
                      onPressed: () {
                        widget
                            .toggleView(); // widget is a property of the State class, that returns the corresponding StatefulWidget instance, in this case an instance of Register
                      })
                ],
              ),
              body: SingleChildScrollView(
                child: Container(
                  padding: EdgeInsets.symmetric(vertical: 20.0, horizontal: 50.0),
                  child: Form(
                    key: _formKey, // associating our Form with a GlobalKey, which allows tracking of our Form's state, allowing form validation
                    child: Column(
                      children: [
                        SizedBox(height: 20),
                        TextFormField(
                            decoration: textInputDecoration.copyWith(
                                hintText:
                                    'Email'), // belongs to constants.dart in the shared directory
                            validator: (val) => val.isEmpty
                                ? 'Enter an email'
                                : null, // return null if form is valid
                            onChanged: (val) {
                              setState(() => email = val);
                            }),
                        SizedBox(height: 20),
                        TextFormField(
                            decoration: textInputDecoration.copyWith(
                                hintText: 'Password'),
                            obscureText: true,
                            validator: (val) => val.length < 6
                                ? 'Enter a password 6+ chars long'
                                : null,
                            onChanged: (val) {
                              setState(() => password = val);
                            }),
                        SizedBox(height: 20),
                        TextFormField(
                            decoration: textInputDecoration.copyWith(
                                hintText: 'Enter a nickname'),
                            validator: (val) => val.length < 3
                                ? 'Please enter a name at least 3 characters long'
                                : null,
                            onChanged: (val) {
                              setState(() {
                                name = val;
                              });
                            }),
                        SizedBox(height: 20),
                        RaisedButton(
                            color: Colors.grey[200],
                            child: Text('Register',
                                style: TextStyle(color: Colors.black54)),
                            onPressed: () async {
                              if (_formKey.currentState.validate()) {
                                // validates form based on form's state, using the validator properties in each FormField

                                setState(() => loading = true);
                                // entire Form is valid if all validators return null
                                dynamic result =
                                    await _auth.registerWithEmailAndPassword(
                                        email, password, name);

                                if (result == null) {
                                  setState(() {
                                    loading = false;
                                    error = 'please supply a valid email';
                                  });
                                }
                                /* like before, there is no need for an else clause to make the Home widget appear if the user is successfully registered.
                          Why? Because the widget tree is listening to the AuthService().user stream
                          */
                              }
                            }),
                        SizedBox(height: 12),
                        Text(
                          error,
                          style: TextStyle(color: Colors.red, fontSize: 14),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          );
  }
}
