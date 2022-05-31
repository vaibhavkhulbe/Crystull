import 'dart:typed_data';

import 'package:crystull/providers/user_provider.dart';
import 'package:crystull/resources/auth_methods.dart';
import 'package:crystull/resources/models/signup.dart';
import 'package:crystull/resources/storage_methods.dart';
import 'package:crystull/screens/notifications_detail_screen.dart';
import 'package:crystull/screens/search_screen.dart';
import 'package:crystull/utils/colors.dart';
import 'package:crystull/utils/utils.dart';
import 'package:crystull/widgets/tabbar.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:timeago/timeago.dart' as timeago;

class NotificationsScreen extends StatefulWidget {
  const NotificationsScreen({Key? key}) : super(key: key);

  @override
  State<NotificationsScreen> createState() => _NotificationsScreenState();
}

class _NotificationsScreenState extends State<NotificationsScreen>
    with TickerProviderStateMixin {
  CrystullUser? _currentUser;
  bool isLoadingCounts = false;
  bool isLoadingData = false;
  int cachedFromIdx = 1;
  int cachedToIdx = 1;
  List<Swap> eventsAll = [];
  Map<String, Uint8List> eventsPics = {};
  List<Swap> eventsUnread = [];

  final List<String> tabs = ['All', 'Unread'];

  TabController? _tabController;

  @override
  void didChangeDependencies() {
    _tabController = TabController(
        vsync: this, length: tabs.length, animationDuration: Duration.zero);
    _currentUser = Provider.of<UserProvider>(context).getUser;
    getCounts();
    super.didChangeDependencies();
  }

  void getCounts() async {
    setState(() {
      isLoadingCounts = true;
      isLoadingData = true;
    });
    eventsAll =
        await AuthMethods().getIndividualAttributes("", _currentUser!.uid, "");
    eventsUnread = await AuthMethods()
        .getIndividualAttributes("", _currentUser!.uid, "", unreadOnly: true);

    for (var event in eventsAll) {
      if (eventsPics.containsKey(event.fromUid)) {
        continue;
      }
      var eventPic = await StorageMethods()
          .downloadUserImage("profilePics", event.fromUid);
      if (eventPic != null) {
        eventsPics[event.fromUid] = eventPic;
      }
    }
    for (var event in eventsUnread) {
      if (eventsPics.containsKey(event.fromUid)) {
        continue;
      } else {
        var eventPic = await StorageMethods()
            .downloadUserImage("profilePics", event.fromUid);
        if (eventPic != null) {
          eventsPics[event.fromUid] = eventPic;
        }
      }
    }
    if (mounted) {
      setState(() {
        isLoadingCounts = false;
        isLoadingData = false;
      });
    }
  }

  @override
  void dispose() {
    _tabController!.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    _currentUser = Provider.of<UserProvider>(context).getUser;
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 1,
        leading: null,
        centerTitle: false,
        title: const Text(
          'Notifications',
          style: TextStyle(
              color: Colors.black87,
              fontSize: 16,
              height: 1.5,
              fontWeight: FontWeight.bold),
        ),
      ),
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            getTabBar(tabs, _tabController!, cachedFromIdx, cachedToIdx),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              height: getSafeAreaHeight(context) * 0.5,
              width: getSafeAreaWidth(context),
              child: TabBarView(
                controller: _tabController,
                children: [
                  Container(
                    decoration: const BoxDecoration(color: Color(0xFFFBFEFF)),
                    child: ListView(
                      children: [
                        getActivityDetailsCard('all'),
                      ],
                    ),
                  ),
                  Container(
                    decoration: const BoxDecoration(color: Color(0xFFFBFEFF)),
                    child: ListView(
                      shrinkWrap: true,
                      children: [
                        getActivityDetailsCard('unread'),
                      ],
                    ),
                  )
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget getActivityDetailsCard(String activity) {
    return Card(
      elevation: 0,
      color: Colors.white,
      shape: const ContinuousRectangleBorder(),
      child: isLoadingData
          ? const Center(
              child: CircularProgressIndicator(
                color: primaryColor,
              ),
            )
          : ((activity == 'unread' ? eventsUnread : eventsAll).isEmpty
              ? SizedBox(
                  height: getSafeAreaHeight(context) * 0.5,
                  child: const Center(
                    child: Text(
                      'No new notifications yet',
                      style: TextStyle(
                        fontFamily: "Poppins",
                        color: Color(0xFF8F8E8E),
                        fontSize: 18,
                        fontWeight: FontWeight.w400,
                      ),
                    ),
                  ),
                )
              : Column(
                  children: [
                    ListView(
                      shrinkWrap: true,
                      children: (activity == 'unread'
                              ? eventsUnread
                              : eventsAll)
                          .map(
                            (e) => InkWell(
                              onTap: () async {
                                await AuthMethods().markSwapRead(e.id);
                                setState(() {
                                  getCounts();
                                });
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => NotificationDetail(
                                        swap: e, uid: _currentUser!.uid),
                                  ),
                                );
                              },
                              child: Container(
                                  color: e.unread
                                      ? const Color(0xFFEDF9FF)
                                      : Colors.white,
                                  padding: const EdgeInsets.symmetric(
                                    vertical: 10,
                                  ),
                                  child: Row(
                                    children: [
                                      Container(
                                          width:
                                              getSafeAreaWidth(context) * 0.1,
                                          height:
                                              getSafeAreaWidth(context) * 0.1,
                                          decoration: BoxDecoration(
                                            shape: BoxShape.circle,
                                            color: Colors.black54,
                                            image: DecorationImage(
                                              fit: BoxFit.cover,
                                              image:
                                                  eventsPics[e.fromUid] != null
                                                      ? Image.memory(eventsPics[
                                                              e.fromUid]!)
                                                          .image
                                                      : const ExactAssetImage(
                                                          'images/avatar.png'),
                                            ),
                                          )),
                                      const SizedBox(
                                        width: 10,
                                      ),
                                      Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            e.anonymous
                                                ? "Someone"
                                                : e.fromName.capitalize() +
                                                    (e.swaps.length > 1
                                                        ? " has SWAPed you for multiple attributes"
                                                        : " has SWAPed you for " +
                                                            e.swapList.first),
                                            style: const TextStyle(
                                                fontFamily: "Poppins",
                                                color: Color(0xFF8F8E8E),
                                                fontSize: 10,
                                                height: 1.4,
                                                fontWeight: FontWeight.w400),
                                          ),
                                          Text(
                                            timeago.format(e.addedAt,
                                                allowFromNow: false),
                                            style: const TextStyle(
                                                fontFamily: "Poppins",
                                                color: Color(0xFF8F8E8E),
                                                fontSize: 8,
                                                fontWeight: FontWeight.w400),
                                          ),
                                        ],
                                      ),
                                    ],
                                  )),
                            ),
                          )
                          .toList(),
                    ),
                  ],
                )),
    );
  }
}
