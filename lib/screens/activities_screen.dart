import 'package:crystull/screens/notifications_detail_screen.dart';
import 'package:crystull/utils/colors.dart';
import 'package:crystull/widgets/tabbar.dart';
import 'package:timeago/timeago.dart' as timeago;

import 'package:crystull/providers/user_provider.dart';
import 'package:crystull/resources/auth_methods.dart';
import 'package:crystull/resources/models/signup.dart';
import 'package:crystull/screens/search_screen.dart';
import 'package:crystull/utils/utils.dart';
import 'package:crystull/widgets/app_bar.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class ActivitiesScreen extends StatefulWidget {
  String dropDownValueRec;
  ActivitiesScreen({Key? key, this.dropDownValueRec = "All"}) : super(key: key);

  @override
  State<ActivitiesScreen> createState() => _ActivitiesScreenState();
}

class _ActivitiesScreenState extends State<ActivitiesScreen>
    with TickerProviderStateMixin {
  CrystullUser? _currentUser;
  bool isLoadingCounts = false;
  bool isLoadingData = false;
  String dropDownValueGive = "All";
  int cachedFromIdx = 1;
  int cachedToIdx = 1;
  List<Swap> eventsRec = [];
  List<Swap> eventsGive = [];
  Map<String, Map<String, int>> counts = {
    'cumulative': {},
    'cumulative_given': {},
  };
  Map<String, Map<String, String>> dropDownOptions = {
    'cumulative': {"All": ""},
    'cumulative_given': {"All": ""},
  };
  final List<String> tabs = ['Received', 'Given'];

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
    counts = await AuthMethods().getAttributesCounts(_currentUser!.uid);
    counts.forEach(
      (key, value) => value.forEach(
        (valueKey, valueValue) {
          dropDownOptions[key]![valueKey] = valueKey;
        },
      ),
    );
    eventsRec = await AuthMethods().getIndividualAttributes(
        "",
        _currentUser!.uid,
        dropDownOptions["cumulative"]![widget.dropDownValueRec]!);
    eventsGive = await AuthMethods().getIndividualAttributes(_currentUser!.uid,
        "", dropDownOptions["cumulative_given"]![dropDownValueGive]!);
    setState(() {
      isLoadingCounts = false;
      isLoadingData = false;
    });
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
      appBar: getAppBar(context, "Activities"),
      body: SafeArea(
        child: TabBarView(
          controller: _tabController,
          children: [
            Container(
              height: getSafeAreaHeight(context) * 0.5,
              decoration: const BoxDecoration(color: colorEEEEEE),
              child: ListView(
                children: [
                  getActivitiesSummaryCard(counts['cumulative'],
                      dropDownOptions['cumulative']!, 'received'),
                  getActivityDetailsCard(
                      dropDownOptions['cumulative']!, 'received'),
                ],
              ),
            ),
            Container(
              height: getSafeAreaHeight(context) * 0.5,
              decoration: const BoxDecoration(color: colorEEEEEE),
              child: ListView(
                shrinkWrap: true,
                children: [
                  getActivitiesSummaryCard(counts['cumulative_given'],
                      dropDownOptions['cumulative_given']!, 'given'),
                  getActivityDetailsCard(
                      dropDownOptions['cumulative_given']!, 'given'),
                ],
              ),
            )
          ],
        ),
      ),
    );
  }

  Widget getActivitiesSummaryCard(
      Map<String, int>? counts, Map<String, String> details, String activity) {
    return Card(
      elevation: 0,
      color: mobileBackgroundColor,
      shape: const ContinuousRectangleBorder(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          getTabBar(tabs, _tabController!, cachedFromIdx, cachedToIdx),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                isLoadingCounts
                    ? const Center(
                        child: CircularProgressIndicator(
                          color: primaryColor,
                        ),
                      )
                    : InkWell(
                        onTap: () async {
                          setState(() {
                            isLoadingData = true;
                            activity == "given"
                                ? dropDownValueGive = "All"
                                : widget.dropDownValueRec = "All";
                          });
                          if (activity == 'given') {
                            eventsGive = await AuthMethods()
                                .getIndividualAttributes(_currentUser!.uid, "",
                                    details[dropDownValueGive]!);
                          } else {
                            eventsRec = await AuthMethods()
                                .getIndividualAttributes("", _currentUser!.uid,
                                    details[widget.dropDownValueRec]!);
                          }
                          setState(() {
                            isLoadingData = false;
                          });
                        },
                        child: Container(
                          decoration: BoxDecoration(
                            boxShadow: const [
                              BoxShadow(
                                color: Color.fromARGB(40, 116, 88, 255),
                                blurRadius: 16,
                                spreadRadius: 2,
                              ),
                            ],
                            color: primaryColor,
                            borderRadius: BorderRadius.circular(6),
                          ),
                          padding: const EdgeInsets.symmetric(
                            horizontal: 20,
                            vertical: 16,
                          ),
                          margin: const EdgeInsets.symmetric(
                            vertical: 10,
                          ),
                          child: Row(
                            children: [
                              Text(
                                'Total SWAPs $activity',
                                style: const TextStyle(
                                  fontFamily: "Poppins",
                                  color: mobileBackgroundColor,
                                  fontSize: 14,
                                  height: 1.5,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                              const Spacer(),
                              Text(
                                counts != null && counts.isNotEmpty
                                    ? '${counts.values.reduce((sum, element) => sum + element)}'
                                    : '0',
                                style: const TextStyle(
                                  fontFamily: "Poppins",
                                  color: mobileBackgroundColor,
                                  fontSize: 14,
                                  height: 1.5,
                                  fontWeight: FontWeight.w600,
                                ),
                              )
                            ],
                          ),
                        ),
                      ),
                const SizedBox(height: 16),
                Text(
                  "All SWAPs $activity",
                  style: const TextStyle(
                    fontFamily: "Poppins",
                    fontSize: 14,
                    color: color808080,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                Container(
                  margin: const EdgeInsets.symmetric(vertical: 10),
                  height: getSafeAreaHeight(context) * 0.1,
                  child: isLoadingCounts
                      ? const Center(
                          child: CircularProgressIndicator(
                            color: primaryColor,
                          ),
                        )
                      : ListView(
                          scrollDirection: Axis.horizontal,
                          shrinkWrap: true,
                          children: counts!.entries
                              .map(
                                (value) => InkWell(
                                  onTap: () async {
                                    setState(() {
                                      isLoadingData = true;
                                      activity == "given"
                                          ? dropDownValueGive = value.key
                                          : widget.dropDownValueRec = value.key;
                                    });

                                    if (activity == 'given') {
                                      eventsGive = await AuthMethods()
                                          .getIndividualAttributes(
                                              _currentUser!.uid,
                                              "",
                                              details[dropDownValueGive]!);
                                    } else {
                                      eventsRec = await AuthMethods()
                                          .getIndividualAttributes(
                                              "",
                                              _currentUser!.uid,
                                              details[
                                                  widget.dropDownValueRec]!);
                                    }
                                    setState(() {
                                      isLoadingData = false;
                                    });
                                  },
                                  child: Container(
                                    width: getSafeAreaWidth(context) * 0.25,
                                    margin: const EdgeInsets.symmetric(
                                        horizontal: 4, vertical: 4),
                                    decoration: BoxDecoration(
                                      color: mobileBackgroundColor,
                                      borderRadius: BorderRadius.circular(4),
                                      boxShadow: const [
                                        BoxShadow(
                                          color: Color(0x9FE6E1FF),
                                          blurRadius: 11,
                                          spreadRadius: -2,
                                        )
                                      ],
                                    ),
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 20,
                                      vertical: 10,
                                    ),
                                    child: Column(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Text(
                                          '${value.value}',
                                          style: const TextStyle(
                                            fontFamily: "Poppins",
                                            color: primaryColor,
                                            fontSize: 14,
                                            height: 1.5,
                                            fontWeight: FontWeight.w600,
                                          ),
                                        ),
                                        const Spacer(),
                                        Text(
                                          value.key,
                                          overflow: TextOverflow.ellipsis,
                                          style: const TextStyle(
                                            fontFamily: "Poppins",
                                            color: color808080,
                                            fontSize: 12,
                                            height: 1.5,
                                            fontWeight: FontWeight.w400,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              )
                              .toList(),
                        ),
                )
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget getActivityDetailsCard(Map<String, String> details, String activity) {
    return Card(
      elevation: 0,
      color: mobileBackgroundColor,
      shape: const ContinuousRectangleBorder(),
      child: isLoadingData
          ? const Center(
              child: CircularProgressIndicator(
                color: primaryColor,
              ),
            )
          : Column(children: [
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 8,
                ),
                alignment: Alignment.topRight,
                child: DropdownButton<String>(
                  menuMaxHeight: getSafeAreaHeight(context) * 0.3,
                  dropdownColor: mobileBackgroundColor,
                  style: const TextStyle(
                    fontFamily: "Poppins",
                    color: color808080,
                    fontSize: 10,
                    height: 1.5,
                    fontWeight: FontWeight.w400,
                  ),
                  icon: const Icon(
                    Icons.arrow_drop_down_outlined,
                    color: color808080,
                    size: 9,
                  ),
                  value: activity == 'given'
                      ? dropDownValueGive
                      : widget.dropDownValueRec,
                  items: details.keys
                      .map(
                        (e) => DropdownMenuItem(
                          value: e,
                          child: Text(e),
                        ),
                      )
                      .toList(),
                  onChanged: (e) async {
                    setState(() {
                      isLoadingData = true;
                      if (activity == 'given') {
                        dropDownValueGive = e!;
                      } else {
                        widget.dropDownValueRec = e!;
                      }
                    });
                    if (activity == 'given') {
                      eventsGive = await AuthMethods().getIndividualAttributes(
                          _currentUser!.uid, "", details[dropDownValueGive]!);
                    } else {
                      eventsRec = await AuthMethods().getIndividualAttributes(
                          "",
                          _currentUser!.uid,
                          details[widget.dropDownValueRec]!);
                    }
                    // log(events.toString());
                    setState(() {
                      isLoadingData = false;
                    });
                  },
                ),
              ),
              ListView(
                shrinkWrap: true,
                children: (activity == 'given' ? eventsGive : eventsRec)
                    .map(
                      (e) => InkWell(
                        onTap: () => {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => NotificationDetail(
                                  swap: e, uid: _currentUser!.uid),
                            ),
                          )
                        },
                        child: Container(
                            margin: const EdgeInsets.symmetric(
                              horizontal: 26,
                              vertical: 10,
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  (e.fromUid == _currentUser!.uid
                                          ? "You"
                                          : (e.anonymous
                                              ? "Someone"
                                              : e.fromName.capitalize())) +
                                      " has SWAPed " +
                                      (e.toUid == _currentUser!.uid
                                          ? "you"
                                          : e.toName.capitalize()) +
                                      " for " +
                                      (e.swaps.length > 1
                                          ? "multiple attributes"
                                          : e.swapList.first),
                                  style: const TextStyle(
                                    fontFamily: "Poppins",
                                    color: color8F8E8E,
                                    fontSize: 12,
                                    height: 1.5,
                                    fontWeight: FontWeight.w400,
                                  ),
                                ),
                                Text(
                                  timeago.format(e.addedAt,
                                      allowFromNow: false),
                                  style: const TextStyle(
                                    fontFamily: "Poppins",
                                    color: color8F8E8E,
                                    fontSize: 10,
                                    height: 1.5,
                                    fontWeight: FontWeight.w400,
                                  ),
                                ),
                              ],
                            )),
                      ),
                    )
                    .toList(),
              ),
            ]),
    );
  }
}
