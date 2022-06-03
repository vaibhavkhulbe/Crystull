import 'package:crystull/resources/auth_methods.dart';
import 'package:crystull/responsive/mobile_screen_layout.dart';
import 'package:crystull/responsive/response_layout_screen.dart';
import 'package:crystull/responsive/web_screen_layout.dart';
import 'package:crystull/screens/login_screen.dart';
import 'package:crystull/utils/colors.dart';
import 'package:crystull/utils/utils.dart';
import 'package:flutter/material.dart';
import 'package:crystull/widgets/text_field_widget.dart';
import 'package:email_auth/email_auth.dart';
import 'package:crystull/resources/models/signup.dart';
import 'package:crystull/screens/email_otp_screen.dart';
import 'package:flutter_svg/flutter_svg.dart';

class SignupScreen extends StatefulWidget {
  const SignupScreen({Key? key}) : super(key: key);

  @override
  State<SignupScreen> createState() => _SignupHomeScreenState();
}

class _SignupHomeScreenState extends State<SignupScreen> {
  final TextEditingController _firstNameController = TextEditingController();
  final TextEditingController _lastNameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController =
      TextEditingController();

  final EmailAuth _emailAuth = EmailAuth(sessionName: "Crystull Sign Up");
  var otpStatus = "";
  var _isLoading = false;

  @override
  void dispose() {
    super.dispose();
    _firstNameController.dispose();
    _lastNameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
  }

  void handleSignupResult(Future<String> result) {
    result.then((value) {
      if (value != "Success") {
        showSnackBar("User login failed with error: " + value, context);

        setState(() {
          _isLoading = false;
        });
      } else {
        showSnackBar("User logged in successfully.", context);
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) {
              return ResponsiveLayout(
                  webScreenLayout: const WebScreenLayout(),
                  mobileScreenLayout: MobileScreenLayout());
            },
          ),
        );
        setState(() {
          _isLoading = false;
        });
      }
    }).catchError((onError) {
      showSnackBar(
          "User login failed with error: " + onError.toString(), context);

      setState(() {
        _isLoading = false;
      });
    });
  }

  Future<bool> sendOTP() async {
    setState(() {
      otpStatus = "Sending OTP...";
      _isLoading = true;
    });
    showSnackBar(otpStatus, context);
    // send OTP to user's email
    var res = await _emailAuth.sendOtp(
      recipientMail: _emailController.value.text,
      otpLength: 6,
    );
    return res;
  }

  List<String> nullCheck() {
    List<String> _nullCheck = [];
    if (_firstNameController.text.isEmpty) {
      _nullCheck.add("Please add your first name");
    }
    if (_emailController.text.isEmpty) {
      _nullCheck.add("Please add your email");
    }
    if (_passwordController.text.isEmpty) {
      _nullCheck.add("Please add your password");
    }
    if (_confirmPasswordController.text.isEmpty) {
      _nullCheck.add("Please enter the password again");
    }
    if (_passwordController.text != _confirmPasswordController.text) {
      _nullCheck.add("Password does not match");
    }
    return _nullCheck;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        child: SafeArea(
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 32),
            width: double.infinity,
            height: getSafeAreaHeight(context),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Spacer(flex: 3),
                // Add logo
                // SvgPicture.asset('images/crystull_logo.svg', height: 64),

                // Sign up statement
                const Text(
                  "Sign up",
                  style: TextStyle(
                    fontFamily: "Poppins",
                    fontSize: 24,
                    height: 0.75,
                    fontWeight: FontWeight.w600,
                    color: primaryColor,
                  ),
                ),

                const Spacer(flex: 1),

                const Text(
                  "Please fill the credentials",
                  style: TextStyle(
                    fontFamily: "Poppins",
                    fontSize: 16,
                    height: 1.5,
                    fontWeight: FontWeight.w400,
                    letterSpacing: -0.015,
                    color: color666666,
                  ),
                ),

                const Spacer(flex: 3),

                // Email text box
                const Text(
                  "First name",
                  style: TextStyle(
                    fontFamily: "Poppins",
                    fontSize: 14,
                    height: 1.5,
                    fontWeight: FontWeight.w400,
                    color: color808080,
                  ),
                ),
                TextFieldInput(
                  textEditingController: _firstNameController,
                  hintText: "Enter your First name",
                  textInputType: TextInputType.text,
                ),

                const Spacer(flex: 1),

                // Email text box
                const Text(
                  "Last name",
                  style: TextStyle(
                    fontFamily: "Poppins",
                    fontSize: 14,
                    height: 1.5,
                    fontWeight: FontWeight.w400,
                    color: color808080,
                  ),
                ),
                TextFieldInput(
                  textEditingController: _lastNameController,
                  hintText: "Enter your Last name",
                  textInputType: TextInputType.text,
                ),

                const Spacer(flex: 1),

                // Email text box
                const Text(
                  "Email",
                  style: TextStyle(
                    fontFamily: "Poppins",
                    fontSize: 14,
                    height: 1.5,
                    fontWeight: FontWeight.w400,
                    color: color808080,
                  ),
                ),
                TextFieldInput(
                  textEditingController: _emailController,
                  hintText: "Enter your Email",
                  textInputType: TextInputType.emailAddress,
                ),

                const Spacer(flex: 1),

                // Password text box
                const Text(
                  "Password",
                  style: TextStyle(
                    fontFamily: "Poppins",
                    fontSize: 14,
                    height: 1.5,
                    fontWeight: FontWeight.w400,
                    color: color808080,
                  ),
                ),
                // text field input for password
                TextFieldInput(
                  textEditingController: _passwordController,
                  hintText: "Enter your Password",
                  textInputType: TextInputType.text,
                  isPassword: true,
                ),

                const Spacer(flex: 1),

                const Text(
                  "Confirm Password",
                  style: TextStyle(
                    fontFamily: "Poppins",
                    fontSize: 14,
                    height: 1.5,
                    fontWeight: FontWeight.w400,
                    color: color808080,
                  ),
                ),
                // text field input for password
                TextFieldInput(
                  textEditingController: _confirmPasswordController,
                  hintText: "Re-enter your Password",
                  textInputType: TextInputType.text,
                  isPassword: true,
                ),

                const Spacer(flex: 1),

                Wrap(
                  alignment: WrapAlignment.start,
                  crossAxisAlignment: WrapCrossAlignment.start,
                  children: const [
                    Text(
                      "By clicking ",
                      style: TextStyle(
                        fontFamily: "Poppins",
                        fontSize: 12,
                        height: 1.5,
                        fontWeight: FontWeight.w400,
                        color: color808080,
                      ),
                    ),
                    Text(
                      "Sign up",
                      style: TextStyle(
                        fontFamily: "Poppins",
                        fontSize: 12,
                        height: 1.5,
                        fontWeight: FontWeight.w600,
                        color: color808080,
                      ),
                    ),
                    Text(
                      " you agree to the ",
                      style: TextStyle(
                        fontFamily: "Poppins",
                        fontSize: 12,
                        height: 1.5,
                        fontWeight: FontWeight.w400,
                        color: color808080,
                      ),
                    ),
                    Text(
                      "Terms of Service",
                      style: TextStyle(
                        fontFamily: "Poppins",
                        fontSize: 12,
                        height: 1.5,
                        fontWeight: FontWeight.w500,
                        decoration: TextDecoration.underline,
                        color: color808080,
                      ),
                    ),
                    Text(
                      " and ",
                      style: TextStyle(
                        fontFamily: "Poppins",
                        fontSize: 12,
                        height: 1.5,
                        fontWeight: FontWeight.w400,
                        color: color808080,
                      ),
                    ),
                    Text(
                      "Privacy policy",
                      style: TextStyle(
                        fontFamily: "Poppins",
                        fontSize: 12,
                        height: 1.5,
                        fontWeight: FontWeight.w500,
                        decoration: TextDecoration.underline,
                        color: color808080,
                      ),
                    ),
                  ],
                ),

                const Spacer(flex: 2),

                // button to sign up
                InkWell(
                  onTap: () {
                    List<String> message;
                    message = nullCheck();
                    if (message.isEmpty) {
                      // send OTP to user's email and open OTP screen
                      Future<bool> otpSent = sendOTP();
                      otpSent.then((value) {
                        if (!value) {
                          setState(
                            () {
                              otpStatus = "OTP Sending failed";
                            },
                          );
                          showSnackBar(otpStatus, context);
                          setState(
                            () {
                              _isLoading = false;
                            },
                          );
                        } else {
                          setState(
                            () {
                              otpStatus = "OTP Sent successfully";
                            },
                          );
                          showSnackBar(otpStatus, context);
                          final CrystullUser _signupForm = CrystullUser(
                            _firstNameController.text,
                            _lastNameController.text,
                            _emailController.text,
                            _passwordController.text,
                          );
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => EmailOTPScreen(
                                signupForm: _signupForm,
                                emailAuth: _emailAuth,
                              ),
                            ),
                          );
                          setState(
                            () {
                              _isLoading = false;
                            },
                          );
                        }
                      }).catchError(
                        (e) {
                          showSnackBar(e.toString(), context);
                          setState(
                            () {
                              _isLoading = false;
                            },
                          );
                        },
                      );
                    } else {
                      for (String s in message) {
                        showSnackBar(s, context);
                      }
                    }
                  },
                  child: Container(
                    child: _isLoading
                        ? const Center(
                            child: CircularProgressIndicator(
                              color: mobileBackgroundColor,
                            ),
                          )
                        : const Text(
                            "Next",
                            style: TextStyle(
                              fontFamily: "Poppins",
                              fontSize: 20,
                              height: 1.2,
                              color: mobileBackgroundColor,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                    width: double.infinity,
                    alignment: Alignment.center,
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    decoration: BoxDecoration(
                      border: Border.all(color: primaryColor, width: 2),
                      color: primaryColor,
                    ),
                  ),
                ),

                const SizedBox(height: 16),

                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    const Text(
                      "Already have an account? ",
                      style: TextStyle(
                        fontFamily: "Poppins",
                        fontSize: 12,
                        height: 1.5,
                        fontWeight: FontWeight.w400,
                        color: color747474,
                      ),
                    ),
                    GestureDetector(
                      onTap: () {
                        Navigator.pushReplacement(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const LoginScreen(),
                          ),
                        );
                      },
                      child: const Text(
                        "Log in",
                        style: TextStyle(
                          fontFamily: "Poppins",
                          fontSize: 12,
                          height: 1.5,
                          fontWeight: FontWeight.w600,
                          color: primaryColor,
                        ),
                      ),
                    ),
                  ],
                ),

                const Spacer(flex: 1),

                Container(
                    alignment: Alignment.center,
                    child: const Text(
                      "or",
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontFamily: "Poppins",
                        fontSize: 16,
                        height: 1.5,
                        fontWeight: FontWeight.w400,
                        color: color666666,
                      ),
                    )),

                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    GestureDetector(
                      onTap: () {
                        setState(() {
                          _isLoading = true;
                        });
                        Future<String> result = AuthMethods().loginWithGoogle();
                        handleSignupResult(result);
                      },
                      child: Container(
                        height: 36,
                        width: 36,
                        padding: const EdgeInsets.all(8),
                        decoration: const BoxDecoration(
                          color: googleLogoColor,
                          shape: BoxShape.circle,
                        ),
                        child: SvgPicture.asset(
                          'images/google_logo.svg',
                          color: mobileBackgroundColor,
                          height: 18,
                          width: 18,
                        ),
                      ),
                    ),
                    const SizedBox(
                      width: 40,
                    ),
                    GestureDetector(
                      onTap: () {
                        setState(() {
                          _isLoading = true;
                        });
                        Future<String> result =
                            AuthMethods().loginWithFacebook();
                        handleSignupResult(result);
                      },
                      child: Container(
                        height: 36,
                        width: 36,
                        padding: const EdgeInsets.all(8),
                        decoration: const BoxDecoration(
                          color: fbLogoColor,
                          shape: BoxShape.circle,
                        ),
                        child: SvgPicture.asset(
                          'images/fb_logo.svg',
                          color: mobileBackgroundColor,
                          height: 18,
                          width: 9,
                        ),
                      ),
                    ),
                  ],
                ),
                const Spacer()
              ],
            ),
          ),
        ),
      ),
    );
  }
}
