import 'package:crystull/resources/auth_methods.dart';
import 'package:crystull/resources/models/signup.dart';
import 'package:crystull/responsive/mobile_screen_layout.dart';
import 'package:crystull/responsive/response_layout_screen.dart';
import 'package:crystull/responsive/web_screen_layout.dart';
import 'package:crystull/screens/home_screen.dart';
import 'package:crystull/screens/login_with_otp_screen.dart';
import 'package:crystull/screens/signup_screen.dart';
import 'package:crystull/utils/utils.dart';
import 'package:crystull/widgets/text_field_widget.dart';
import 'package:email_auth/email_auth.dart';
import 'package:flutter/material.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({Key? key}) : super(key: key);

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
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
      body: SingleChildScrollView(
        child: SafeArea(
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 32),
            width: double.infinity,
            height: getSafeAreaHeight(context),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Flexible(child: Container(), flex: 2),
                // Add logo
                // SvgPicture.asset('images/crystull_logo.svg', height: 64),

                // Login statement
                const Text(
                  "Log in",
                  style: TextStyle(
                    fontSize: 30,
                    fontWeight: FontWeight.bold,
                    color: Colors.lightBlueAccent,
                  ),
                ),

                Flexible(child: Container(), flex: 1),

                const Text(
                  "Enter your email to continue",
                  style: TextStyle(
                    fontSize: 18,
                    color: Colors.black87,
                  ),
                ),

                Flexible(child: Container(), flex: 3),

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

                Flexible(child: Container(), flex: 1),

                const Text(
                  "Password",
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.black54,
                  ),
                ),
                // text field input for password
                TextFieldInput(
                  textEditingController: _passwordController,
                  hintText: "Enter your Password",
                  textInputType: TextInputType.text,
                  isPassword: true,
                ),

                Flexible(child: Container(), flex: 1),

                // button to login with OTP
                InkWell(
                  onTap: () {
                    // send OTP to user's email and open OTP screen
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const LoginWithOTPScreen(),
                      ),
                    );
                  },
                  child: Container(
                    child: const Text("Login with OTP",
                        style: TextStyle(
                          color: Colors.lightBlueAccent,
                          fontSize: 18,
                        )),
                    width: double.infinity,
                    alignment: Alignment.center,
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    decoration: BoxDecoration(
                      border:
                          Border.all(color: Colors.lightBlueAccent, width: 2),
                      color: Colors.white,
                    ),
                  ),
                ),

                Flexible(child: Container(), flex: 1),

                // button to login
                InkWell(
                  onTap: () {
                    // send OTP to user's email and open OTP screen
                    CrystullUser form = CrystullUser(
                      "", // empty string for firstname
                      "", // empty string for lastname
                      _emailController.value.text,
                      _passwordController.value.text,
                    );
                    setState(() {
                      _isLoading = true;
                    });
                    Future<String> result =
                        AuthMethods().loginUser(signupForm: form);
                    result.then((value) {
                      if (value != "Success") {
                        showSnackBar(
                            "User login failed with error: " + value, context);

                        setState(() {
                          _isLoading = false;
                        });
                        // Navigator.pushReplacement(context,
                        //     MaterialPageRoute(builder: (context) {
                        //   return const SignupScreen();
                        // }));
                      } else {
                        showSnackBar("User logged in successfully.", context);
                        Navigator.pushReplacement(context,
                            MaterialPageRoute(builder: (context) {
                              
                          return const ResponsiveLayout(
                              webScreenLayout: WebScreenLayout(),
                              mobileScreenLayout: MobileScreenLayout());
                        }));

                        setState(() {
                          _isLoading = false;
                        });
                      }
                    }).catchError((onError) {
                      showSnackBar(
                          "User login failed with error: " + onError.toString(),
                          context);

                      setState(() {
                        _isLoading = false;
                      });
                      // Navigator.pushReplacement(context,
                      //     MaterialPageRoute(builder: (context) {
                      //   return const ResponsiveLayout(
                      //       webScreenLayout: WebScreenLayout(),
                      //       mobileScreenLayout: MobileScreenLayout());
                      // }));
                    });
                  },
                  child: Container(
                    child: _isLoading
                        ? const CircularProgressIndicator(
                            color: Colors.white,
                          )
                        : const Text("Login",
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            )),
                    width: double.infinity,
                    alignment: Alignment.center,
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    decoration: BoxDecoration(
                      border:
                          Border.all(color: Colors.lightBlueAccent, width: 2),
                      color: Colors.lightBlueAccent,
                    ),
                  ),
                ),

                Flexible(child: Container(), flex: 1),

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
                            color: Colors.lightBlueAccent,
                          )),
                    ),
                  ],
                ),

                Flexible(child: Container(), flex: 1),

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
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Flexible(child: Container(), flex: 1),
                    const Icon(
                      Icons.facebook_rounded,
                      color: Colors.red,
                    ),
                    Flexible(child: Container(), flex: 1),
                    const Icon(
                      Icons.facebook_rounded,
                      color: Colors.blue,
                    ),
                    Flexible(child: Container(), flex: 1)
                  ],
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
