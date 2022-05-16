import 'package:flutter/material.dart';

showAlertDialog(BuildContext context, String title, String message,
    Function()? cancelFunction, Function()? confirmFunction) {
  // set up the buttons
  Widget cancelButton = TextButton(
    child: Text("Cancel", style: TextStyle(color: Colors.lightBlueAccent)),
    onPressed: () {
      Navigator.of(context).pop();
      if (cancelFunction != null) {
        cancelFunction();
      }
    },
  );
  Widget continueButton = TextButton(
    child: Text("Continue", style: TextStyle(color: Colors.lightBlueAccent)),
    onPressed: () {
      Navigator.of(context).pop();
      if (confirmFunction != null) {
        confirmFunction();
      }
    },
  );
  // set up the AlertDialog
  AlertDialog alert = AlertDialog(
    backgroundColor: Colors.white,
    title: Text(title, style: TextStyle(color: Colors.black)),
    content: Text(message, style: TextStyle(color: Colors.black54)),
    actions: [
      cancelButton,
      continueButton,
    ],
  );
  // show the dialog
  showDialog(
    context: context,
    builder: (BuildContext context) {
      return alert;
    },
  );
}
