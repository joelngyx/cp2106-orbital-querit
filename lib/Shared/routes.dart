import 'package:flutter/material.dart';
import 'package:orbital_2020_usono_my_ver/Pages/ChatRoomPage.dart';
import 'package:orbital_2020_usono_my_ver/Pages/QuestionPage.dart';
import 'package:orbital_2020_usono_my_ver/Pages/Archive.dart';

class RouteHandler {
  static Route<dynamic> generateRoute(RouteSettings settings) {
    // onGenerateRoute callback will create a RouteSettings object
    final args = settings.arguments;

    switch (settings.name) {
      case '/QuestionPage':
        return MaterialPageRoute(builder: (_) => QuestionPage(args));
      case '/ChatRoomPage':
        return MaterialPageRoute(builder: (_) => ChatRoomPage(args));
      case '/ArchivedPage':
        return MaterialPageRoute(builder: (_) => Archive());
      //MaterialPageRoute<T> replaces the entire screen with a platform
      //adaptive transition
      default:
        return _errorRoute();
    }
  }

  //Could be better accomplished with its own class
  static Route<dynamic> _errorRoute() {
    return MaterialPageRoute(builder: (_) {
      return Scaffold(
        body: Center(
          child: Text('Error'),
        ),
      );
    });
  }
}
