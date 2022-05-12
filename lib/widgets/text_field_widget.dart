import 'package:flutter/material.dart';

class TextFieldInput extends StatelessWidget {
  final TextEditingController textEditingController;
  final bool isPassword;
  final String hintText;
  final TextInputType textInputType;
  final Color borderColor;
  final double borderWidth;

  const TextFieldInput(
      {Key? key,
      required this.textEditingController,
      this.isPassword = false,
      required this.hintText,
      required this.textInputType,
      this.borderColor = Colors.black38,
      this.borderWidth = 0.5})
      : super(key: key);
  @override
  Widget build(BuildContext context) {
    final focusedBorder = OutlineInputBorder(
        borderSide: Divider.createBorderSide(context,
            color: borderColor, width: borderWidth));
    return Flexible(
      flex: 3,
      child: TextField(
        cursorColor: Colors.black,
        controller: textEditingController,
        style: const TextStyle(color: Colors.black),
        decoration: InputDecoration(
            hintText: hintText,
            border: focusedBorder,
            focusedBorder: focusedBorder,
            enabledBorder: focusedBorder,
            filled: true,
            contentPadding: const EdgeInsets.all(8)),
        keyboardType: textInputType,
        obscureText: isPassword,
      ),
    );
  }
}

class TextFieldWidgetNoFlex extends StatelessWidget {
  final TextEditingController textEditingController;
  final bool isPassword;
  final String hintText;
  final TextInputType textInputType;
  final Color borderColor;
  final double borderWidth;

  const TextFieldWidgetNoFlex(
      {Key? key,
      required this.textEditingController,
      this.isPassword = false,
      required this.hintText,
      required this.textInputType,
      this.borderColor = Colors.black38,
      this.borderWidth = 0.5})
      : super(key: key);
  @override
  Widget build(BuildContext context) {
    final focusedBorder = OutlineInputBorder(
        borderSide: Divider.createBorderSide(context,
            color: borderColor, width: borderWidth));
    return TextField(
      cursorColor: Colors.black,
      controller: textEditingController,
      style: const TextStyle(color: Colors.black),
      decoration: InputDecoration(
          hintText: hintText,
          border: focusedBorder,
          focusedBorder: focusedBorder,
          enabledBorder: focusedBorder,
          filled: true,
          contentPadding: const EdgeInsets.all(8)),
      keyboardType: textInputType,
      obscureText: isPassword,
    );
  }
}
