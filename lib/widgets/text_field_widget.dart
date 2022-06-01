import 'package:crystull/utils/colors.dart';
import 'package:flutter/material.dart';

class TextFieldInput extends StatefulWidget {
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
  State<TextFieldInput> createState() => _TextFieldInputState();
}

class _TextFieldInputState extends State<TextFieldInput> {
  bool _passwordVisible = false;
  @override
  void initState() {
    _passwordVisible = false;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final focusedBorder = OutlineInputBorder(
        borderSide: Divider.createBorderSide(context,
            color: widget.borderColor, width: widget.borderWidth));

    return Flexible(
      flex: 3,
      child: TextField(
        cursorColor: color666666,
        controller: widget.textEditingController,
        style: const TextStyle(
          fontFamily: "Poppins",
          color: color666666,
        ),
        decoration: InputDecoration(
          hintText: widget.hintText,
          hintStyle: const TextStyle(
            fontFamily: "Poppins",
            color: colorBCBCBC,
            fontSize: 16,
          ),
          border: focusedBorder,
          focusedBorder: focusedBorder,
          enabledBorder: focusedBorder,
          filled: true,
          contentPadding: const EdgeInsets.all(8),
          suffixIcon: widget.isPassword
              ? IconButton(
                  icon: Icon(
                    // Based on passwordVisible state choose the icon
                    _passwordVisible ? Icons.visibility : Icons.visibility_off,
                    color: colorBCBCBC,
                  ),
                  onPressed: () {
                    // Update the state i.e. toogle the state of passwordVisible variable
                    setState(() {
                      _passwordVisible = !_passwordVisible;
                    });
                  },
                )
              : null,
        ),
        keyboardType: widget.textInputType,
        obscureText: widget.isPassword && !_passwordVisible,
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
      borderSide: Divider.createBorderSide(
        context,
        color: borderColor,
        width: borderWidth,
      ),
    );
    return TextField(
      cursorColor: Colors.black,
      controller: textEditingController,
      style: const TextStyle(
        fontFamily: "Poppins",
        color: Colors.black,
      ),
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
