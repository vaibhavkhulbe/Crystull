import 'dart:developer';

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
      _user = user;
    } else {
      log("No user found");
    }
    notifyListeners();
  }
}
