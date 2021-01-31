
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:orbital_2020_usono_my_ver/Models/Message.dart';
import 'package:orbital_2020_usono_my_ver/Models/User.dart';
import 'package:orbital_2020_usono_my_ver/Settings/AllSettingsPanel.dart';


class RoomDbService { // manages the Rooms collection in the database, and thus all the messages in each room as well

  final String roomName;
  final String roomID;
  RoomDbService([this.roomName, this.roomID]);
  CollectionReference roomsCollection = Firestore.instance.collection("Rooms");

  Future createChatRoom(String roomName) async { // creates a chat room. The plan is to make each room a document in the Rooms collection, then there is a subcollection of messages in each room.
    dynamic result = await roomsCollection.add({"roomName": roomName, "timeCreated": DateTime.now().millisecondsSinceEpoch, "numUsers": 1});
    return result.documentID; // calling this function will return the room's ID, which is used by the route handler to pass arguments
  }

  Future deleteRoom() async { // calling this function will check if it meets the conditions for the room to be deleted first
    DocumentSnapshot docSS = await roomsCollection.document(roomID).get();
    int numUsers = docSS.data["numUsers"];
    int timeNow = DateTime.now().millisecondsSinceEpoch;
    int timeDifference = timeNow - docSS.data["timeCreated"];

    if (numUsers == 0 && timeDifference >= 36000000) { // if no users and it has been more than 10 hours since the room is created, delete that room
      await roomsCollection.document(roomID).delete();
      print("Room with name " + roomName + " has been deleted");
    }

  }


  Future sendMessage(String msg, String sender, String questionID) async { // adds the message to the database

    try {
      CollectionReference messages = roomsCollection.document(roomID).collection("Questions").document(questionID).collection("Messages");
      dynamic result = await messages.add({
        "text": msg,
        "from": sender,
        "time": DateTime.now().millisecondsSinceEpoch,
        "votes": 0,
        "voteMap": new Map<String,dynamic>(),
      });

    } catch(e) {
      print(e.toString());
    }
  }

  Future createQuestion(BuildContext context, String roomName, String roomID) { // will call sendQuestion
    try {
//      print("roomID in createQuestion: " + roomID);
      AllSettingsPanel(roomName, roomID).showSettingsPanel(context, SettingsPanel.question);

    } catch(e) {
      print(e.toString);
    }
  }

  Future sendQuestion(String qn, String senderUID) async {
    try {
      CollectionReference questions = roomsCollection.document(roomID).collection("Questions");
      // print("roomID: " + "$roomID");
      await questions.add({
        "text": qn,
        "from": senderUID,
        "time": DateTime.now().millisecondsSinceEpoch,
        "votes": 0,
        "voteMap": new Map<String,dynamic>(),
        // additional features like tags?
      });
    } catch(e) {
      print(e.toString());
    }
  }

    Stream<QuerySnapshot> getQuestionMessages(String questionID) {
      return roomsCollection.document(roomID).collection('Questions').document(questionID).collection('Messages').orderBy("time").snapshots(); // will change order to votes later
    }

    Stream<QuerySnapshot> getRoomQuestions() {
      return roomsCollection.document(roomID).collection('Questions').orderBy("votes", descending: true).snapshots(); // change to order by votes later
    }

//    Future<void> upvoteQuestion(String questionID) {
//      roomsCollection.document(roomID).collection('Questions').document(questionID).updateData({"votes": })
//    }

    Stream<DocumentSnapshot> getQuestionVotes(String questionID) {
      return roomsCollection.document(roomID).collection('Questions').document(questionID).snapshots();
    }


    Stream<DocumentSnapshot> getMessageVotes(String questionID, String messageID) {
      return roomsCollection.document(roomID).collection('Questions').document(questionID).collection('Messages').document(messageID).snapshots();
    }
    
    Future<String> getQuestionVoteStatus(String userID, String questionID) async {
      Map<String,dynamic> voteMap = (await roomsCollection.document(roomID).collection('Questions').document(questionID).get()).data["voteMap"];
      if (voteMap.containsKey(userID)) {
        return voteMap[userID];
      } else { // not initialised yet
        return "Neutral";
      }
    }

    Future<String> getMessageVoteStatus(String userID, String questionID, String messageID) async {
      Map<String,dynamic> voteMap = (await roomsCollection.document(roomID).collection('Questions').document(questionID)
          .collection('Messages').document(messageID).get()).data["voteMap"];
      if (voteMap.containsKey(userID)) {
        return voteMap[userID];
      } else { // not initialised yet
        return "Neutral";
      }
    }

    // To implement voting, we will have to add a Map<String, bool> to each question in the database. Create a function
    // that will add the user's uid and the bool false as a kv pair to the question's map in the db, if the entry doesnt exist
    // This is done everytime for the question that the user clicks on the upvote or downvote button for.

    Future upvoteQuestion(String userID, String questionID) async {
//
      DocumentReference relevantQn = roomsCollection.document(roomID).collection('Questions').document(questionID);
//
      int currVotes;
      bool keyExists;
      String voteStatus;

      await relevantQn.get().then((docSS) => {
        keyExists = docSS.data["voteMap"].containsKey(userID),
        if (keyExists) {
          voteStatus = docSS.data["voteMap"][userID],
          currVotes = docSS.data["votes"],
        }
      });

      if (!keyExists) {
        await relevantQn.get().then((docSS) => {
          currVotes = docSS.data["votes"],
          // print("currVotes: $currVotes"),
          relevantQn.updateData({"votes": currVotes += 1})
        });
        relevantQn.updateData({"voteMap.$userID": "Upvoted"});

      } else {
        if (voteStatus == "Upvoted") { // revoke upvote
          await relevantQn.updateData({"voteMap.$userID": "Neutral"});
          await relevantQn.updateData({"votes": currVotes -= 1});
          print("userID $userID has neutralised the upvote");
        } else if (voteStatus == "Neutral") {
          await relevantQn.updateData({"voteMap.$userID": "Upvoted"});
          await relevantQn.updateData({"votes": currVotes += 1});
          print("userID $userID has upvoted this question");
        } else { // this user downvoted this qn previously
          await relevantQn.updateData({"voteMap.$userID": "Upvoted"});
          await relevantQn.updateData({"votes" : currVotes += 2});
          print("userID $userID who has previously downvoted this question has now upvoted it");
        }
      }
    }

  Future downvoteQuestion(String userID, String questionID) async {
//
    DocumentReference relevantQn = roomsCollection.document(roomID).collection(
        'Questions').document(questionID);
//
    int currVotes;
    bool keyExists;
    String voteStatus;

    await relevantQn.get().then((docSS) =>
    {
      keyExists = docSS.data["voteMap"].containsKey(userID),
      if (keyExists) {
        voteStatus = docSS.data["voteMap"][userID],
        currVotes = docSS.data["votes"],
      }
    });

    if (!keyExists) {
      await relevantQn.get().then((docSS) =>
      {
        currVotes = docSS.data["votes"],
        // print("currVotes: $currVotes"),
        relevantQn.updateData({"votes": currVotes -= 1})
      });
      relevantQn.updateData({"voteMap.$userID": "Downvoted"});
    } else {
      if (voteStatus == "Downvoted") { // revoke downvote
        await relevantQn.updateData({"voteMap.$userID": "Neutral"});
        await relevantQn.updateData({"votes": currVotes += 1});
        print("userID $userID has neutralised the downvote");
      } else if (voteStatus == "Neutral") {
        await relevantQn.updateData({"voteMap.$userID": "Downvoted"});
        await relevantQn.updateData({"votes": currVotes -= 1});
        print("userID $userID has downvoted this question");
      } else { // this user upvoted this qn previously
        await relevantQn.updateData({"voteMap.$userID": "Downvoted"});
        await relevantQn.updateData({"votes": currVotes -= 2});
        print(
            "userID $userID who has previously upvoted this question has now downvoted it");
      }
    }
  }


  Future upvoteMessage(String messageID, String questionID, String userID) async {
    DocumentReference relevantMsg = roomsCollection.document(roomID).collection('Questions')
        .document(questionID).collection('Messages').document(messageID);

    int currVotes;
    bool keyExists;
    String voteStatus;

    await relevantMsg.get().then((docSS) => {
      keyExists = docSS.data["voteMap"].containsKey(userID),
      if (keyExists) {
        voteStatus = docSS.data["voteMap"][userID],
        currVotes = docSS.data["votes"],
      }
    });

    if (!keyExists) {
      await relevantMsg.get().then((docSS) => {
        currVotes = docSS.data["votes"],
        // print("currVotes: $currVotes"),
        relevantMsg.updateData({"votes": currVotes += 1})
      });
      relevantMsg.updateData({"voteMap.$userID": "Upvoted"});

    } else {
      if (voteStatus == "Upvoted") { // revoke upvote
        await relevantMsg.updateData({"voteMap.$userID": "Neutral"});
        await relevantMsg.updateData({"votes": currVotes -= 1});
        print("userID $userID has neutralised the upvote");
      } else if (voteStatus == "Neutral") {
        await relevantMsg.updateData({"voteMap.$userID": "Upvoted"});
        await relevantMsg.updateData({"votes": currVotes += 1});
        print("userID $userID has upvoted this message");
      } else { // this user downvoted this qn previously
        await relevantMsg.updateData({"voteMap.$userID": "Upvoted"});
        await relevantMsg.updateData({"votes" : currVotes += 2});
        print("userID $userID who has previously downvoted this message has now upvoted it");
      }
    }
  }

  Future downvoteMessage(String messageID, String questionID, String userID) async {
    DocumentReference relevantMsg = roomsCollection.document(roomID).collection('Questions')
        .document(questionID).collection('Messages').document(messageID);

    int currVotes;
    bool keyExists;
    String voteStatus;

    await relevantMsg.get().then((docSS) => {
      keyExists = docSS.data["voteMap"].containsKey(userID),
      if (keyExists) {
        voteStatus = docSS.data["voteMap"][userID],
        currVotes = docSS.data["votes"],
      }
    });

    if (!keyExists) {
      await relevantMsg.get().then((docSS) => {
        currVotes = docSS.data["votes"],
        // print("currVotes: $currVotes"),
        relevantMsg.updateData({"votes": currVotes -= 1})
      });
      relevantMsg.updateData({"voteMap.$userID": "Downvoted"});

    } else {
      if (voteStatus == "Downvoted") { // revoke downvote
        await relevantMsg.updateData({"voteMap.$userID": "Neutral"});
        await relevantMsg.updateData({"votes": currVotes += 1});
        print("userID $userID has neutralised the downvote");
      } else if (voteStatus == "Neutral") {
        await relevantMsg.updateData({"voteMap.$userID": "Downvoted"});
        await relevantMsg.updateData({"votes": currVotes -= 1});
        print("userID $userID has downvoted this message");
      } else { // this user upvoted this qn previously
        await relevantMsg.updateData({"voteMap.$userID": "Downvoted"});
        await relevantMsg.updateData({"votes": currVotes -= 2});
        print(
            "userID $userID who has previously upvoted this message has now downvoted it");
      }
    }
  }


  Future editQuestion(String questionID, String newQuestion) async {
    CollectionReference questions = roomsCollection.document(roomID).collection("Questions");
    await questions.document(questionID).updateData({"text": newQuestion}); // should we save the time that is edited?
  }

  Future deleteQuestion(String questionID) async {
    CollectionReference questions = roomsCollection.document(roomID).collection("Questions");
    await questions.document(questionID).delete();
  }

  Future deleteMessage() async {

  }
}