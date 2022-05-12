import 'package:crystull/resources/models/signup.dart';
import 'package:flutter/material.dart';

class ProfileScreen extends StatefulWidget {
  CrystullUser user;
  ProfileScreen({Key? key, required this.user}) : super(key: key);

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  @override
  Widget build(BuildContext context) {
    return Text("Profile", style: TextStyle(color: Colors.black));
  }
}
