import 'package:crystull/resources/models/signup.dart';
import 'package:crystull/responsive/mobile_screen_layout.dart';
import 'package:crystull/screens/activities_screen.dart';
import 'package:crystull/screens/connected_friends_screen.dart';
import 'package:crystull/screens/login_screen.dart';
import 'package:crystull/screens/search_screen.dart';
import 'package:crystull/utils/colors.dart';
import 'package:crystull/utils/utils.dart';
import 'package:crystull/widgets/drawer_widget.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

List<Widget> getDrawerList(BuildContext context, CrystullUser user) {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  int friendCount = 0;
  user.connections.forEach((key, value) {
    if (value.status == 3) {
      friendCount++;
    }
  });
  return [
    SvgPicture.asset(
      'images/crystull_logo.svg',
      height: getSafeAreaHeight(context) * 0.05,
      width: getSafeAreaWidth(context) * 0.2,
    ),
    SizedBox(
      height: getSafeAreaHeight(context) * 0.02,
    ),
    Container(
      padding:
          EdgeInsets.symmetric(vertical: getSafeAreaHeight(context) * 0.03),
      height: getSafeAreaHeight(context) * 0.2,
      decoration: const BoxDecoration(
        color: Color(0xFFE7F7FF),
      ),
      child: Column(
        children: [
          Center(
            child: CircleAvatar(
              radius: getSafeAreaWidth(context) * 0.1,
              backgroundImage: user.profileImage != null
                  ? Image.memory(user.profileImage!).image
                  : const ExactAssetImage('images/avatar.png'),
            ),
          ),
          Flexible(child: Container()),
          GestureDetector(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => MobileScreenLayout(screen: 3),
                ),
              );
            },
            child: Text(user.fullName.capitalize(),
                style: const TextStyle(
                  fontFamily: "Poppins",
                  color: color575757,
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                )),
          ),
        ],
      ),
    ),
    DrawerWidget(
        imgURL: 'images/icons/activities.svg',
        drawerKey: 'Activities',
        onTap: () => Navigator.push(context,
            MaterialPageRoute(builder: (context) => ActivitiesScreen()))),
    InkWell(
      onTap: () => Navigator.push(
          context,
          MaterialPageRoute(
              builder: (context) => const ConnectedFriendsScreen())),
      child: Row(children: [
        DrawerWidget(
            imgURL: 'images/icons/network.svg',
            drawerKey: 'Connections',
            onTap: () => Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (context) => const ConnectedFriendsScreen()))),
        Flexible(
          child: Container(),
          flex: 10,
        ),
        Text(friendCount.toString(),
            style: const TextStyle(
                fontFamily: "Poppins",
                fontSize: 10,
                fontWeight: FontWeight.w600,
                color: color575757)),
        Flexible(child: Container()),
      ]),
    ),
    SizedBox(
      height: getSafeAreaHeight(context) * 0.25,
    ),
    DrawerWidget(imgURL: '', drawerKey: 'Terms and Policy', onTap: () {}),
    DrawerWidget(
        imgURL: 'images/icons/settings.svg',
        drawerKey: 'Settings',
        onTap: () {}),
    DrawerWidget(
        imgURL: 'images/icons/help.svg', drawerKey: 'Help', onTap: () {}),
    InkWell(
        child: const Center(
          child: Text(
            'Logout',
            style: TextStyle(
              fontFamily: "Poppins",
              fontWeight: FontWeight.w600,
              fontSize: 12,
              color: color575757,
            ),
          ),
        ),
        onTap: () {
          _auth.signOut();
          Navigator.pushReplacement(context,
              MaterialPageRoute(builder: (context) => const LoginScreen()));
        }),
  ];
}
