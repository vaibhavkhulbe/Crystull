import 'package:crystull/providers/user_provider.dart';
import 'package:crystull/resources/models/signup.dart';
import 'package:crystull/screens/home_screen.dart';
import 'package:crystull/screens/profile_screen.dart';
import 'package:crystull/widgets/bottom_nav_bar_item.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class MobileScreenLayout extends StatefulWidget {
  const MobileScreenLayout({
    Key? key,
  }) : super(key: key);

  @override
  State<MobileScreenLayout> createState() => _MobileScreenLayoutState();
}

class _MobileScreenLayoutState extends State<MobileScreenLayout> {
  int _screen = 0;
  late PageController _pageController;
  // SignupForm _signupForm;
  // final FirebaseAuth _auth = FirebaseAuth.instance;
  // final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  @override
  void initState() {
    super.initState();
    addData();
    _pageController = PageController();
  }

  addData() async {
    UserProvider userProvider =
        Provider.of<UserProvider>(context, listen: false);
    await userProvider.refreshUser();
  }

  @override
  void dispose() {
    super.dispose();
    _pageController.dispose();
  }

  void navigateToPage(int page) {
    _pageController.jumpToPage(page);
  }

  void onPageChanged(int page) {
    setState(() {
      _screen = page;
    });
  }

  @override
  Widget build(BuildContext context) {
    CrystullUser? _user = Provider.of<UserProvider>(context).getUser;
    return _user != null
        ? Scaffold(
            body: PageView(
              controller: _pageController,
              onPageChanged: onPageChanged,
              children: [
                const HomeScreen(),
                const Text("FriendRequests",
                    style: TextStyle(color: Colors.black)),
                const Text("Notifications",
                    style: TextStyle(color: Colors.black)),
                ProfileScreen(user: _user, isHome: true),
              ],
            ),
            bottomNavigationBar: CupertinoTabBar(
                backgroundColor: Colors.white,
                onTap: navigateToPage,
                items: [
                  getBottomNavBarWidget(
                      _screen, 0, 'images/icons/homeButton.svg'),
                  getBottomNavBarWidget(
                      _screen, 1, 'images/icons/friendRequests.svg'),
                  getBottomNavBarWidget(
                      _screen, 2, 'images/icons/notifications.svg'),
                  getBottomNavBarWidget(_screen, 3, 'images/avatar.png',
                      isProfile: true, profileImage: _user.profileImage),
                ]),
          )
        : const Center(
            child: CircularProgressIndicator(
            color: Colors.lightBlueAccent,
            backgroundColor: Colors.white,
          ));
  }
}
