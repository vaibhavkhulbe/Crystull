import 'package:crystull/resources/auth_methods.dart';
import 'package:crystull/utils/colors.dart';
import 'package:crystull/widgets/alert_dialog.dart';
import 'package:crystull/widgets/app_bar.dart';
import 'package:crystull/widgets/get_switch.dart';
import 'package:flutter/material.dart';
import 'package:crystull/widgets/text_field_widget.dart';
import 'package:crystull/resources/models/signup.dart';
import '../utils/utils.dart';

class EditProfileScreen extends StatefulWidget {
  final CrystullUser user;
  const EditProfileScreen({Key? key, required this.user}) : super(key: key);

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  final TextEditingController _bioController = TextEditingController();
  final TextEditingController _collegeController = TextEditingController();
  final TextEditingController _degreeController = TextEditingController();
  var _isLoading = false;

  @override
  void initState() {
    super.initState();
    _bioController.text = widget.user.bio;
    _collegeController.text = widget.user.college;
    _degreeController.text = widget.user.degree;
  }

  @override
  void dispose() {
    super.dispose();
    _bioController.dispose();
    _collegeController.dispose();
    _degreeController.dispose();
  }

  List<String> nullCheck() {
    List<String> _nullCheck = [];
    if (_bioController.text.isEmpty) {
      _nullCheck.add("Please add your Bio");
    }
    return _nullCheck;
  }

  updateUser() async {
    widget.user.bio = _bioController.text;
    widget.user.college = _collegeController.text;
    widget.user.degree = _degreeController.text;
    setState(() {
      _isLoading = true;
    });
    String result = await AuthMethods().updateUserPersonalDetails(widget.user);
    if (result != "Success") {
      showSnackBar("User update failed with error: " + result, context);
    } else {
      showSnackBar("User updated successfully.", context);
    }

    setState(() {
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: getAppBar(context, "Edit profile"),
      body: Container(
        decoration: const BoxDecoration(color: Color(0xFFE5E5E5)),
        child: ListView(
          children: [
            Card(
              elevation: 0,
              color: mobileBackgroundColor,
              shape: const RoundedRectangleBorder(
                borderRadius: BorderRadius.zero,
              ),
              child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10),
                  width: getSafeAreaWidth(context),
                  height: getSafeAreaHeight(context) * 0.1,
                  child: Row(
                    children: [
                      const Text(
                        "Private account",
                        style: TextStyle(
                          fontFamily: "Poppins",
                          fontSize: 13,
                          color: color808080,
                          fontWeight: FontWeight.w400,
                        ),
                      ),
                      const Spacer(),
                      getSwitch(
                        activeColor: primaryColor,
                        inactiveColor: secondaryColor,
                        value: widget.user.isPrivate,
                        onChanged: (value) async {
                          if (value) {
                            String message =
                                "If you change your account to private, only top three attributes will be visible to everyone with scores.";
                            showAlertDialog(context, "Are you sure?", message,
                                () {
                              widget.user.isPrivate = false;
                              setState(() {});
                            }, () async {
                              widget.user.isPrivate = true;
                              String res = await AuthMethods()
                                  .updateUserPrivacy(widget.user);
                              if (res != "Success") {
                                showSnackBar(
                                    "Privacy update failed with error: " + res,
                                    context);
                              } else {
                                showSnackBar(
                                    "Your profile is now private.", context);
                              }
                            });
                          } else {
                            String message =
                                "If you change your account to public, all the attributes will be visible to everyone with scores.";
                            showAlertDialog(context, "Are you sure?", message,
                                () {
                              widget.user.isPrivate = true;
                              setState(() {});
                            }, () async {
                              widget.user.isPrivate = false;
                              String res = await AuthMethods()
                                  .updateUserPrivacy(widget.user);
                              if (res != "Success") {
                                showSnackBar(
                                    "Privacy update failed with error: " + res,
                                    context);
                              } else {
                                showSnackBar(
                                    "Your profile is now public.", context);
                              }
                            });
                            widget.user.isPrivate = false;
                          }
                          widget.user.isPrivate = value;
                          setState(() {});
                        },
                      ),
                    ],
                  )),
            ),
            Card(
              elevation: 0,
              color: mobileBackgroundColor,
              shape: const RoundedRectangleBorder(
                borderRadius: BorderRadius.zero,
              ),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 10),
                width: getSafeAreaWidth(context),
                height: getSafeAreaHeight(context) * 0.7,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Spacer(flex: 1),
                    const Text(
                      "Personal details",
                      style: TextStyle(
                        fontFamily: "Poppins",
                        fontSize: 14,
                        height: 1.5,
                        fontWeight: FontWeight.w600,
                        color: color575757,
                      ),
                    ),
                    const Spacer(flex: 1),
                    // Bio text box
                    const Text(
                      "Bio*",
                      style: TextStyle(
                        fontFamily: "Poppins",
                        fontSize: 12,
                        height: 1.5,
                        fontWeight: FontWeight.w400,
                        color: color575757,
                      ),
                    ),
                    TextFieldInput(
                      textEditingController: _bioController,
                      hintText: "Enter your bio",
                      textInputType: TextInputType.text,
                    ),

                    const Spacer(flex: 2),

                    // College text box
                    const Text(
                      "School/College",
                      style: TextStyle(
                        fontFamily: "Poppins",
                        fontSize: 12,
                        height: 1.5,
                        fontWeight: FontWeight.w400,
                        color: color575757,
                      ),
                    ),
                    TextFieldInput(
                      textEditingController: _collegeController,
                      hintText: "Enter your college",
                      textInputType: TextInputType.text,
                    ),

                    const Spacer(flex: 2),

                    // Email text box
                    const Text(
                      "Degree",
                      style: TextStyle(
                        fontFamily: "Poppins",
                        fontSize: 12,
                        height: 1.5,
                        fontWeight: FontWeight.w400,
                        color: color575757,
                      ),
                    ),
                    TextFieldInput(
                      textEditingController: _degreeController,
                      hintText: "Enter your Degree",
                      textInputType: TextInputType.emailAddress,
                    ),

                    const Spacer(flex: 2),

                    // button to sign up
                    InkWell(
                      onTap: () {
                        List<String> message;
                        message = nullCheck();
                        if (message.isEmpty) {
                          updateUser();
                          Navigator.pop(context);
                        } else {
                          for (String s in message) {
                            showSnackBar(s, context);
                          }
                        }
                      },
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          Container(
                            child: _isLoading
                                ? const CircularProgressIndicator(
                                    color: mobileBackgroundColor,
                                  )
                                : const Text(
                                    "Update",
                                    style: TextStyle(
                                      fontFamily: "Poppins",
                                      fontSize: 12,
                                      height: 1.5,
                                      fontWeight: FontWeight.w600,
                                      color: mobileBackgroundColor,
                                    ),
                                  ),
                            width: getSafeAreaWidth(context) * 0.3,
                            alignment: Alignment.center,
                            padding: const EdgeInsets.symmetric(vertical: 10),
                            decoration: BoxDecoration(
                              border: Border.all(color: primaryColor, width: 2),
                              color: primaryColor,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const Spacer(flex: 5),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
