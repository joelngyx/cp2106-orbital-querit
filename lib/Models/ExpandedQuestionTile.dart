import 'package:flutter/material.dart';

class ExpandedQuestionTile extends StatefulWidget {
  final String text;
  int netVotes;
  Function toggleExpansion;

  ExpandedQuestionTile(this.text, this.netVotes, this.toggleExpansion);

  @override
  _ExpandedQuestionTileState createState() =>
      _ExpandedQuestionTileState(text, netVotes);
}

class _ExpandedQuestionTileState extends State<ExpandedQuestionTile> {
  final String text;
  int netVotes;

  _ExpandedQuestionTileState(this.text, this.netVotes);

  @override
  Widget build(BuildContext context) {
    return Card(
      child: new Column(
        children: <Widget>[
          new ListTile(
            leading: Text(
                "$netVotes"), // shows votes of this qn on the left of the tile
            title: Text(text,
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 28)),
            trailing: FlatButton(
              child: Icon(Icons.expand_less),
              onPressed: widget.toggleExpansion,
            ),
          )
        ],
      ),
    );
  }
}
