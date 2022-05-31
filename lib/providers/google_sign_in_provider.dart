import 'dart:developer';
import 'dart:typed_data';

import 'package:crystull/resources/auth_methods.dart';
import 'package:crystull/resources/models/signup.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';

class GoogleSignInProvider extends ChangeNotifier {
  CrystullUser? _user;
  GoogleSignInAccount? _googleUser;
  final GoogleSignIn googleSignIn = GoogleSignIn();

  CrystullUser? get getUser => _user;

  Future googleLogin() async {
    final googleUser = await googleSignIn.signIn();
    if (googleUser == null) return;
    _googleUser = googleUser;
    final googleAuth = await googleUser.authentication;
    final credetials = GoogleAuthProvider.credential(
      accessToken: googleAuth.accessToken,
      idToken: googleAuth.idToken,
    );
    await FirebaseAuth.instance.signInWithCredential(credetials);
    notifyListeners();
  }

  // Future<void> refreshUser() async {
  //   log("Refreshing user");
  //   CrystullUser? user = await _authMethods.getUserDetails();
  //   if (user != null) {
  //     Uint8List? image = await _authMethods.getUserImage();
  //     if (image != null) {
  //       user.profileImage = image;
  //     } else {
  //       log("No image found");
  //       user.profileImage = null;
  //     }
  //   } else {
  //     log("No user found");
  //   }
  //   _user = user;
  //   notifyListeners();
  // }
}
