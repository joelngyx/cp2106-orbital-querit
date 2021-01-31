import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:orbital_2020_usono_my_ver/Models/RoomDetails.dart';
import 'package:orbital_2020_usono_my_ver/Models/User.dart';
import 'package:orbital_2020_usono_my_ver/Services/database/UserDbService.dart';
import 'package:orbital_2020_usono_my_ver/Settings/AllSettingsPanel.dart';
import 'package:orbital_2020_usono_my_ver/Shared/constants.dart';
import 'package:provider/provider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:geolocator/geolocator.dart';
import 'package:orbital_2020_usono_my_ver/Services/auth.dart';
import 'package:geoflutterfire/geoflutterfire.dart';
import 'dart:async';
import 'package:rxdart/rxdart.dart';
import 'package:hexcolor/hexcolor.dart';
import 'package:geocoder/geocoder.dart';

class Home extends StatefulWidget {
  //SelectionPage({Key key, @required this.alias}) : super(key: key);
  @override
  State createState() =>
      new _HomeState(); // Framework calls createState() when the stateful element has been created
}

class _HomeState extends State<Home> {
  final AuthService _auth = AuthService();
  final Firestore firestoreInstance = Firestore.instance;
  bool loading = false;
  Position _position = Position(latitude: 0.0, longitude: 0.0);
  StreamSubscription<Position> _positionStream;
  Geoflutterfire geo = Geoflutterfire();
  Firestore _firestore = Firestore.instance;
  Stream<List<DocumentSnapshot>> stream;
  var radius = BehaviorSubject<double>.seeded(1.0);
  var refreshKey = GlobalKey<RefreshIndicatorState>();
  double _userRadius = 0.05;
  final _formKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
    var locationOptions =
        LocationOptions(accuracy: LocationAccuracy.high, distanceFilter: 1);
    _positionStream = Geolocator()
        .getPositionStream(locationOptions)
        .listen((Position position) {
      _position = position;
    });
  }

  // _getAddress(_position) {
  //   addresses = await Geocoder.local.findAddressesFromCoordinates(coordinates);
  //   first = addresses.first;
  //   print("${first.featureName} : ${first.addressLine}");
  // }

  _debugger() {
    print("Hey!");
  }

  void _popUp(var dist) {
    // flutter defined function
    showDialog(
      context: context,
      builder: (BuildContext context) {
        // return object of type Dialog
        return AlertDialog(
          title: new Text("You're too far away!"),
          content: new Text(
              "You're ${dist.toStringAsFixed(3)}km away from the border of this room"),
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

  Future<Null> refreshList() async {
    // refreshKey.currentState?.show(atTop: true);
    // setState(() => loading = true);
    await Future.delayed(Duration(seconds: 0));
    print(_position.latitude);
    print(_position.longitude);
    setState(() {
      _roomList(_position);
    });
  }

  Widget _roomList(var _position) {
    return StreamBuilder(stream: radius.switchMap((rad) {
      var collectionRef = _firestore.collection('Rooms');
      // print(_position.latitude);
      // print(_position.longitude);
      return geo.collection(collectionRef: collectionRef).within(
          center: geo.point(
              latitude: _position.latitude, longitude: _position.longitude),
          radius: _userRadius,
          field: 'position',
          strictMode: false);
    }), builder: (BuildContext context,
        AsyncSnapshot<List<DocumentSnapshot>> snapshots) {
      if (snapshots.hasError) return new Text('Error; ${snapshots.error}');
      switch (snapshots.connectionState) {
        case ConnectionState.waiting:
          return new Text('', style: TextStyle(fontSize: 30.0));
        default:
          return new ListView(
            children: snapshots.data.map((document) {
              return _buildListWidget(Colors.grey[200],
                  document.data['roomName'], document.documentID);
            }).toList(),
          );
      }
    });
  }

  Widget _buildListWidget(Color color, String roomName, String roomID) {
    return Provider<RoomDetails>(
      create: (context) => RoomDetails(roomName, roomID),
      child: Container(
          height: 120,
          child: Card(
              semanticContainer: true,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10.0),
              ),
              elevation: 5,
              margin: EdgeInsets.all(10),
              color: color,
              child: GestureDetector(
                onTap: () async {
                  DocumentReference docRef =
                      Firestore.instance.collection("Rooms").document(roomID);

                  int currNumUsers = (await docRef.get()).data["numUsers"];

                  docRef.updateData({"numUsers": currNumUsers += 1});

                  double _roomLat = (await docRef.get()).data["Latitude"];
                  double _roomLng = (await docRef.get()).data["Longitude"];
                  double _roomRadius = (await docRef.get()).data["Radius"];

                  print("Lat: $_roomLat");
                  print("Lng: $_roomLng");

                  double distanceInMeters = await Geolocator().distanceBetween(
                      _position.latitude,
                      _position.longitude,
                      _roomLat,
                      _roomLng);

                  double distanceInKm = distanceInMeters / 1000;

                  print("Dist: $distanceInKm");
                  if (distanceInKm <= _roomRadius) {
                    Navigator.of(context).pushNamed(
                      '/QuestionPage',
                      arguments: {
                        "roomName": roomName,
                        "roomID": roomID,
                      },
                    );
                  } else if (distanceInKm > _roomRadius) {
                    double diff = distanceInKm - _roomRadius;
                    _popUp(diff);
                    refreshList();
                  }
                },
                child: Text('\n  $roomName',
                    style: TextStyle(color: Colors.black54, fontSize: 25)),
              ))),
    );
  }

  @override
  Widget build(BuildContext context) {
    // final fs = Firestore.instance;
    final user = Provider.of<User>(context);
    return loading
        ? Loading()
        : Scaffold(
            backgroundColor: Colors.white,
            body: CustomScrollView(slivers: <Widget>[
              SliverAppBar(
                expandedHeight: 200.0,
                floating: true,
                pinned: true,
                backgroundColor: Hexcolor('#A38FA3'),
                // Hexcolor('#A593B4'),
                //  Hexcolor('#CDC3D5'),
                // Hexcolor('#cfbae1'),
                flexibleSpace: FlexibleSpaceBar(
                  background: Container(
                    decoration: BoxDecoration(
                      border: Border(
                        top: BorderSide(
                          color: Colors.black12,
                          width: 2.0,
                        ),
                      ),
                    ),
                  ),
                  title: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.end,
                    mainAxisSize: MainAxisSize.max,
                    children: <Widget>[
                      const Text(
                        'Hello there,',
                        style: (TextStyle(
                            fontSize: 15,
                            fontStyle: FontStyle.italic,
                            color: Colors.black54,
                            fontWeight: FontWeight.w400)),
                      ),
                      new FutureBuilder(
                          future:
                              UserDbService(uid: user.uid).getNameFromUser(),
                          builder: (context, snapshot) {
                            if (snapshot.connectionState ==
                                ConnectionState.done) {
                              return new Text(
                                '${snapshot.data}',
                                style: TextStyle(
                                    color: Colors.black54,
                                    fontSize: 22,
                                    fontWeight: FontWeight.w500),
                                textAlign: TextAlign.left,
                              );
                            } else {
                              return CircularProgressIndicator();
                            }
                          }),
                      const Text(
                        'These are the rooms around you\n\n',
                        style: (TextStyle(
                            fontSize: 12,
                            fontStyle: FontStyle.italic,
                            color: Colors.black54,
                            fontWeight: FontWeight.w400)),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                ),
              ),
              SliverFixedExtentList(
                  itemExtent: 500,
                  delegate: SliverChildListDelegate([
                    _roomList(_position),
                  ])),
            ]),
            bottomNavigationBar: Row(children: <Widget>[
              InkWell(
                  onTap: () async {
                    setState(() => loading = true);
                    await _auth.signOut();
                  },
                  child: Container(
                    height: 60,
                    width: MediaQuery.of(context).size.width / 5,
                    decoration: BoxDecoration(color: Hexcolor('#CDC3D5')),
                    child: Icon(Icons.arrow_back),
                  )),
              InkWell(
                  onTap: () => showModalBottomSheet(
                      context: context,
                      builder: (context) {
                        return Container(
                          padding: EdgeInsets.symmetric(
                              vertical: 20, horizontal: 60),
                          child: Column(
                            children: [
                              new Text(
                                "Filter rooms by this distance(km)",
                                style: TextStyle(fontWeight: FontWeight.w400),
                              ),
                              new Form(
                                key: _formKey,
                                child: TextFormField(
                                    // decoration: new InputDecoration(
                                    //     labelText: "Enter your number"),
                                    keyboardType: TextInputType.number,
                                    validator: (val) {
                                      if (double.parse(val) > 2.0) {
                                        return "The maximum range is 2 km!";
                                      } else {
                                        return null;
                                      }
                                    },
                                    onChanged: (val) {
                                      setState(() {
                                        _userRadius = double.parse(val);
                                      });
                                      refreshList();
                                    }),
                              ),
                              // OR
                              // new NumberPicker.decimal(
                              //     initialValue: _userRadius,
                              //     minValue: 0,
                              //     maxValue: 5,
                              //     decimalPlaces: 2,
                              //     onChanged: (newValue) =>
                              //         setState(() => _userRadius = newValue)),
                              // no work, dk why
                            ],
                          ),
                        );
                      }),
                  child: Container(
                    height: 60,
                    width: MediaQuery.of(context).size.width / 5,
                    decoration: BoxDecoration(color: Hexcolor('#CDC3D5')),
                    // Get a better icon legit
                    child: Icon(Icons.settings),
                  )),
              InkWell(
                  onTap: () => AllSettingsPanel()
                      .showSettingsPanel(context, SettingsPanel.chatRoom),
                  child: Container(
                    height: 60,
                    width: MediaQuery.of(context).size.width / 5,
                    decoration: BoxDecoration(color: Hexcolor('#CDC3D5')),
                    child: Icon(Icons.add_box),
                  )),
              InkWell(
                  onTap: () async {
                    FirebaseUser user =
                        await FirebaseAuth.instance.currentUser();

                    if (user.email == null) {
                      showDialog(
                        barrierDismissible: true,
                        context: context,
                        builder: (_) => AlertDialog(
                          title: Text(
                              "Archiving not available to anonymous users!"),
                          content: Text(
                              "Please login to archive messages as well as to view them"),
                          actions: <Widget>[
                            FlatButton(
                              child: Text('Ok'),
                              onPressed: () => Navigator.of(context).pop(),
                            ),
                          ],
                        ),
                      );
                    } else {
                      Navigator.of(context).pushNamed(
                        '/ArchivedPage',
                        // should pass room name, question
                      );
                    }
                  },
                  child: Container(
                    height: 60,
                    width: MediaQuery.of(context).size.width / 5,
                    decoration: BoxDecoration(color: Hexcolor('#CDC3D5')),
                    // Get a better icon legit
                    child: Icon(Icons.bookmark),
                  )),
              InkWell(
                  onTap: () async {
                    print(_userRadius.toString());
                    _debugger();
                    refreshList();
                  },
                  child: Container(
                    height: 60,
                    width: MediaQuery.of(context).size.width / 5,
                    decoration: BoxDecoration(color: Hexcolor('#CDC3D5')),
                    // Get a better icon legit
                    child: Icon(Icons.refresh),
                  )),
            ]),
          );
  }
}
