import 'package:flutter/cupertino.dart';
import 'package:orbital_2020_usono_my_ver/Pages/Register.dart';
import 'package:orbital_2020_usono_my_ver/Pages/SignIn.dart';

class Authenticate extends StatefulWidget {
  @override
  State createState() => _AuthenticateState();
}

class _AuthenticateState extends State<Authenticate> {
  bool showSignIn = true;

  @override
  Widget build(BuildContext context) {
    // we will either return a signIn() widget or an anonSignIn() widget here
    void toggleView() {
      setState(() => showSignIn = !showSignIn);
    }

    if (showSignIn) {
      return SignIn(toggleView: toggleView);
    } else {
      return Register(toggleView: toggleView);
    }
  }
}
