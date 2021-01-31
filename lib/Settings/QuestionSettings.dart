import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:orbital_2020_usono_my_ver/Models/User.dart';
import 'package:orbital_2020_usono_my_ver/Services/database/RoomDbService.dart';
import 'package:orbital_2020_usono_my_ver/Services/database/UserDbService.dart';
import 'package:orbital_2020_usono_my_ver/Shared/constants.dart';
import 'package:provider/provider.dart';

class QuestionSettingsForm extends StatefulWidget {
  final String roomName;
  final String roomID;

  QuestionSettingsForm(this.roomName, this.roomID);

  @override
  _QuestionSettingsFormState createState() =>
      _QuestionSettingsFormState(roomName, roomID);
}

class _QuestionSettingsFormState extends State<QuestionSettingsForm> {
  final String roomName;
  final String roomID;
  int _charCount = 0;
  final int limit = 100;
  TextEditingController _controller = new TextEditingController();
  final _formKey = GlobalKey<FormState>();

  _QuestionSettingsFormState(this.roomName, this.roomID);

  @override
  Widget build(BuildContext context) {
    final user = Provider.of<User>(context);
    RoomDbService dbService = RoomDbService(roomName, roomID);

    return Form(
      key: _formKey,
      child: Column(
        children: <Widget>[
          TextFormField(
            //validator fill in later
            controller: _controller,
            maxLines: null,
            keyboardType: TextInputType.multiline,
            onChanged: (value) {
              setState(() {
                _charCount = value.length;
              });
            },

            decoration: textInputDecoration.copyWith(
                hintText: "Type in the question you would like to ask"),

            validator: (val) => val.length < 6
                ? "Question is too short"
                : val.length > limit
                  ? "Question is too long. Please limit it to 100 characters"
                  : null,

          ),

          SizedBox(height: 15),

          Text("Character limit left: " + "${limit - _charCount}"),

          SizedBox(height: 15),

          RaisedButton(
            color: Colors.pink[400],
            child: Text(
              "Submit question",
              style: TextStyle(color: Colors.white),
            ),
            onPressed: () async {
              // we need some way to retrieve the questionID of the added question.

              if (_formKey.currentState.validate()) {
                dbService.sendQuestion(_controller.text,
                    user.uid);
                _controller.clear();
                Navigator.pop(context);
              }
//              dbService.sendQuestion(_controller.text, await UserDbService(uid: user.uid).getNameFromUser());
//              Navigator.pop(context);
            },
          ),
        ],
      ),
    );
  }
}
