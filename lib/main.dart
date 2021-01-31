import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:orbital_2020_usono_my_ver/Models/Message.dart';
import 'package:orbital_2020_usono_my_ver/Models/User.dart';
import 'package:orbital_2020_usono_my_ver/Services/database/RoomDbService.dart';
import 'package:orbital_2020_usono_my_ver/Shared/routes.dart';
import 'package:orbital_2020_usono_my_ver/wrapper.dart';
import 'package:provider/provider.dart';
import 'package:orbital_2020_usono_my_ver/Pages/SignIn.dart';
import 'package:orbital_2020_usono_my_ver/Pages/ChatRoomPage.dart';
import 'package:orbital_2020_usono_my_ver/Pages/Home.dart';
import 'package:orbital_2020_usono_my_ver/Services/auth.dart';
import 'package:orbital_2020_usono_my_ver/Services/database/UserDbService.dart';
import 'package:flutter/services.dart';

void main() {
  runApp(new ChatApp());
}

class ChatApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
    return MultiProvider(
      providers: [
        StreamProvider<User>(create: (context) => AuthService().user),
      ],
      child: MaterialApp(
        home: Wrapper(),
        onGenerateRoute: RouteHandler
            .generateRoute, // callback used when app is navigated to a named route
      ),
    );
  }
}
