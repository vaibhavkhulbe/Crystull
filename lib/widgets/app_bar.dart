import 'package:crystull/utils/colors.dart';
import 'package:flutter/material.dart';

PreferredSizeWidget getAppBar(
  BuildContext context,
  String title, {
  bool centerTitle = false,
}) {
  return AppBar(
    elevation: 1,
    leading: IconButton(
      icon: const Icon(Icons.arrow_back, color: color575757),
      onPressed: () => Navigator.of(context).pop(),
    ),
    backgroundColor: Colors.white,
    centerTitle: centerTitle,
    title: Text(
      title,
      style: const TextStyle(
        fontFamily: "Poppins",
        color: color575757,
        fontSize: 14,
        height: 1.5,
        fontWeight: FontWeight.w600,
      ),
    ),
  );
}
