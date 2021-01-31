import 'package:flutter/material.dart';
import 'package:orbital_2020_usono_my_ver/Models/User.dart';
import 'package:orbital_2020_usono_my_ver/Services/database/UserDbService.dart';
import 'package:provider/provider.dart';

class ArchivedMessage extends StatelessWidget {
  final String messageID;
  final String message;
  final String question;
  final String roomName;

  ArchivedMessage(this.messageID, this.message, this.question, this.roomName);

  @override
  Widget build(BuildContext context) {


    final user = Provider.of<User>(context);

    return Padding(
      padding: const EdgeInsets.fromLTRB(5, 3, 5, 0),
      child: Card(
        elevation: 3,
        child: ListTile(
          contentPadding: EdgeInsets.fromLTRB(12, 3, 15, 3),
          leading: Text(roomName, style: TextStyle(fontSize: 12),),
          title: Text(question),
          subtitle: Text(message),
          trailing: InkWell(
              child: Text("Delete", style: TextStyle()),
              onTap: () async {
                await UserDbService(uid: user.uid).deleteArchivedMessage(messageID);
              })
        ),
      ),
    );
  }
}

