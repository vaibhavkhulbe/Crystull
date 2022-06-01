import 'package:crystull/screens/profile_screen.dart';
import 'package:crystull/utils/colors.dart';
import 'package:crystull/utils/utils.dart';
import 'package:flutter/material.dart';

class MultiSelect extends StatefulWidget {
  Map<String, double> selectedValuesMap;
  MultiSelect({Key? key, required this.selectedValuesMap}) : super(key: key);

  @override
  State<MultiSelect> createState() => _MultiSelectState();
}

class _MultiSelectState extends State<MultiSelect> {
  Map<String, bool> selectedValues = {};

  @override
  void initState() {
    for (var element in otherAttributes) {
      selectedValues[element] = false;
    }
    for (var e in widget.selectedValuesMap.keys) {
      if (!primaryAttributes.contains(e)) {
        selectedValues[e] = true;
      }
    }
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      alignment: const Alignment(0, -0.25),
      backgroundColor: mobileBackgroundColor,
      title: const Text(
        "SWAP on more attributes",
        style: TextStyle(
          fontFamily: "Poppins",
          fontSize: 14,
          height: 1.5,
          fontWeight: FontWeight.w600,
          color: color575757,
        ),
      ),
      insetPadding: const EdgeInsets.symmetric(horizontal: 5, vertical: 10),
      content: SizedBox(
        height: MediaQuery.of(context).size.height * 0.08,
        width: MediaQuery.of(context).size.width * 0.8,
        child: DropdownButton(
          underline: Container(
            padding: const EdgeInsets.symmetric(vertical: 5, horizontal: 10),
            decoration: BoxDecoration(
              border: Border.all(
                color: color808080,
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: const [
                Text(
                  "Select",
                  style: TextStyle(
                    fontFamily: "Roboto",
                    fontSize: 14,
                    height: 1.5,
                    color: color808080,
                  ),
                ),
                Icon(
                  Icons.arrow_drop_down_outlined,
                  color: color808080,
                ),
              ],
            ),
          ),
          style: const TextStyle(
            fontFamily: "Poppins",
            color: color808080,
          ),
          dropdownColor: mobileBackgroundColor,
          menuMaxHeight: getSafeAreaHeight(context) * 0.5,
          alignment: AlignmentDirectional.topEnd,
          items: otherAttributes
              .map(
                (e) => DropdownMenuItem(
                  enabled: false,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(e),
                      StatefulBuilder(
                        builder: (context, setState) => Checkbox(
                          checkColor: color808080,
                          activeColor: mobileBackgroundColor,
                          onChanged: (value) {
                            setState(() {
                              if (value == true) {
                                selectedValues[e] = true;
                              } else {
                                selectedValues[e] = false;
                              }
                            });
                          },
                          value: selectedValues[e],
                        ),
                      ),
                    ],
                  ),
                  value: e,
                ),
              )
              .toList(),
          onChanged: (value) {},
        ),
      ),
      actions: <Widget>[
        TextButton(
          child: const Text("Cancel",
              style: TextStyle(
                fontFamily: "Poppins",
                fontSize: 12,
                height: 1.5,
                color: primaryColor,
                fontWeight: FontWeight.w500,
              )),
          onPressed: () {
            Navigator.of(context).pop();
          },
        ),
        TextButton(
          child: Container(
            decoration: const BoxDecoration(
              color: primaryColor,
            ),
            padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 30),
            child: const Text("Done",
                style: TextStyle(
                  fontFamily: "Poppins",
                  fontSize: 12,
                  height: 1.5,
                  color: mobileBackgroundColor,
                  fontWeight: FontWeight.w500,
                )),
          ),
          onPressed: () {
            // remove all unselected values
            selectedValues.removeWhere((key, value) => value == false);
            // add the new values
            for (var value in selectedValues.keys) {
              if (!widget.selectedValuesMap.containsKey(value)) {
                widget.selectedValuesMap[value] = 0;
              } else if (widget.selectedValuesMap.containsKey(value) ||
                  primaryAttributes.contains(value)) {
                continue;
              } else {
                widget.selectedValuesMap.remove(value);
              }
            }
            Navigator.of(context).pop(widget.selectedValuesMap);
          },
        )
      ],
    );
  }
}
