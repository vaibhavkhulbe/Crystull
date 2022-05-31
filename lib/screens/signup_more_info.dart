import 'dart:typed_data';

import 'package:crystull/resources/auth_methods.dart';
import 'package:crystull/responsive/mobile_screen_layout.dart';
import 'package:crystull/responsive/response_layout_screen.dart';
import 'package:crystull/responsive/web_screen_layout.dart';
import 'package:crystull/screens/signup_screen.dart';
import 'package:crystull/utils/colors.dart';
import 'package:flutter/material.dart';
import 'package:country_code_picker/country_code_picker.dart';
import 'package:crystull/widgets/text_field_widget.dart';
import 'package:email_auth/email_auth.dart';
import 'package:image_picker/image_picker.dart';
import 'package:crystull/resources/models/signup.dart';
import '../utils/utils.dart';

class MoreInfoScreen extends StatefulWidget {
  final CrystullUser signupForm;
  final EmailAuth emailAuth;
  const MoreInfoScreen(
      {Key? key, required this.signupForm, required this.emailAuth})
      : super(key: key);

  @override
  State<MoreInfoScreen> createState() => _MoreInfoScreenState();
}

class _MoreInfoScreenState extends State<MoreInfoScreen> {
  final TextEditingController _bioController = TextEditingController();
  final TextEditingController _collegeController = TextEditingController();
  final TextEditingController _degreeController = TextEditingController();
  final TextEditingController _mobileController = TextEditingController();
  Uint8List? _profileImage;
  var _isLoading = false;

  @override
  void dispose() {
    super.dispose();
    _bioController.dispose();
    _collegeController.dispose();
    _degreeController.dispose();
    _mobileController.dispose();
    _profileImage = null;
  }

  void selectImage() async {
    Uint8List? _image = await pickImage(ImageSource.gallery);
    Uint8List _compressedImage;
    if (_image != null) {
      _compressedImage = await compressList(_image);
      setState(() {
        _profileImage = _compressedImage;
      });
    } else {
      //User canceled the picker. You need do something here, or just add return
      return;
    }
  }

  List<String> nullCheck() {
    List<String> _nullCheck = [];
    if (_profileImage == null) {
      _nullCheck.add("Please add your Profile Image");
    }
    if (_bioController.text.isEmpty) {
      _nullCheck.add("Please add your Bio");
    }
    if (_mobileController.text.isEmpty) {
      _nullCheck.add("Please add your Mobile Number");
    }
    return _nullCheck;
  }

  signUpUser() {
    widget.signupForm.bio = _bioController.text;
    widget.signupForm.college = _collegeController.text;
    widget.signupForm.degree = _degreeController.text;
    widget.signupForm.mobileNumberWithCountryCode = _mobileController.text;
    widget.signupForm.profileImage = _profileImage;
    setState(() {
      _isLoading = true;
    });
    Future<String> result =
        AuthMethods().signUpUser(signupForm: widget.signupForm);
    result.then((value) {
      if (value != "Success") {
        showSnackBar("User creation failed with error: " + value, context);

        Navigator.pushReplacement(context,
            MaterialPageRoute(builder: (context) {
          return const SignupScreen();
        }));
      } else {
        showSnackBar(
            "User added successfully. Please login to continue", context);

        Navigator.pushReplacement(context,
            MaterialPageRoute(builder: (context) {
          return ResponsiveLayout(
              webScreenLayout: const WebScreenLayout(),
              mobileScreenLayout: MobileScreenLayout());
        }));
      }
    }).catchError((onError) {
      showSnackBar(
          "User creation failed with error: " + onError.toString(), context);

      Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) {
        return const SignupScreen();
      }));
    });
    setState(() {
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        child: SafeArea(
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 32),
            width: getSafeAreaWidth(context),
            height: getSafeAreaHeight(context),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Flexible(child: Container(), flex: 4),
                // Welcome statement
                Text(
                  "Welcome " + widget.signupForm.firstName + "!",
                  style: const TextStyle(
                    fontSize: 30,
                    fontWeight: FontWeight.bold,
                    color: primaryColor,
                  ),
                ),

                Flexible(child: Container(), flex: 1),

                const Text(
                  "Help us to know more about you",
                  style: TextStyle(
                    fontSize: 18,
                    color: Colors.black87,
                  ),
                ),

                Flexible(child: Container(), flex: 2),
                _profileImage != null
                    ? Center(
                        child: CircleAvatar(
                          radius: 64,
                          backgroundImage: MemoryImage(_profileImage!),
                        ),
                      )
                    : const Center(
                        child: CircleAvatar(
                          radius: 64,
                          backgroundImage: ExactAssetImage('images/avatar.png'),
                        ),
                      ),

                Center(
                  child: InkWell(
                    onTap: selectImage,
                    child: const Text("Add Photo",
                        style: TextStyle(
                          color: primaryColor,
                          fontWeight: FontWeight.bold,
                        )),
                  ),
                ),

                // Email text box
                const Text(
                  "Bio",
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.black54,
                  ),
                ),
                TextFieldInput(
                  textEditingController: _bioController,
                  hintText: "Enter your bio",
                  textInputType: TextInputType.text,
                ),

                Flexible(child: Container(), flex: 1),

                // Email text box
                const Text(
                  "School/College",
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.black54,
                  ),
                ),
                TextFieldInput(
                  textEditingController: _collegeController,
                  hintText: "Enter your college",
                  textInputType: TextInputType.text,
                ),

                Flexible(child: Container(), flex: 1),

                // Email text box
                const Text(
                  "Degree",
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.black54,
                  ),
                ),
                TextFieldInput(
                  textEditingController: _degreeController,
                  hintText: "Enter your Degree",
                  textInputType: TextInputType.emailAddress,
                ),

                Flexible(child: Container(), flex: 1),

                // Password text box
                const Text(
                  "Phone Number*",
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.black54,
                  ),
                ),

                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Flexible(
                      flex: 10,
                      child: Container(
                        // margin: const EdgeInsets.only(bottom: 13),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(4),
                          border: Border.all(
                            color: Colors.black38,
                            width: 0.5,
                          ),
                        ),
                        child: CountryCodePicker(
                          alignLeft: true,
                          showFlagDialog: true,
                          showFlag: false,
                          textStyle: const TextStyle(
                            fontSize: 14,
                            color: Colors.black87,
                          ),
                          initialSelection: '+91',
                          showCountryOnly: false,
                          showOnlyCountryWhenClosed: false,

                          // options for the dropdown
                          closeIcon: const Icon(
                            Icons.close,
                            color: Colors.black,
                          ),
                          searchDecoration: InputDecoration(
                            hintText: "Enter your country code",
                            hintStyle: const TextStyle(
                              color: Colors.black54,
                            ),
                            enabledBorder: UnderlineInputBorder(
                              borderSide: Divider.createBorderSide(context,
                                  color: Colors.black54, width: 0.5),
                            ),
                          ),
                          backgroundColor: Colors.white,
                          dialogTextStyle: const TextStyle(
                            fontSize: 14,
                            color: Colors.black87,
                          ),
                          searchStyle: const TextStyle(
                            fontSize: 14,
                            color: Colors.black87,
                          ),
                        ),
                      ),
                    ),
                    Flexible(
                      child: Container(),
                      flex: 1,
                    ),
                    Flexible(
                      child: Container(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(4),
                          border: Border.all(
                            color: Colors.black38,
                            width: 0.5,
                          ),
                        ),
                        child: TextFieldWidgetNoFlex(
                          textEditingController: _mobileController,
                          hintText: "Enter your Phone Number",
                          textInputType: TextInputType.phone,
                          borderWidth: 0,
                        ),
                      ),
                      flex: 20,
                    ),
                  ],
                ),

                Flexible(child: Container(), flex: 1),

                // button to sign up
                InkWell(
                  onTap: () {
                    List<String> message;
                    message = nullCheck();
                    if (message.isEmpty) {
                      signUpUser();
                    } else {
                      for (String s in message) {
                        showSnackBar(s, context);
                      }
                    }
                  },
                  child: Container(
                    child: _isLoading
                        ? const CircularProgressIndicator(
                            color: Colors.white,
                          )
                        : const Text("Sign up",
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            )),
                    width: double.infinity,
                    alignment: Alignment.center,
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    decoration: BoxDecoration(
                      border: Border.all(color: primaryColor, width: 2),
                      color: primaryColor,
                    ),
                  ),
                ),
                Flexible(child: Container(), flex: 2),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
