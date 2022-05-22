import 'package:flutter/material.dart';

Widget getAttributesGridFromValues(
  Map<String, double> _swapValues,
  BuildContext context,
) {
  return GridView(
    shrinkWrap: true,
    // padding: const EdgeInsets.all(10),
    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
      crossAxisCount: 3,
      childAspectRatio: 1.2,
      // crossAxisSpacing: 10,
    ),
    children: [
      for (var entry in _swapValues.entries)
        Container(
          padding: const EdgeInsets.symmetric(vertical: 20),
          margin: const EdgeInsets.all(10),
          decoration: const BoxDecoration(color: Color(0xFFEEF9FF)),
          width: MediaQuery.of(context).size.width * 0.3,
          height: MediaQuery.of(context).size.width * 0.05,
          child: Column(children: [
            Text(entry.value.toStringAsFixed(0) + "%",
                style: const TextStyle(
                  fontSize: 16,
                  color: Colors.lightBlueAccent,
                  fontWeight: FontWeight.bold,
                )),
            Flexible(child: Container()),
            Text(entry.key,
                style: const TextStyle(
                  fontSize: 12,
                  height: 1.5,
                  color: Colors.black54,
                )),
          ]),
        )
    ],
  );
}
