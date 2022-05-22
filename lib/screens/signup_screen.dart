import 'package:crystull/screens/login_screen.dart';
import 'package:crystull/utils/utils.dart';
import 'package:flutter/material.dart';
import 'package:crystull/widgets/text_field_widget.dart';
import 'package:email_auth/email_auth.dart';
import 'package:crystull/resources/models/signup.dart';
import 'package:crystull/screens/email_otp_screen.dart';

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
                Flexible(child: Container(), flex: 3),
                // Add logo
                // SvgPicture.asset('images/crystull_logo.svg', height: 64),

                // Sign up statement
                const Text(
                  "Sign up",
                  style: TextStyle(
                    fontSize: 30,
                    fontWeight: FontWeight.bold,
                    color: Colors.lightBlueAccent,
                  ),
                ),

                Flexible(child: Container(), flex: 1),

                const Text(
                  "Please fill the credentials",
                  style: TextStyle(
                    fontSize: 18,
                    color: Colors.black87,
                  ),
                ),

                Flexible(child: Container(), flex: 3),

                // Email text box
                const Text(
                  "First name",
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.black54,
                  ),
                ),
                TextFieldInput(
                  textEditingController: _firstNameController,
                  hintText: "Enter your First name",
                  textInputType: TextInputType.text,
                ),

                Flexible(child: Container(), flex: 2),

                // Email text box
                const Text(
                  "Last name",
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.black54,
                  ),
                ),
                TextFieldInput(
                  textEditingController: _lastNameController,
                  hintText: "Enter your last name",
                  textInputType: TextInputType.text,
                ),

                Flexible(child: Container(), flex: 2),

                // Email text box
                const Text(
                  "Email",
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.black54,
                  ),
                ),
                TextFieldInput(
                  textEditingController: _emailController,
                  hintText: "Enter your Email",
                  textInputType: TextInputType.emailAddress,
                ),

                Flexible(child: Container(), flex: 2),

                // Password text box
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

                Flexible(child: Container(), flex: 2),

                const Text(
                  "Confirm Password",
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.black54,
                  ),
                ),
                // text field input for password
                TextFieldInput(
                  textEditingController: _confirmPasswordController,
                  hintText: "Re-enter your Password",
                  textInputType: TextInputType.text,
                  isPassword: true,
                ),

                Flexible(child: Container(), flex: 2),

                Wrap(
                  alignment: WrapAlignment.start,
                  crossAxisAlignment: WrapCrossAlignment.start,
                  children: const [
                    Text("By clicking ",
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.black54,
                        )),
                    Text("Sign up",
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 12,
                          color: Colors.black54,
                        )),
                    Text(" you agree to the ",
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.black54,
                        )),
                    Text("Terms of Service",
                        style: TextStyle(
                          fontSize: 12,
                          decoration: TextDecoration.underline,
                          color: Colors.black,
                        )),
                    Text(" and ",
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.black54,
                        )),
                    Text("Privacy policy",
                        style: TextStyle(
                          fontSize: 12,
                          decoration: TextDecoration.underline,
                          color: Colors.black,
                        )),
                  ],
                ),

                Flexible(child: Container(), flex: 1),

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
                            child:
                                CircularProgressIndicator(color: Colors.white),
                          )
                        : const Text("Next",
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

                const SizedBox(height: 16),

                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    const Text("Already have an account? ",
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.black54,
                        )),
                    GestureDetector(
                      onTap: () {
                        Navigator.pushReplacement(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const LoginScreen(),
                          ),
                        );
                      },
                      child: const Text("Log in",
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
                    Flexible(child: Container(), flex: 1),
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
