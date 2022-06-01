import 'package:crystull/utils/colors.dart';
import 'package:flutter/material.dart';

showAlertDialog(BuildContext context, String title, String message,
    Function()? cancelFunction, Function()? confirmFunction) {
  // set up the buttons
  Widget cancelButton = TextButton(
    child: const Text(
      "Cancel",
      style: TextStyle(
        fontFamily: "Poppins",
        fontSize: 12,
        height: 1.5,
        fontWeight: FontWeight.w500,
        color: primaryColor,
      ),
    ),
    onPressed: () {
      Navigator.of(context).pop();
      if (cancelFunction != null) {
        cancelFunction();
      }
    },
  );
  Widget continueButton = TextButton(
    child: const Text(
      "Continue",
      style: TextStyle(
        fontFamily: "Poppins",
        fontSize: 12,
        height: 1.5,
        fontWeight: FontWeight.w500,
        color: primaryColor,
      ),
    ),
    onPressed: () {
      Navigator.of(context).pop();
      if (confirmFunction != null) {
        confirmFunction();
      }
    },
  );
  // set up the AlertDialog
  AlertDialog alert = AlertDialog(
    backgroundColor: mobileBackgroundColor,
    title: Text(
      title,
      style: const TextStyle(
        fontFamily: "Poppins",
        fontSize: 14,
        height: 1.5,
        fontWeight: FontWeight.w600,
        color: color575757,
      ),
    ),
    content: Text(
      message,
      style: const TextStyle(
        fontFamily: "Poppins",
        fontSize: 12,
        height: 1.5,
        fontWeight: FontWeight.w400,
        color: color7A7A7A,
      ),
    ),
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
