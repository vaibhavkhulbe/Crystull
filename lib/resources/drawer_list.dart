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

List<Widget> getDrawerList(
    BuildContext context, CrystullUser user, Map<String, double> _swapValues) {
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
      child: GestureDetector(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => MobileScreenLayout(screen: 4),
            ),
          );
        },
        child: Column(
          children: [
            SizedBox(
              height: getSafeAreaHeight(context) * 0.1,
              child: Center(
                child: Stack(
                  clipBehavior: Clip.none,
                  children: [
                    Positioned(
                      child: CircleAvatar(
                        radius: getSafeAreaHeight(context) * 0.05,
                        backgroundImage: user.profileImage != null
                            ? Image.memory(user.profileImage!).image
                            : const ExactAssetImage('images/avatar.png'),
                      ),
                    ),
                    // SWAP
                    Positioned(
                      top: (MediaQuery.of(context).size.height * 0.08),
                      left: (MediaQuery.of(context).size.width * 0.0725),
                      child: Container(
                        alignment: Alignment.center,
                        padding: const EdgeInsets.symmetric(vertical: 2.5),
                        width: 22,
                        height: 22,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: mobileBackgroundColor,
                          border: Border.all(
                            color: primaryColor,
                            width: 1,
                          ),
                        ),
                        child: Text(
                          _swapValues.isEmpty
                              ? '0'
                              : (_swapValues.values.reduce(
                                          (value, element) => value + element) /
                                      (_swapValues.values.length * 10))
                                  .round()
                                  .toString(),
                          style: const TextStyle(
                            fontFamily: "Poppins",
                            fontSize: 9,
                            height: 1.5,
                            fontWeight: FontWeight.w600,
                            color: primaryColor,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const Spacer(),
            Text(
              user.fullName.capitalize(),
              style: const TextStyle(
                fontFamily: "Poppins",
                color: color575757,
                fontSize: 12,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
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
        const Spacer(
          flex: 10,
        ),
        Text(friendCount.toString(),
            style: const TextStyle(
                fontFamily: "Poppins",
                fontSize: 10,
                fontWeight: FontWeight.w600,
                color: color575757)),
        const Spacer(),
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
          while (Navigator.canPop(context)) {
            Navigator.pop(context);
          }
          Navigator.push(context,
              MaterialPageRoute(builder: (context) => const LoginScreen()));
        }),
  ];
}
