import 'package:flutter/material.dart';
import 'package:orbital_2020_usono_my_ver/Settings/ChatRoomSettings.dart';
import 'package:orbital_2020_usono_my_ver/Settings/QuestionSettings.dart';

enum SettingsPanel { chatRoom, question }

class AllSettingsPanel {
  final String roomName;
  final String roomID;

  AllSettingsPanel([this.roomName, this.roomID]);

  void showSettingsPanel(BuildContext context, SettingsPanel selection) {
//    assert(roomID != null);

//    print("roomID in AllSettingsPanel: ")

    switch (selection) {
      case SettingsPanel.chatRoom:
        {
          showModalBottomSheet(

              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.only(
                  topLeft: const Radius.circular(15.0),
                  topRight: const Radius.circular(15.0),
                ),
              ),

              isScrollControlled: true,
              context: context,
              builder: (context) {
                return Container(
//                  decoration: BoxDecoration(
//                    borderRadius: BorderRadius.only(
//                      topLeft: const Radius.circular(25.0),
//                      topRight: const Radius.circular(25.0),
//                    ),
//                  ),
                  height: MediaQuery.of(context).size.height * 0.7,
                  padding: EdgeInsets.symmetric(vertical: 20, horizontal: 60),
                  child: ChatRoomSettingsForm(),
                );
              });
        }
        break;

      case SettingsPanel.question:
        {
          showModalBottomSheet(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.only(
                  topLeft: const Radius.circular(15.0),
                  topRight: const Radius.circular(15.0),
                ),
              ),
              isScrollControlled: true,
              context: context,
              builder: (context) {
                return Container(
//                  decoration: BoxDecoration(
//                    borderRadius: BorderRadius.only(
//                      topLeft: const Radius.circular(25.0),
//                      topRight: const Radius.circular(25.0),
//                    ),
//                  ),
                  height: MediaQuery.of(context).size.height * 0.7,
                  padding: EdgeInsets.symmetric(vertical: 20, horizontal: 60),
                  child: QuestionSettingsForm(roomName, roomID),
                );
              });
        }

        break;
    }
  }
}
