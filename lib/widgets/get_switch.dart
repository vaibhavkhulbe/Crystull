import 'package:flutter/material.dart';


 Widget getSwitch(
      {required bool value,
      required Function onChanged,
      required Color activeColor,
      required Color inactiveColor}) {
    Duration _kSwitchAnimationDuration = const Duration(milliseconds: 250);
    return GestureDetector(
      onTap: () => onChanged(!value),
      child: SizedBox(
        height: 20,
        width: 42,
        child: Stack(
          children: [
            AnimatedContainer(
              height: 20,
              width: 42,
              curve: Curves.ease,
              duration: _kSwitchAnimationDuration,
              decoration: BoxDecoration(
                borderRadius: const BorderRadius.all(
                  Radius.circular(17.0),
                ),
                color: value ? activeColor : inactiveColor,
              ),
            ),
            AnimatedAlign(
              curve: Curves.ease,
              duration: _kSwitchAnimationDuration,
              alignment: !value ? Alignment.centerLeft : Alignment.centerRight,
              child: Container(
                height: 14,
                width: 14,
                margin: const EdgeInsets.symmetric(horizontal: 3),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.white,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black12.withOpacity(0.1),
                      spreadRadius: 0.5,
                      blurRadius: 1,
                    )
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }