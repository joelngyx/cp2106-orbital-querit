import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:orbital_2020_usono_my_ver/Models/QuestionDetails.dart';
import 'package:orbital_2020_usono_my_ver/Models/RoomDetails.dart';
import 'package:orbital_2020_usono_my_ver/Models/User.dart';
import 'package:orbital_2020_usono_my_ver/Services/database/RoomDbService.dart';
import 'package:orbital_2020_usono_my_ver/Services/database/UserDbService.dart';
import 'package:provider/provider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:hexcolor/hexcolor.dart';
import 'dart:async';

class Message extends StatefulWidget {
  final String text;
  final String sender;
  final String messageID;

  Message({this.text, this.sender, this.messageID});
  @override
  _MessageState createState() => _MessageState();
}

class _MessageState extends State<Message> {
//  final AnimationController animationController;
//  static String defaultUserName = "You";

  @override
  Widget build(BuildContext context) {
//    return new SizeTransition( // SizeTransition wraps around the widget that it wants to animate, in this case Container.
//        sizeFactor: new CurvedAnimation(
//          parent: animationController,
//          curve: Curves.bounceOut, // affects animation of newly submitted messages popping out in the flexible widget
//        ),

    final user = Provider.of<User>(context);
    final roomDetails = Provider.of<RoomDetails>(context);
    final questionDetails = Provider.of<QuestionDetails>(context);
    final roomDbService =
        RoomDbService(roomDetails.roomName, roomDetails.roomID);
    final userDbService = UserDbService(uid: user.uid);

    String displayName;

    return new Card(
      // color: Colors.teal[100],
      margin: const EdgeInsets.symmetric(horizontal: 5, vertical: 3),
      elevation: 5,
      // affects the vertical gap between messages in the ListView
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: FutureBuilder<String>(
            future: userDbService.getNameFromUser(),
            builder: (context, snapshot1) {
              if (!snapshot1.hasData) {
                return Container();
              } else {
                String userName = snapshot1.data;
                userName == widget.sender
                    ? displayName = "You"
                    : displayName = widget.sender;
                return new Row(
                  children: [
                    FutureBuilder(
                        future: roomDbService.getMessageVoteStatus(user.uid,
                            questionDetails.questionID, widget.messageID),
                        builder: (context, snapshot2) {
                          return Column(
                            // the stack overflow functionality
                            children: <Widget>[
                              InkWell(
                                child: snapshot2.data == "Upvoted"
                                    ? Icon(Icons.arrow_drop_up,
                                        color: Colors.blue[500])
                                    : Icon(Icons.arrow_drop_up),
                                onTap: () {
                                  dynamic result = roomDbService.upvoteMessage(
                                      widget.messageID,
                                      questionDetails.questionID,
                                      user.uid);
                                },
                              ),
                              StreamBuilder<DocumentSnapshot>(
                                stream: roomDbService.getMessageVotes(
                                    questionDetails.questionID,
                                    widget.messageID),
                                builder: (context, snapshot1) {
                                  if (!snapshot1.hasData) {
                                    return Center(child: Container());
                                  } else {
                                    // print("Current Votes: " + "${snapshot1.data.data["votes"]}");
                                    return Text(
                                        "${snapshot1.data.data["votes"]}");
                                  }
                                },
                              ),
                              InkWell(
                                child: snapshot2.data == "Downvoted"
                                    ? Icon(Icons.arrow_drop_down,
                                        color: Colors.red[500])
                                    : Icon(Icons.arrow_drop_down),
                                onTap: () {
                                  roomDbService.downvoteMessage(
                                      widget.messageID,
                                      questionDetails.questionID,
                                      user.uid);
//                                  setState(() {
//                                    alreadyDownvoted = !alreadyDownvoted;
//                                    if (alreadyUpvoted) {
//                                      alreadyUpvoted = false;
//                                    }
//                                  });
                                },
                              ),
                            ],
                          );
                        }),
                    new SizedBox(
                      width: 15,
                    ),
                    new Expanded(
                      child: new Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          new Text(displayName,
                              style: TextStyle(fontWeight: FontWeight.bold)),
                          //Theme.of(context).textTheme.subtitle1),
                          new Container(
                            margin: const EdgeInsets.only(top: 6),
                            child: new Text(widget.text),
                          )
                        ],
                      ),
                    ),
                    FutureBuilder(
                        future: Future.wait([
                          userDbService
                              .getMessageArchivedStatus(widget.messageID),
                          FirebaseAuth.instance.currentUser(),
                        ]),
                        builder: (context, snapshotList) {
                          bool alreadyArchived;
                          FirebaseUser user;

                          if (!snapshotList.hasData) {
                            return Container();
                          } else {
                            alreadyArchived = snapshotList.data[0];
                            user = snapshotList.data[1];

                            return InkWell(
                              child: Container(
                                  height: 30,
                                  width: 30,
                                  alignment: Alignment.centerRight,
                                  decoration:
                                      BoxDecoration(color: Colors.white),
                                  child: Icon(
                                      alreadyArchived
                                          ? Icons.bookmark
                                          : Icons.bookmark_border,
                                      color: alreadyArchived
                                          ? Colors.red[200]
                                          : null)),
                              onTap: () async {
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
                                          onPressed: () =>
                                              Navigator.of(context).pop(),
                                        ),
                                      ],
                                    ),
                                  );
                                } else {
                                  CollectionReference archivedCollection =
                                      Firestore.instance.collection("Users");
                                  CollectionReference messages =
                                      archivedCollection
                                          .document(user.uid)
                                          .collection("Archived Messages");

                                  if (alreadyArchived) {
                                    userDbService.deleteArchivedMessage(
                                        widget.messageID);
                                  } else {
                                    userDbService.addArchivedMessage(
                                        widget.text,
                                        widget.messageID,
                                        questionDetails.question,
                                        roomDetails.roomName,
                                        widget.sender);
                                  }
                                }
                              },
                            );
                          }
                        }),
                  ],
                );
              }
            }),
      ),
    );
  }
}
