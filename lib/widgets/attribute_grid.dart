import 'package:crystull/resources/models/signup.dart';
import 'package:crystull/utils/colors.dart';
import 'package:flutter/material.dart';

Widget getAttributesGridFromValues(
  Map<String, AttributeDetails> _swapAttributeDetails,
  Map<String, double> _swapValues,
  BuildContext context,
) {
  return GridView(
    shrinkWrap: true,
    physics: const NeverScrollableScrollPhysics(),
    // padding: const EdgeInsets.all(10),
    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
      crossAxisCount: 3,
      childAspectRatio: 1.2,
    ),
    children: [
      for (var entry in _swapValues.entries)
        Container(
          padding: const EdgeInsets.only(top: 12, bottom: 20),
          margin: const EdgeInsets.symmetric(vertical: 5, horizontal: 10),
          decoration: const BoxDecoration(color: Color(0xFFEEF9FF)),
          width: MediaQuery.of(context).size.width * 0.3,
          height: MediaQuery.of(context).size.height * 0.03,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              Text(
                entry.value.toStringAsFixed(0) + "%",
                style: const TextStyle(
                  fontFamily: "Poppins",
                  fontSize: 16,
                  height: 1.5,
                  color: primaryColor,
                  fontWeight: FontWeight.w600,
                ),
              ),
              // const Spacer(),
              FittedBox(
                child: Text(
                  entry.key,
                  style: const TextStyle(
                    fontFamily: "Poppins",
                    fontSize: 12,
                    height: 1.5,
                    color: color808080,
                    fontWeight: FontWeight.w400,
                  ),
                ),
              ),
              if (_swapAttributeDetails[entry.key] != null)
                Text(
                  "(" +
                      _swapAttributeDetails[entry.key]!.count.toString() +
                      (_swapAttributeDetails[entry.key]!.count != 1
                          ? " SWAPs)"
                          : " SWAP)"),
                  style: const TextStyle(
                    fontFamily: "Poppins",
                    fontSize: 10,
                    height: 1.5,
                    color: primaryColor,
                    fontWeight: FontWeight.w400,
                  ),
                )
            ],
          ),
        )
    ],
  );
}
