import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:orbital_2020_usono_my_ver/Models/EditQuestionTile.dart';
import 'package:orbital_2020_usono_my_ver/Models/ExpandedQuestionTile.dart';
import 'package:orbital_2020_usono_my_ver/Models/QuestionDetails.dart';
import 'package:orbital_2020_usono_my_ver/Models/RoomDetails.dart';
import 'package:orbital_2020_usono_my_ver/Models/User.dart';
import 'package:orbital_2020_usono_my_ver/Services/database/RoomDbService.dart';
import 'package:provider/provider.dart';

class QuestionTile extends StatefulWidget {
  final String text;
  final String roomName; // roomName and roomID needs to be passed around so that in ChatRoomPage, can add the message to the correct room.
  final String roomID; // might have trouble if changing roomName
  final String questionID; //

  QuestionTile({this.questionID, this.text, this.roomName, this.roomID});

  @override
  _QuestionTileState createState() => _QuestionTileState(text);
}

class _QuestionTileState extends State<QuestionTile> {
  final String text;
  int netVotes = 0;
  bool editing = false;

  _QuestionTileState(this.text);

  void toggleEdit() {
    setState(() => editing = !editing);
  }

  Widget buildTile() {

    RoomDbService dbService = RoomDbService(widget.roomName, widget.roomID);
    final user = Provider.of<User>(context);

    return editing
        ? EditQuestionTile(toggleEdit)
        : Card(
      elevation: 5,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(10, 7, 10, 7),
        child: GestureDetector(
          onTap: () => {
            Navigator.pushNamed(context, "/ChatRoomPage", arguments: {
              "question": widget.text,
              "questionID": widget.questionID,
              "roomName": widget.roomName,
              "roomID": widget.roomID,
            })
          },
          child: new Row(
            // crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
              FutureBuilder<String>(
                  future: dbService.getQuestionVoteStatus(user.uid, widget.questionID),
                  builder: (context, snapshot) {

                    if (!snapshot.hasData) {
//                      return CircularProgressIndicator();
                      return Container();
                    } else {
                      return Column(
                        // the stack overflow functionality
                        children: <Widget>[
                          InkWell(
                            child: snapshot.data == "Upvoted"
                                ? Icon(Icons.arrow_drop_up,
                                color: Colors.blue[500])
                                : Icon(Icons.arrow_drop_up),
                            onTap: () {
                              dynamic result = dbService.upvoteQuestion(
                                  user.uid, widget.questionID);
//                                  setState(() {
//                                    alreadyUpvoted = !alreadyUpvoted;
//                                    if (alreadyDownvoted) {
//                                      alreadyDownvoted = false;
//                                    }
//                                  });
                            },
                          ),
                          StreamBuilder<DocumentSnapshot>(
                            stream: dbService.getQuestionVotes(widget.questionID),
                            builder: (context, snapshot) {
                              if (!snapshot.hasData) {
                                return Center(child: CircularProgressIndicator());
                              } else {
                                // print("Current Votes: " + "${snapshot.data.data["votes"]}");
                                // print("questionID: " + widget.questionID);
                                return Text("${snapshot.data.data["votes"]}");
                              }
                            },
                          ),
                          InkWell(
                            child: snapshot.data == "Downvoted"
                                ? Icon(Icons.arrow_drop_down,
                                color: Colors.red[500])
                                : Icon(Icons.arrow_drop_down),
                            onTap: () {
                              dbService.downvoteQuestion(
                                  user.uid, widget.questionID);
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
                    }


                  }
              ),

              Spacer(flex: 1),

              Flexible(
                flex: 16,
                child: Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      widget.text,
                      style: TextStyle(fontSize: 16),
                    )),
              ),

              Spacer(
                flex: 1,
              ),

              Flexible(
                flex: 3,
                child: FutureBuilder(
                  future: getQuestionSender(),
                  builder: (context, snapshot) {
                    String senderUID = snapshot.data;

                    if (!snapshot.hasData) {
                      return Container();
                    } else if (senderUID != user.uid) {
                      return Container();
                    } else {
                      return Row(
                        children: <Widget>[

                          InkWell( // Edit button
                            child: Icon(Icons.create),
                            onTap: () async {
                              setState(() {
                                editing = !editing;
                              });
                            },
                          ),

                          Spacer(
                            flex: 1,
                          ),


                          InkWell(
                            child: Icon(Icons.delete),
                            onTap: () async {
                              showDialog(
                                barrierDismissible: true,
                                context: context,
                                builder: (context) => AlertDialog(
                                  title: Text("Delete this question?"),
                                  content: Text("Are you sure you want to delete this question?"),
                                  actions: <Widget>[
                                    FlatButton(
                                      child: Text('Yes'),
                                      onPressed: () async {
                                        await dbService.deleteQuestion(widget.questionID);
                                        Navigator.of(context).pop();
                                      },
                                    ),
                                    FlatButton(
                                      child: Text('No'),
                                      onPressed: () => Navigator.of(context).pop(),
                                    ),
                                  ],

                                ),
                              );

                            }
                          ),

                        ],
                      );
                    }
                  },
                ),
              ),

//                    GestureDetector(
//                      child: Icon(Icons.editing_more),
//                      onTap: toggleExpansion,
//                    ),

            ],
          ),
        ),
      ),
    );
  }

  Future getQuestionSender() async {

    return (await Firestore.instance.collection('Rooms').document(widget.roomID)
      .collection('Questions').document(widget.questionID).get()).data["from"];

    // return
//    return user.uid != questionSenderUID
//        ? Container()
//        : InkWell(
//      child: Icon(Icons.create),
//      onTap: () async {
//        RoomDbService(widget.roomName, widget.roomID).editQuestion(widget.questionID);
//      },
//    );
  }

  @override
  Widget build(BuildContext context) {
    return buildTile();
  }
}
