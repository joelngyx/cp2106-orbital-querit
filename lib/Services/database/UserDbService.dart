import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:orbital_2020_usono_my_ver/Models/User.dart';


class UserDbService {
  final String uid;
  UserDbService({this.uid});
  CollectionReference userCollection = Firestore.instance.collection('Users');

  Future updateUserData(String name) async {
    await userCollection.document(uid).setData({"Name": name});
    // await userCollection.document(uid).collection("Archived Messages").add({});
  }


  Future<String> getNameFromUser() async { // since User objects don't have a name attribute
    // await userCollection.document(uid).get().then((doc) => doc.data["Name"]);
    DocumentSnapshot docSS = await userCollection.document(uid).get();
    return docSS.data["Name"];
  }

  Future addArchivedMessage(String message, String messageID, String question, String roomName, String sender) async {
    CollectionReference archivedCollection = userCollection.document(uid).collection("Archived Messages");

    await archivedCollection.document(messageID).setData({
      "roomName": roomName,
      "question": question,
      "message": message,
      "from": sender,
    });
  }

  Future deleteArchivedMessage(String messageID) async {
    return userCollection.document(uid).collection("Archived Messages").document(messageID).delete();
  }

  Future<bool> getMessageArchivedStatus(String messageID) async {
    var docSS = await userCollection.document(uid).collection("Archived Messages").document(messageID).get();

    return docSS.exists ? true : false;
  }

  Stream<QuerySnapshot> getUserArchivedMessages() {
    return userCollection.document(uid).collection("Archived Messages").snapshots();
  }
}