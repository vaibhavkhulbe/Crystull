import 'package:flutter/material.dart';

Widget getStatusButton(Color boxColor, Color borderColor, String text,
    Color textColor, Function() function,
    {double radius = 0,
    double fontSize = 12,
    FontWeight? fontWeight = FontWeight.w400}) {
  return InkWell(
    onTap: function,
    child: Container(
      margin: const EdgeInsets.symmetric(horizontal: 2, vertical: 10),
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
      decoration: BoxDecoration(
        border: Border.all(color: borderColor, width: 1),
        borderRadius: BorderRadius.circular(radius),
        color: boxColor,
      ),
      child: Text(
        text,
        style: TextStyle(
          fontFamily: "Poppins",
          fontWeight: fontWeight,
          color: textColor,
          fontSize: fontSize,
          height: 1.5,
        ),
      ),
    ),
  );
}
