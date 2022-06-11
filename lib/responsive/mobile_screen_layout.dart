import 'package:crystull/providers/user_provider.dart';
import 'package:crystull/resources/models/signup.dart';
import 'package:crystull/screens/friend_request_screen.dart';
import 'package:crystull/screens/home_screen.dart';
import 'package:crystull/screens/notifications_screen.dart';
import 'package:crystull/screens/profile_screen.dart';
import 'package:crystull/utils/colors.dart';
import 'package:crystull/utils/utils.dart';
import 'package:crystull/widgets/bottom_nav_bar_item.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class MobileScreenLayout extends StatefulWidget {
  int screen;
  MobileScreenLayout({Key? key, this.screen = 0}) : super(key: key);

  @override
  State<MobileScreenLayout> createState() => _MobileScreenLayoutState();
}

class _MobileScreenLayoutState extends State<MobileScreenLayout> {
  late PageController _pageController;

  @override
  void initState() {
    super.initState();
    addData();
    _pageController = PageController(initialPage: widget.screen);
    // navigateToPage(widget.screen);
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
      widget.screen = page;
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
                const FriendRequestScreen(),
                NotificationsScreen(user: _user),
                ProfileScreen(user: _user, isHome: true),
              ],
            ),
            bottomNavigationBar: CupertinoTabBar(
                backgroundColor: mobileBackgroundColor,
                onTap: navigateToPage,
                items: [
                  getBottomNavBarWidget(
                      widget.screen, 0, 'images/icons/homeButton.svg'),
                  getBottomNavBarWidget(
                      widget.screen, 1, 'images/icons/friendRequests.svg'),
                  getBottomNavBarWidget(
                      widget.screen, 2, 'images/icons/notifications.svg'),
                  getBottomNavBarWidget(widget.screen, 3, 'images/avatar.png',
                      isProfile: true, profileImage: _user.profileImage),
                ]),
          )
        : SafeArea(
            child: Container(
              height: getSafeAreaHeight(context),
              width: getSafeAreaWidth(context),
              color: mobileBackgroundColor,
              child: const Center(
                  child: CircularProgressIndicator(
                color: primaryColor,
                backgroundColor: mobileBackgroundColor,
              )),
            ),
          );
  }
}
