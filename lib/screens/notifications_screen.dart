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
  CrystullUser user;
  NotificationsScreen({Key? key, required this.user}) : super(key: key);

  @override
  State<NotificationsScreen> createState() => _NotificationsScreenState();
}

class _NotificationsScreenState extends State<NotificationsScreen>
    with TickerProviderStateMixin {
  bool isLoadingData = false;
  int cachedFromIdx = 1;
  int cachedToIdx = 1;
  Map<String, List<Swap>> events = {
    "all": [],
    'unread': [],
  };
  Map<String, Uint8List> eventsPics = {};

  final List<String> tabs = ['All', 'Unread'];

  TabController? _tabController;

  @override
  void initState() {
    _tabController = TabController(
        vsync: this, length: tabs.length, animationDuration: Duration.zero);

    super.initState();
  }

  @override
  void didChangeDependencies() {
    var _user = Provider.of<UserProvider>(context).getUser;
    if (_user != null) {
      widget.user = _user;
    }
    getCounts();
    super.didChangeDependencies();
  }

  void getCounts() async {
    setState(() {
      isLoadingData = true;
    });
    events["all"] =
        await AuthMethods().getIndividualAttributes("", widget.user.uid, "");
    events["unread"] = await AuthMethods()
        .getIndividualAttributes("", widget.user.uid, "", unreadOnly: true);

    for (var eventEntries in events.values) {
      for (var event in eventEntries) {
        if (eventsPics.containsKey(event.fromUid)) {
          continue;
        }
        var eventPic = await StorageMethods()
            .downloadUserImage("profilePics", event.fromUid);
        if (eventPic != null) {
          eventsPics[event.fromUid] = eventPic;
        }
      }
    }
    if (mounted) {
      setState(() {
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
    return Scaffold(
      appBar: AppBar(
        backgroundColor: mobileBackgroundColor,
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
            Expanded(
              child: TabBarView(
                controller: _tabController,
                children: [
                  Container(
                    decoration: const BoxDecoration(color: Color(0xFFFBFEFF)),
                    child: isLoadingData
                        ? const Center(
                            child: CircularProgressIndicator(
                              color: primaryColor,
                            ),
                          )
                        : (!events.containsKey('all') || events['all']!.isEmpty
                            ? SizedBox(
                                height: getSafeAreaHeight(context) * 0.5,
                                child: const Center(
                                  child: Text(
                                    'No new notifications yet',
                                    style: TextStyle(
                                      fontFamily: "Poppins",
                                      color: color8F8E8E,
                                      fontSize: 18,
                                      fontWeight: FontWeight.w400,
                                    ),
                                  ),
                                ),
                              )
                            : ListView(
                                shrinkWrap: true,
                                children: getActivityDetailsCard('all'),
                              )),
                  ),
                  Container(
                    decoration: const BoxDecoration(color: Color(0xFFFBFEFF)),
                    child: isLoadingData
                        ? const Center(
                            child: CircularProgressIndicator(
                              color: primaryColor,
                            ),
                          )
                        : (!events.containsKey('all') || events['all']!.isEmpty
                            ? SizedBox(
                                height: getSafeAreaHeight(context) * 0.5,
                                child: const Center(
                                  child: Text(
                                    'No new notifications yet',
                                    style: TextStyle(
                                      fontFamily: "Poppins",
                                      color: color8F8E8E,
                                      fontSize: 18,
                                      fontWeight: FontWeight.w400,
                                    ),
                                  ),
                                ),
                              )
                            : ListView(
                                shrinkWrap: true,
                                children: getActivityDetailsCard('unread'),
                              )),
                  )
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  List<Widget> getActivityDetailsCard(String activity) {
    return events[activity]!
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
                  builder: (context) =>
                      NotificationDetail(swap: e, uid: widget.user.uid),
                ),
              );
            },
            child: Container(
                color:
                    e.unread ? const Color(0xFFEDF9FF) : mobileBackgroundColor,
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 10,
                ),
                child: Row(
                  children: [
                    Container(
                        width: getSafeAreaWidth(context) * 0.1,
                        height: getSafeAreaWidth(context) * 0.1,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: Colors.black54,
                          image: DecorationImage(
                            fit: BoxFit.cover,
                            image: eventsPics[e.fromUid] != null
                                ? Image.memory(eventsPics[e.fromUid]!).image
                                : const ExactAssetImage('images/avatar.png'),
                          ),
                        )),
                    const SizedBox(
                      width: 10,
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Wrap(
                          children: [
                            Text(
                              e.anonymous ? "Someone" : e.fromName.capitalize(),
                              style: const TextStyle(
                                fontFamily: "Poppins",
                                color: color8F8E8E,
                                fontSize: 10,
                                height: 1.4,
                                fontWeight: FontWeight.w400,
                              ),
                            ),
                            const Text(
                              " has SWAPed you for ",
                              style: TextStyle(
                                fontFamily: "Poppins",
                                color: color8F8E8E,
                                fontSize: 10,
                                height: 1.4,
                                fontWeight: FontWeight.w400,
                              ),
                            ),
                            Text(
                              e.swaps.length > 1
                                  ? "multiple attributes"
                                  : e.swapList.first,
                              style: const TextStyle(
                                fontFamily: "Poppins",
                                color: color8F8E8E,
                                fontSize: 10,
                                height: 1.4,
                                fontWeight: FontWeight.w400,
                              ),
                            ),
                          ],
                        ),
                        Text(
                          timeago.format(e.addedAt, allowFromNow: false),
                          style: const TextStyle(
                              fontFamily: "Poppins",
                              color: color8F8E8E,
                              fontSize: 8,
                              fontWeight: FontWeight.w400),
                        ),
                      ],
                    ),
                  ],
                )),
          ),
        )
        .toList();
  }
}
