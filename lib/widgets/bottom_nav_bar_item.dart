import 'dart:typed_data';

import 'package:crystull/utils/colors.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

BottomNavigationBarItem getBottomNavBarWidget(
    int _currScreen, int widgetScreen, String imgURL,
    {bool isProfile = false, Uint8List? profileImage, int imageCount = 0}) {
  return BottomNavigationBarItem(
    icon: Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(
              width: 2,
              color: _currScreen == widgetScreen
                  ? primaryColor
                  : mobileBackgroundColor),
        ),
      ),
      child: isProfile
          ? CircleAvatar(
              radius: 20,
              backgroundImage: profileImage != null
                  ? MemoryImage(profileImage)
                  : Image.asset(imgURL).image)
          : Stack(
              clipBehavior: Clip.none,
              children: [
                SvgPicture.asset(
                  imgURL,
                  width: 20,
                  color: _currScreen == widgetScreen
                      ? primaryColor
                      : Colors.black54,
                ),
                if (imageCount > 0)
                  Positioned(
                    top: -5,
                    right: -10,
                    child: Text(
                      " " + imageCount.toString() + " ",
                      style: const TextStyle(
                        fontFamily: "Poppins",
                        fontSize: 8,
                        fontWeight: FontWeight.w400,
                        backgroundColor: colorFF3225,
                        color: secondaryColor,
                      ),
                    ),
                  )
              ],
            ),
    ),
  );
}
