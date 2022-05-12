import 'dart:typed_data';

import 'package:cloud_firestore/cloud_firestore.dart';

class Friend {
  String id;
  Enum status;

  Friend({required this.id, required this.status});

  static Friend fromMap(Map<String, dynamic> map) {
    return Friend(
      id: map['id'],
      status: map['status'],
    );
  }
}

class CrystullUser {
  late String fullName;
  String firstName;
  String lastName;
  String email;
  String password;
  String bio;
  String college;
  String company;
  String mobileNumberWithCountryCode;
  String profileImageUrl;
  Uint8List? profileImage;
  List<Friend> connections;
  List posts;
  CrystullUser(
    this.firstName,
    this.lastName,
    this.email,
    this.password, {
    this.bio = "",
    this.college = "",
    this.company = "",
    this.mobileNumberWithCountryCode = "",
    this.profileImage,
    this.profileImageUrl = "",
    this.connections = const <Friend>[],
    this.posts = const [],
  });

  Map<String, dynamic> toMap() {
    return {
      "fullName": firstName + " " + lastName,
      'firstName': firstName,
      'lastName': lastName,
      'email': email,
      'bio': bio,
      'college': college,
      'company': company,
      'mobileNumberWithCountryCode': mobileNumberWithCountryCode,
      'profileImage': profileImage,
      'profileImageUrl': profileImageUrl,
      'connections': connections,
      'posts': posts,
    };
  }

  static CrystullUser fromMap(Map<String, dynamic> map) {
    final connections = map['connections']
        .map<Friend>((friend) => Friend.fromMap(friend))
        .toList();
    var user = CrystullUser(
      map['firstName'] ?? "",
      map['lastName'] ?? "",
      map['email'] ?? "",
      "",
      bio: map['bio'] ?? "",
      college: map['college'] ?? "",
      company: map['company'] ?? "",
      mobileNumberWithCountryCode: map['mobileNumberWithCountryCode'] ?? "",
      profileImageUrl: map['profileImageUrl'] ?? "",
      connections: connections ?? const <Friend>[],
      posts: map['posts'] ?? const [],
    );
    user.fullName = map['fullName'];
    return user;
  }

  static CrystullUser fromSnapshot(DocumentSnapshot snapshot) {
    var snapShotData = snapshot.data() as Map<String, dynamic>;
    return CrystullUser.fromMap(snapShotData);
  }
}
