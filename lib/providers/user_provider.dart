import 'dart:developer';
import 'dart:typed_data';

import 'package:crystull/resources/auth_methods.dart';
import 'package:crystull/resources/models/signup.dart';
import 'package:flutter/material.dart';

class UserProvider extends ChangeNotifier {
  CrystullUser? _user;
  final AuthMethods _authMethods = AuthMethods();

  CrystullUser? get getUser => _user;

  Future<void> refreshUser() async {
    log("Refreshing user");
    CrystullUser? user = await _authMethods.getUserDetails();
    if (user != null) {
      Uint8List? image = await _authMethods.getUserImage();
      if (image != null) {
        user.profileImage = image;
      } else {
        log("No image found");
        user.profileImage = null;
      }
    } else {
      log("No user found");
    }
    _user = user;
    notifyListeners();
  }
}
