import 'package:crystull/resources/auth_methods.dart';
import 'package:crystull/resources/models/signup.dart';
import 'package:crystull/responsive/mobile_screen_layout.dart';
import 'package:crystull/responsive/response_layout_screen.dart';
import 'package:crystull/responsive/web_screen_layout.dart';
import 'package:crystull/screens/email_otp_screen.dart';
import 'package:crystull/screens/signup_screen.dart';
import 'package:crystull/utils/colors.dart';
import 'package:crystull/utils/utils.dart';
import 'package:crystull/widgets/text_field_widget.dart';
import 'package:email_auth/email_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

class LoginWithOTPScreen extends StatefulWidget {
  const LoginWithOTPScreen({Key? key}) : super(key: key);

  @override
  State<LoginWithOTPScreen> createState() => _LoginWithOTPScreenState();
}

class _LoginWithOTPScreenState extends State<LoginWithOTPScreen> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final EmailAuth _emailAuth = EmailAuth(sessionName: "Crystull Login");
  bool _isLoading = false;
  String otpStatus = "";

  @override
  void dispose() {
    super.dispose();
    _emailController.dispose();
    _passwordController.dispose();
  }

  void handleLoginResult(Future<String> result) {
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
      _isLoading = true;
      otpStatus = "Sending OTP...";
    });
    showSnackBar(otpStatus, context);
    // send OTP to user's email
    var res = await _emailAuth.sendOtp(
      recipientMail: _emailController.value.text,
      otpLength: 6,
    );
    return res;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        elevation: 1,
      ),
      body: SafeArea(
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 32),
          width: double.infinity,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Spacer(flex: 2),
              // Add logo
              // SvgPicture.asset('images/crystull_logo.svg', height: 64),

              // Login statement
              const Text(
                "Log in",
                style: TextStyle(
                  fontSize: 30,
                  fontWeight: FontWeight.bold,
                  color: primaryColor,
                ),
              ),

              const Spacer(flex: 1),

              const Text(
                "Enter your email to continue",
                style: TextStyle(
                  fontSize: 18,
                  color: Colors.black87,
                ),
              ),

              const Spacer(flex: 3),

              const Text(
                "Email",
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.black54,
                ),
              ),

              // text field input for email
              TextFieldInput(
                textEditingController: _emailController,
                hintText: "Enter your Email",
                textInputType: TextInputType.emailAddress,
              ),

              const Spacer(flex: 1),

              // button to login
              InkWell(
                onTap: () {
                  // send OTP to user's email and open OTP screen
                  CrystullUser signupForm =
                      CrystullUser("", "", _emailController.text, "");
                  Future<bool> otpSent = sendOTP();
                  otpSent.then((value) {
                    if (!value) {
                      setState(() {
                        _isLoading = false;
                        otpStatus = "OTP Sending failed";
                      });
                      showSnackBar(otpStatus, context);
                    } else {
                      setState(() {
                        _isLoading = false;
                        otpStatus = "OTP Sent successfully";
                      });
                      showSnackBar(otpStatus, context);
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => EmailOTPScreen(
                            signupForm: signupForm,
                            emailAuth: _emailAuth,
                            isLoginWithOTP: true,
                          ),
                        ),
                      );
                    }
                  });
                },
                child: Container(
                  child: _isLoading
                      ? const CircularProgressIndicator(
                          color: mobileBackgroundColor)
                      : const Text("Next",
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

              const Spacer(flex: 1),

              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  const Text("Don't have an account? ",
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.black54,
                      )),
                  GestureDetector(
                    onTap: () {
                      Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const SignupScreen(),
                          ));
                    },
                    child: const Text("Sign up",
                        style: TextStyle(
                          fontSize: 14,
                          color: primaryColor,
                        )),
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
                      fontSize: 18,
                      color: Colors.black,
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
                      handleLoginResult(result);
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
                      Future<String> result = AuthMethods().loginWithFacebook();
                      handleLoginResult(result);
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
              )
            ],
          ),
        ),
      ),
    );
  }
}
