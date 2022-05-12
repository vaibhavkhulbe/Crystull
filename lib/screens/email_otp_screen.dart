import 'dart:developer';

import 'package:crystull/utils/utils.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:crystull/widgets/text_field_widget.dart';
import 'package:email_auth/email_auth.dart';
import 'package:crystull/resources/models/signup.dart';
import 'package:crystull/screens/signup_more_info.dart';

class EmailOTPScreen extends StatefulWidget {
  final CrystullUser signupForm;
  final EmailAuth emailAuth;
  final bool isLoginWithOTP;
  const EmailOTPScreen(
      {Key? key,
      required this.signupForm,
      required this.emailAuth,
      this.isLoginWithOTP = false})
      : super(key: key);

  @override
  State<EmailOTPScreen> createState() => _EmailOTPScreenState();
}

class _EmailOTPScreenState extends State<EmailOTPScreen> {
  // final SignupForm signupForm;
  // final EmailAuth emailAuth;
  final TextEditingController _otpController = TextEditingController();
  var _isLoading = false;

  Future<bool> validateOTP(EmailAuth _emailAuth, String email) async {
    setState(() {
      _isLoading = true;
    });
    // validate OTP
    var res = _emailAuth.validateOtp(
      recipientMail: email,
      userOtp: _otpController.value.text,
    );
    return res;
  }

  Future<bool> resendOTP(EmailAuth _emailAuth, String email) async {
    // send OTP to user's email
    setState(() {
      _isLoading = true;
    });
    var res = await _emailAuth.sendOtp(
      recipientMail: email,
      otpLength: 6,
    );
    return res;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(),
        body: SingleChildScrollView(
          child: SafeArea(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              width: double.infinity,
              height: getSafeAreaHeight(context),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Flexible(child: Container(), flex: 2),
                  // Add logo
                  SvgPicture.asset('images/otp_verification.svg'),

                  Flexible(child: Container(), flex: 2),
                  // Sign up statement
                  const Text(
                    "OTP verification",
                    style: TextStyle(
                      fontSize: 30,
                      fontWeight: FontWeight.bold,
                      color: Colors.lightBlueAccent,
                    ),
                  ),

                  Flexible(child: Container(), flex: 1),

                  Wrap(
                    alignment: WrapAlignment.center,
                    crossAxisAlignment: WrapCrossAlignment.center,
                    children: [
                      Text(
                        "Enter the OTP sent to " + widget.signupForm.email,
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          fontSize: 14,
                          color: Colors.black54,
                        ),
                      ),
                    ],
                  ),

                  Flexible(child: Container(), flex: 1),

                  TextFieldInput(
                    textEditingController: _otpController,
                    hintText: "Enter OTP",
                    textInputType: TextInputType.text,
                  ),

                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      const Text(
                        "Haven't received it yet? ",
                        style: TextStyle(color: Colors.black54),
                      ),
                      InkWell(
                        onTap: () {
                          Future<bool> otpStatus = resendOTP(
                              widget.emailAuth, widget.signupForm.email);
                          otpStatus.then((value) {
                            if (!value) {
                              // show error
                              showSnackBar("Failed to send OTP", context);
                            } else {
                              // show OTP screen
                              showSnackBar("OTP resent successfully", context);
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => MoreInfoScreen(
                                    signupForm: widget.signupForm,
                                    emailAuth: widget.emailAuth,
                                  ),
                                ),
                              );
                            }
                          }).catchError((e) {
                            showSnackBar(e.toString(), context);
                          });
                          setState(() {
                            _isLoading = false;
                          });
                        },
                        child: const Text("Resend",
                            style: TextStyle(
                              color: Colors.lightBlueAccent,
                              fontWeight: FontWeight.bold,
                            )),
                      )
                    ],
                  ),

                  Flexible(child: Container(), flex: 2),

                  // button to sign up
                  InkWell(
                    onTap: () {
                      // send OTP to user's email and open OTP screen
                      Future<bool> otpStatus = validateOTP(
                          widget.emailAuth, widget.signupForm.email);
                      otpStatus.then((value) {
                        if (!value) {
                          setState(() {
                            _isLoading = false;
                          });
                          // show error
                          showSnackBar("Invalid OTP", context);
                        } else {
                          setState(() {
                            _isLoading = false;
                          });
                          // show OTP screen
                          showSnackBar("OTP validated successfully", context);
                          widget.isLoginWithOTP
                              ?
                              // login()
                              log("logged in")
                              : Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => MoreInfoScreen(
                                      signupForm: widget.signupForm,
                                      emailAuth: widget.emailAuth,
                                    ),
                                  ),
                                );
                        }
                      }).catchError((e) {
                        log(e);
                      });
                    },
                    child: Container(
                      child: _isLoading
                          ? const Center(
                              child: CircularProgressIndicator(
                                  color: Colors.white),
                            )
                          : Text(widget.isLoginWithOTP ? "Login" : "Submit",
                              style: const TextStyle(
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

                  Flexible(child: Container(), flex: 4),
                ],
              ),
            ),
          ),
        ));
  }
}
