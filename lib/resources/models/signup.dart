import 'dart:typed_data';

import 'package:cloud_firestore/cloud_firestore.dart';

class SwapData {
  double value;

  SwapData({
    required this.value,
  });

  Map<String, dynamic> toJson() => {
        'value': value,
      };
}

class Swap {
  String fromUid;
  DateTime addedAt;
  Map<String, SwapData> swaps;

  Swap({
    required this.fromUid,
    required this.addedAt,
    required this.swaps,
  });
}

class Friend {
  String id;
  int status;

  Friend({required this.id, required this.status});

  static Friend fromMap(Map<String, dynamic> map) {
    return Friend(
      id: map['id'],
      status: map['status'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'status': status,
    };
  }
}

class CrystullUser {
  late String fullName;
  String firstName;
  String lastName;
  String email;
  String uid;
  String password;
  String bio;
  bool isPrivate;
  String college;
  String degree;
  String mobileNumberWithCountryCode;
  String profileImageUrl;
  Uint8List? profileImage;
  Map<String, Friend> connections;
  List posts;
  CrystullUser(
    this.firstName,
    this.lastName,
    this.email,
    this.password, {
    this.uid = "",
    this.bio = "",
    this.isPrivate = false,
    this.college = "",
    this.degree = "",
    this.mobileNumberWithCountryCode = "",
    this.profileImage,
    this.profileImageUrl = "",
    this.connections = const <String, Friend>{},
    this.posts = const [],
  });

  Map<String, dynamic> toMap() {
    Map<String, dynamic> updateConnections =
        Map<String, dynamic>.from(connections)
            .map((key, value) => MapEntry(key, value.toMap()));
    return {
      "fullName": (firstName + " " + lastName).toLowerCase(),
      'firstName': firstName,
      'lastName': lastName,
      'email': email,
      "uid": uid,
      'bio': bio,
      "isPrivate": isPrivate,
      'college': college,
      'degree': degree,
      'mobileNumberWithCountryCode': mobileNumberWithCountryCode,
      'profileImage': profileImage,
      'profileImageUrl': profileImageUrl,
      'connections': updateConnections,
      'posts': posts,
    };
  }

  static CrystullUser fromMap(Map<String, dynamic> map) {
    final connections = Map<String, Friend>.from(map['connections']
        ?.map((key, value) => MapEntry(key, Friend.fromMap(value))));
    var user = CrystullUser(
      map['firstName'] ?? "",
      map['lastName'] ?? "",
      map['email'] ?? "",
      "",
      isPrivate: map['isPrivate'] ?? false,
      uid: map['uid'] ?? "",
      bio: map['bio'] ?? "",
      college: map['college'] ?? "",
      degree: map['degree'] ?? "",
      mobileNumberWithCountryCode: map['mobileNumberWithCountryCode'] ?? "",
      profileImageUrl: map['profileImageUrl'] ?? "",
      connections: connections,
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
