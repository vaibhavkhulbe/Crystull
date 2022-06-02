import 'dart:typed_data';

import 'package:cloud_firestore/cloud_firestore.dart';

class SwapInfo {
  DateTime lastSwappedAt;
  String lastSwappedID;

  SwapInfo({required this.lastSwappedAt, required this.lastSwappedID});
}

class SwapAttributes {
  Map<String, double> attributes;
  Map<String, SwapInfo> swapInfo;

  SwapAttributes({required this.attributes, required this.swapInfo});
}

class SwapData {
  Map<String, double> value;

  SwapData({
    required this.value,
  });

  Map<String, dynamic> toJson() {
    return value;
  }
}

class Swap {
  String id;
  String fromUid;
  String fromName;
  String toUid;
  String toName;
  DateTime addedAt;
  bool anonymous;
  bool unread;
  Map<String, double> swaps;
  List<String> swapList;

  Swap({
    required this.id,
    required this.fromUid,
    required this.fromName,
    required this.toUid,
    required this.toName,
    required this.addedAt,
    required this.anonymous,
    required this.unread,
    required this.swaps,
    required this.swapList,
  });

  Map<String, dynamic> toJson() => {
        'id': id,
        'fromUid': fromUid,
        'fromName': fromName,
        'toUid': toUid,
        'toName': toName,
        'addedAt': addedAt,
        'unread': unread,
        'anonymous': anonymous,
        'swaps': swaps,
        'swapList': swapList,
      };
  static Swap fromJson(Map<String, dynamic> swap) {
    Map<String, double> _swaps = {};
    List<String> _swapList = [];
    swap['swaps'].forEach((key, value) {
      _swaps[key] = value as double;
    });
    var _addedAtTs = swap['addedAt'] as Timestamp;
    var _addedAt = _addedAtTs.toDate();
    swap['swapList'].forEach((key) {
      _swapList.add(key);
    });
    return Swap(
      id: swap['id'] as String,
      fromUid: swap["fromUid"] as String,
      fromName: swap["fromName"] as String,
      toUid: swap["toUid"] as String,
      toName: swap["toName"] as String,
      addedAt: _addedAt,
      anonymous: swap["anonymous"] as bool,
      swaps: _swaps,
      unread: swap["unread"] != null ? swap["unread"] as bool : false,
      swapList: _swapList,
    );
  }
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
  String coverImageUrl;
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
    this.isPrivate = true,
    this.college = "",
    this.degree = "",
    this.mobileNumberWithCountryCode = "",
    this.profileImage,
    this.profileImageUrl = "",
    this.coverImageUrl = "",
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
      coverImageUrl: map['coverImageUrl'] ?? "",
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
