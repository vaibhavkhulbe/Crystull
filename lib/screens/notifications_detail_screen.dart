import 'package:crystull/resources/models/signup.dart';
import 'package:crystull/screens/search_screen.dart';
import 'package:crystull/utils/colors.dart';
import 'package:crystull/utils/utils.dart';
import 'package:crystull/widgets/app_bar.dart';
import 'package:crystull/widgets/slider_grid.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';

class NotificationDetail extends StatelessWidget {
  final Swap swap;
  final String uid;
  final String fromUserName;
  final String toUserName;
  const NotificationDetail(
      {Key? key,
      required this.swap,
      required this.uid,
      required this.fromUserName,
      required this.toUserName})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: getAppBar(context, "Notifications"),
      body: SingleChildScrollView(
        child: SafeArea(
          child: Container(
            height: getSafeAreaHeight(context),
            alignment: Alignment.topCenter,
            color: colorEEEEEE,
            child: Container(
              color: const Color(0xFFFBFEFF),
              height: getSafeAreaHeight(context) * 0.6,
              child: Column(
                children: [
                  Container(
                    padding: const EdgeInsets.all(20),
                    color: const Color(0xFFEDF9FF),
                    margin: const EdgeInsets.symmetric(
                        horizontal: 25, vertical: 19),
                    child: Row(
                      children: [
                        SvgPicture.asset("images/notificationFilled.svg",
                            color: primaryColor, height: 28, width: 24),
                        const SizedBox(width: 37),
                        SizedBox(
                          width: MediaQuery.of(context).size.width * 0.6,
                          child: Text(
                            (swap.fromUid == uid
                                    ? "You"
                                    : (swap.anonymous
                                        ? "Someone"
                                        : fromUserName.capitalize())) +
                                " has SWAPed " +
                                (swap.toUid == uid
                                    ? "you"
                                    : toUserName.capitalize()) +
                                " for " +
                                (swap.swaps.length > 1
                                    ? "multiple attributes"
                                    : swap.swapList.first),
                            style: const TextStyle(
                              fontFamily: "Poppins",
                              fontSize: 12,
                              height: 1.5,
                              fontWeight: FontWeight.w500,
                              color: primaryColor,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  GridView(
                      shrinkWrap: true,
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      gridDelegate:
                          const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 2,
                        childAspectRatio: 2.5,
                        crossAxisSpacing: 50,
                      ),
                      children: [
                        for (var entry in swap.swaps.entries)
                          getSliderWidgetWithLabel(
                              entry.key, entry.value, (value) {})
                      ])
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
