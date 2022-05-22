import 'package:crystull/utils/utils.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

class DrawerWidget extends StatelessWidget {
  final String imgURL;
  final String drawerKey;
  final Function() onTap;
  const DrawerWidget(
      {Key? key,
      required this.imgURL,
      required this.drawerKey,
      required this.onTap})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.symmetric(
            vertical: getSafeAreaHeight(context) * 0.02,
            horizontal: getSafeAreaWidth(context) * 0.04),
        child: Row(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              imgURL != ''
                  ? SvgPicture.asset(imgURL,
                      width: getSafeAreaWidth(context) * 0.04)
                  : Icon(Icons.policy_outlined,
                      size: getSafeAreaWidth(context) * 0.04),
              SizedBox(width: getSafeAreaWidth(context) * 0.04),
              Text(drawerKey,
                  style: const TextStyle(color: Colors.black, fontSize: 16)),
            ]),
      ),
    );
  }
}
