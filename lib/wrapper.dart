import 'package:flutter/material.dart';
import 'package:orbital_2020_usono_my_ver/Pages/Authenticate.dart';
import 'package:orbital_2020_usono_my_ver/Pages/Home.dart';
import 'package:provider/provider.dart';
import 'package:orbital_2020_usono_my_ver/Models/User.dart';


class Wrapper extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final user = Provider.of<User>(context);

    if (user == null) {
      return Authenticate();
    } else {
      return Home();
    }
  }
}