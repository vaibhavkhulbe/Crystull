import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

BottomNavigationBarItem getBottomNavBarWidget(
    int _currScreen, int widgetScreen, String imgURL,
    {bool isProfile = false, Uint8List? profileImage}) {
  return BottomNavigationBarItem(
    icon: Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(
              width: 2,
              color: _currScreen == widgetScreen
                  ? Colors.lightBlueAccent
                  : Colors.white),
        ),
      ),
      child: isProfile && profileImage != null
          ? CircleAvatar(radius: 20, backgroundImage: MemoryImage(profileImage))
          : SvgPicture.asset(
              imgURL,
              color: _currScreen == widgetScreen
                  ? Colors.lightBlueAccent
                  : Colors.black54,
            ),
    ),
  );
}
