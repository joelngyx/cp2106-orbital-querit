import 'package:flutter/material.dart';
import 'package:orbital_2020_usono_my_ver/Models/QuestionDetails.dart';
import 'package:orbital_2020_usono_my_ver/Models/RoomDetails.dart';
import 'package:orbital_2020_usono_my_ver/Services/database/RoomDbService.dart';
import 'package:provider/provider.dart';

class EditQuestionTile extends StatefulWidget {
  final Function toggleEdit;

  EditQuestionTile(this.toggleEdit);

  @override
  _EditQuestionTileState createState() => _EditQuestionTileState();
}

class _EditQuestionTileState extends State<EditQuestionTile> {
  final _formKey = GlobalKey<FormState>();
  final int limit = 100;
  RoomDetails roomDetails;
  QuestionDetails questionDetails;

  @override
  void initState() {
    // TODO: implement initState
    roomDetails = Provider.of<RoomDetails>(context, listen: false);
    questionDetails = Provider.of<QuestionDetails>(context, listen: false);

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    TextEditingController _controller = new TextEditingController();
    RoomDbService dbService =
        RoomDbService(roomDetails.roomName, roomDetails.roomID);

    return ConstrainedBox(
      constraints: BoxConstraints(maxHeight: 150),
      child: Card(
        shape: const RoundedRectangleBorder(
          borderRadius: const BorderRadius.all(const Radius.circular(15)),
          side: const BorderSide(color: Colors.blueAccent, width: 2),
        ),
        elevation: 5,
        // color: Colors.purple[100],
        borderOnForeground: true,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(15, 7, 15, 7),
          child: Row(
              // mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                Flexible(
                  flex: 12,
                  child: Form(
                    key: _formKey,
                    child: TextFormField(
                      controller: _controller,
                      keyboardType: TextInputType.multiline,
                      maxLines: 4,
                      validator: (value) => value.length < 6
                          ? "Question is too short"
                          : value.length > limit
                              ? "Question is too long. Please limit it to 100 characters"
                              : null,
                      decoration: InputDecoration(
                        hintText: "Edit your question here...",
                      ),
//                  onSaved: () {
//
//                  },
                    ),
                  ),
                ),
                Spacer(
                  flex: 1,
                ),
                Flexible(
                  flex: 2,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: <Widget>[
                      InkWell(
                          child: Text("Submit"),
                          onTap: () async {
                            if (_formKey.currentState.validate()) {
                              print("Validation pass");
                              print(_controller.text);
                              await dbService.editQuestion(
                                  questionDetails.questionID, _controller.text);
                              print("Edited question with questionID " +
                                  questionDetails.questionID);
                              widget.toggleEdit();
                            }
                          }),
                      InkWell(
                        child: Text("Cancel"),
                        onTap: widget.toggleEdit,
                      ),
                    ],
                  ),
                )
              ]),
        ),
      ),
    );
  }
}

//class EditQuestionTile extends StatelessWidget {
//  final Function toggleEdit;
//  final _formKey = GlobalKey<FormState>();
//  final int limit = 100;
//
//  EditQuestionTile(this.toggleEdit);
//
//  @override
//  Widget build(BuildContext context) {
//    TextEditingController _controller = new TextEditingController();
//
//    return Card(
//      shape: RoundedRectangleBorder(
//        borderRadius: BorderRadius.circular(15),
//      ),
//      elevation: 5,
//      child: Padding(
//        padding: const EdgeInsets.fromLTRB(15, 7, 15, 7),
//        child: Row(
//          // mainAxisSize: MainAxisSize.min,
//          children: <Widget>[
//
//            Flexible(
//              flex: 13,
//              child: TextFormField(
//                keyboardType: TextInputType.multiline,
//                maxLines: 4,
//                key: _formKey,
//                validator: (value) => value.length < 6
//                    ? "Question is too short"
//                    : value.length > limit
//                      ? "Question is too long. Please limit it to 100 characters"
//                      : null,
//                decoration: InputDecoration(
//                  hintText: "Edit your question here...",
//                ),
////                  onSaved: () {
////
////                  },
//              ),
//            ),
//
//            Spacer(
//              flex: 1,
//            ),
//
//            Flexible(
//              flex: 2,
//              child: Column(
//                children: <Widget>[
//                  InkWell(
//                    child: Text("Submit"),
//                    onTap: () async {
//                      if (_formKey.currentState.validate()) {
//                        final roomDetails = Provider.of<RoomDetails>(context);
//                        print("Line 60");
//                        print(roomDetails.roomName);
//                      }
//                    }
//                  ),
//
//                  InkWell(
//                    child: Text("Cancel"),
//                    onTap: toggleEdit,
//                  ),
//                ],
//              ),
//            )
//
//          ]
//        ),
//      ),
//    );
//  }
//}
