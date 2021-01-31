import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:orbital_2020_usono_my_ver/Models/QuestionDetails.dart';
import 'package:orbital_2020_usono_my_ver/Models/QuestionTile.dart';
import 'package:orbital_2020_usono_my_ver/Models/RoomDetails.dart';
import 'package:orbital_2020_usono_my_ver/Services/database/RoomDbService.dart';
import 'package:hexcolor/hexcolor.dart';
import 'package:provider/provider.dart';

class QuestionPage extends StatefulWidget {
  final String roomName;
  final String roomID;

  QuestionPage(Map<String, String> map)
      : this.roomName = map["roomName"],
        this.roomID = map["roomID"];

  @override
  _QuestionPageState createState() => _QuestionPageState(roomName, roomID);
}

class _QuestionPageState extends State<QuestionPage> {
  final String roomName;
  final String roomID;

  _QuestionPageState(this.roomName, this.roomID);

  Widget _questionList() {
    return StreamBuilder<QuerySnapshot>(
        stream: RoomDbService(roomName, roomID).getRoomQuestions(), // in descending order of votes
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return Container();
          } else if (snapshot.hasError) {
            return new Text("Error...");
          } else {
            // snapshot.data.documents.forEach((element) {print(element);});
            // print("length: " + "${snapshot.data.documents.length}");
            return ListView.builder(
                itemCount: snapshot.data.documents.length,
                itemBuilder: (context, index) {
                  final docSS = snapshot.data.documents[index];
                  // print(snapshot.data.documents[index].data["text"]);

//                return Text(snapshot.data.documents[index].data["text"]);
                  // print(snapshot.data.documents[index].data["text"]);
                  // print(index);

                  final String questionID = docSS.documentID;
                  final String question = docSS.data["text"];

                  return MultiProvider(

                    providers: [
                      Provider<RoomDetails>(create: (_) => RoomDetails(roomName, roomID),),
                      Provider<QuestionDetails>(create: (_) => QuestionDetails(question, questionID))
                    ],

                    child: QuestionTile(
                        questionID: questionID,
                        text: question,
                        roomName: roomName,
                        roomID: roomID),
                  );
                });
          }
        });
  }

  Future<bool> _onBackPressed() async {
    RoomDbService dbService = RoomDbService(roomName, roomID);
    DocumentReference docRef = Firestore.instance.collection("Rooms").document(roomID);

    int currNumUsers = (await docRef.get()).data["numUsers"];
    await docRef.updateData({"numUsers": currNumUsers -= 1});
    await dbService.deleteRoom();
    Navigator.pop(context); // Navigates back to Home()
    return true;
  }

  @override
  Widget build(BuildContext context) {
    RoomDbService dbService = RoomDbService(roomName, roomID);
    DocumentReference docRef = Firestore.instance.collection("Rooms").document(roomID);
    int currNumUsers; //(await docRef.get()).data["numUsers"];

    return Scaffold(
      appBar: new AppBar(
        title: new Text(roomName),
        backgroundColor: Hexcolor('#A38FA3'),
        elevation: 20,
        leading: WillPopScope(
          // ignore: missing_return
          onWillPop: _onBackPressed,
          child: FlatButton(
            child: Icon(Icons.arrow_back_ios),
            onPressed: _onBackPressed,
          ),
        ),
        actions: <Widget>[
          FlatButton.icon(
              onPressed: () => dbService.createQuestion(context, roomName,
                  roomID), // navigate to Question Settings formn
              icon: Icon(Icons.add_circle),
              label: Text("Add a thread!")),
        ],
      ),
      body: CustomScrollView(
        slivers: <Widget>[
          SliverFixedExtentList(
            itemExtent: 600,
            delegate: SliverChildListDelegate([_questionList()]),
          ),
        ],
      ),
    );
  }
}
