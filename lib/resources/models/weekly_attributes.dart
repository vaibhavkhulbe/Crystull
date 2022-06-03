import 'package:crystull/resources/models/signup.dart';
import 'package:flutter/material.dart';

class WeeklyAttributes {
  Map<String, Map<String, dynamic>> attributes;
  Map<String, CrystullUser> users;

  WeeklyAttributes({required this.attributes, required this.users});
}
