import 'package:crystull/resources/models/signup.dart';
import 'package:crystull/screens/connected_friends_screen.dart';
import 'package:crystull/screens/login_screen.dart';
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
          EdgeInsets.symmetric(vertical: getSafeAreaHeight(context) * 0.02),
      height: getSafeAreaHeight(context) * 0.2,
      decoration: BoxDecoration(
        color: Colors.lightBlue[50],
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
          SizedBox(height: getSafeAreaHeight(context) * 0.04),
          Text(user.firstName + " " + user.lastName,
              style: const TextStyle(color: Colors.black)),
        ],
      ),
    ),
    DrawerWidget(
        imgURL: 'images/icons/activities.svg',
        drawerKey: 'Activities',
        onTap: () {}),
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
                fontSize: 12,
                fontWeight: FontWeight.bold,
                color: Colors.black)),
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
            child: Text('Logout',
                style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                    color: Colors.black))),
        onTap: () {
          _auth.signOut();
          Navigator.pushReplacement(context,
              MaterialPageRoute(builder: (context) => const LoginScreen()));
        }),
  ];
}
