import 'package:flutter/material.dart';
import 'package:numberpicker/numberpicker.dart';
import 'package:orbital_2020_usono_my_ver/Services/database/RoomDbService.dart';
import 'package:orbital_2020_usono_my_ver/Shared/constants.dart';
import 'package:geolocator/geolocator.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:geoflutterfire/geoflutterfire.dart';

class ChatRoomSettingsForm extends StatefulWidget {
  @override
  _ChatRoomSettingsFormState createState() => _ChatRoomSettingsFormState();
}

class _ChatRoomSettingsFormState extends State<ChatRoomSettingsForm> {
  String _currentRoomName = '';
  final _formKey = GlobalKey<FormState>();
  final RoomDbService _database = new RoomDbService();
  Position _location = Position(latitude: 0.0, longitude: 0.0);
  Geoflutterfire geo = Geoflutterfire();
  double _radius = 0.02; //in km, so this is 20m
  int _charCount = 0;
  int limit = 30;

  void _getCurrentLocation(String roomid) async {
    GeoFirePoint roomLocation;
    final location = await Geolocator()
        .getCurrentPosition(desiredAccuracy: LocationAccuracy.high);

    setState(() {
      _location = location;
      roomLocation = geo.point(
          latitude: _location.latitude, longitude: _location.longitude);
    });

    Firestore.instance
        .collection('Rooms')
        .document(roomid)
        .setData({'position': roomLocation.data}, merge: true);
    Firestore.instance
        .collection('Rooms')
        .document(roomid)
        .setData({'Latitude': _location.latitude}, merge: true);
    Firestore.instance
        .collection('Rooms')
        .document(roomid)
        .setData({'Longitude': _location.longitude}, merge: true);
    Firestore.instance
        .collection('Rooms')
        .document(roomid)
        .setData({'Radius': _radius}, merge: true);
  }

  @override
  Widget build(BuildContext context) {
    return Form(
      key: _formKey,
      child: Column(
        children: <Widget>[
          new Text(
            "Room Name:",
            style: TextStyle(fontWeight: FontWeight.w400, fontSize: 18),
          ),
          new SizedBox(
            height: 15,
          ),
          TextFormField(

            validator: (value) => value.length < 4
                ? 'Room Names should be at least 4 characters long'
                : value.length > limit
                  ? 'Room Names should be at most 30 characters long'
                  : null,

            onChanged: (text) {
              setState(() {
                 _charCount = text.length;
                _currentRoomName = text;
              });
            },
            decoration: textInputDecoration.copyWith(
                hintText: "Enter between 4 and $limit characters",
                hintStyle: TextStyle(
                    fontWeight: FontWeight.w400,
                    color: Colors.grey,
                    fontSize: 14,
                ),
            ),
          ),

          Container(
            height: 70,
            child: Center(child: Text("Character count: " + "$_charCount")),
          ),

          new Text(
            "Set the room radius: $_radius km",
            style: TextStyle(fontWeight: FontWeight.w400, fontSize: 18),
          ),
          new NumberPicker.decimal(
              initialValue: _radius,
              minValue: 0,
              maxValue: 2,
              decimalPlaces: 2,
              onChanged: (newValue) => setState(() => _radius = newValue)),
          SizedBox(height: 15),
          RaisedButton(
            color: Colors.pink[400],
            child: Text("Let's create the room!",
                style: TextStyle(color: Colors.white)),
            onPressed: () async {
              if (_formKey.currentState.validate()) {
                String roomID =
                    await _database.createChatRoom(_currentRoomName);
                _getCurrentLocation(roomID);
                Navigator.pushNamed(context, '/QuestionPage', arguments: {
                  "roomName": _currentRoomName,
                  "roomID": roomID
                });
              }
            },
          ),
        ],
      ),
    );
  }
}
