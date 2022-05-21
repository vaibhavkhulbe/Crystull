import 'dart:developer';
import 'dart:typed_data';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:crystull/resources/models/signup.dart';
import 'package:crystull/resources/storage_methods.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:uuid/uuid.dart';

class AuthMethods {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<CrystullUser?> getUserDetails() async {
    User user = _auth.currentUser!;
    DocumentSnapshot doc =
        await _firestore.collection('users').doc(user.uid).get();
    if (doc.exists) {
      return CrystullUser.fromSnapshot(doc);
    } else {
      return null;
    }
  }

  Future<Uint8List?> getUserImage() async {
    Uint8List? image = await StorageMethods().downloadImage("profilePics");
    return image;
  }

  Future<String> signUpUser({
    required CrystullUser signupForm,
  }) async {
    String res = "Some error occurred";
    try {
      if (signupForm.email.isNotEmpty ||
          signupForm.password.isNotEmpty ||
          signupForm.firstName.isNotEmpty ||
          signupForm.lastName.isNotEmpty ||
          signupForm.profileImage != null) {
        // register the user
        UserCredential credValue = await _auth.createUserWithEmailAndPassword(
            email: signupForm.email, password: signupForm.password);

        if (credValue.user != null) {
          log("User created successfully " + credValue.user!.uid);

          String photoUrl = await StorageMethods()
              .uploadImage("profilePics", signupForm.profileImage!, false);

          if (photoUrl.isNotEmpty) {
            log("Photo uploaded " + photoUrl);
            signupForm.profileImage = null;
            signupForm.profileImageUrl = photoUrl;
            await _firestore
                .collection('users')
                .doc(credValue.user!.uid)
                .set(signupForm.toMap());
            res = "Success";
          } else {
            log("Photo upload failed " + photoUrl + "Deleting user");
            credValue.user!.delete();
          }
        } else {
          log("User creation failed");
        }
      }
    } catch (e) {
      res = e.toString();
      log(res);
    }
    return res;
  }

  Future<String> loginUser({
    required CrystullUser signupForm,
  }) async {
    String res = "Some error occured";
    try {
      if (signupForm.email.isNotEmpty || signupForm.password.isNotEmpty) {
        // register the user
        UserCredential cred = await _auth.signInWithEmailAndPassword(
            email: signupForm.email, password: signupForm.password);

        log("User logged in successfully " + cred.user!.uid);
        res = "Success";
      }
    } catch (e) {
      res = e.toString();
      log(res);
    }
    return res;
  }

  Future<String> updateUserPrivacy(CrystullUser user) async {
    String res = "Some error occured";
    try {
      if (user.bio.isNotEmpty) {
        // update the user
        await _firestore.collection('users').doc(user.uid).update({
          'isPrivate': user.isPrivate,
        });
        res = "Success";
      }
    } catch (e) {
      res = e.toString();
      log(res);
    }
    return res;
  }

  Future<String> updateUserPersonalDetails(CrystullUser user) async {
    String res = "Some error occured";
    try {
      if (user.bio.isNotEmpty) {
        // update the user
        await _firestore.collection('users').doc(user.uid).update({
          'bio': user.bio,
          'college': user.college,
          'degree': user.degree,
        });
        res = "Success";
      }
    } catch (e) {
      res = e.toString();
      log(res);
    }
    return res;
  }

  Future<CrystullUser> refreshUser(CrystullUser user) async {
    String res = "Some error occured";
    try {
      if (user.bio.isNotEmpty) {
        // update the user
        await _firestore.collection('users').doc(user.uid).get().then((doc) {
          user = CrystullUser.fromSnapshot(doc);
        });
      }
    } catch (e) {
      res = e.toString();
      log(res);
    }
    return user;
  }

  Future<String> addFriendRequest(CrystullUser currentUser, CrystullUser friend,
      int currentUserStatus, int friendStatus) async {
    String res = "Some error occured";
    try {
      if (currentUser.uid.isNotEmpty && friend.uid.isNotEmpty) {
        var batch = _firestore.batch();
        // update the user
        batch.update(_firestore.collection('users').doc(currentUser.uid), {
          'connections.${friend.uid}': Friend(
            id: friend.uid,
            status: currentUserStatus,
          ).toMap(),
        });

        batch.update(_firestore.collection('users').doc(friend.uid), {
          'connections.${currentUser.uid}': Friend(
            id: currentUser.uid,
            status: friendStatus,
          ).toMap()
        });
        await batch.commit();
        res = "Success";
      }
    } catch (e) {
      res = e.toString();
      log(res);
    }

    return res;
  }

  Future<String> removeFriend(
      CrystullUser currentUser, CrystullUser otherUser) async {
    String res = "Some error occured";
    try {
      if (currentUser.uid.isNotEmpty && otherUser.uid.isNotEmpty) {
        // update the user
        await _firestore.collection('users').doc(currentUser.uid).update({
          'connections.${otherUser.uid}': FieldValue.delete(),
        });

        await _firestore.collection('users').doc(otherUser.uid).update({
          'connections.${currentUser.uid}': FieldValue.delete(),
        });
        res = "Success";
      }
    } catch (e) {
      res = e.toString();
      log(res);
    }
    return res;
  }

  static Future<List<CrystullUser>> getConnections(CrystullUser user,
      {int status = 3}) async {
    FirebaseFirestore _firestore = FirebaseFirestore.instance;
    List<CrystullUser> connections = [];
    try {
      List<String> connectionUsers = [];
      user.connections.forEach((key, value) {
        if (value.status == status) {
          connectionUsers.add(key);
        }
      });
      if (connectionUsers.isNotEmpty) {
        await _firestore
            .collection('users')
            .where('uid', whereIn: connectionUsers)
            .get()
            .then((QuerySnapshot snapshot) async {
          for (var doc in snapshot.docs) {
            connections.add(CrystullUser.fromSnapshot(doc));
          }
        });
      }
    } catch (e) {
      log(e.toString());
    }
    return connections;
  }

  Future<String> swapUser(
      String userId, Map<String, double> sliderValues) async {
    String res = "Some error occured";
    try {
      if (userId.isNotEmpty) {
        // remove all the zero values from the map
        Map<String, double> nonEmptySliderValues = {};

        sliderValues.forEach((key, value) {
          if (value != 0) {
            nonEmptySliderValues[key] = value;
          }
        });

        // nonEmptySliderValues.removeWhere((key, value) => value == 0);

        DateTime now = DateTime.now();
        String swapId = const Uuid().v4();
        Map<String, dynamic> individual = <String, dynamic>{
          'fromUid': _auth.currentUser!.uid,
          'toUid': userId,
          'addedAt': now
        };
        nonEmptySliderValues.forEach((key, value) {
          individual[key] = SwapData(value: value).toJson();
        });
        // Map<String, Swap> swap = {};
        DateTime start = DateTime(now.year, now.month, now.day);
        List<DateTime> days =
            List.generate(8, (i) => start.subtract(Duration(days: i)));
        var batch = _firestore.batch();

        // for each key in the map update the swap collection:
        // 1. if the user is not swapped for a property then add it
        // 2. if the user is swapped for a property then append it to individual and update weekly and cumulative

        batch.set(
          _firestore
              .collection('swaps')
              .doc(userId + '_swapped_' + _auth.currentUser!.uid)
              .collection("individual")
              .doc(swapId),
          individual,
          SetOptions(merge: true),
        );
        nonEmptySliderValues.forEach((key, value) {
          batch.set(
            _firestore
                .collection('swaps')
                .doc(userId + '_swapped_' + _auth.currentUser!.uid),
            {
              'lastSwappedAt': now,
              'lastSwappedID': swapId,
              'cumulative': {
                key: {
                  'sum': FieldValue.increment(value),
                  'count': FieldValue.increment(1),
                }
              },
              // 'weekly.${days[0].toString()}.sum': FieldValue.increment(value),
              // 'weekly.${days[0].toString()}.count': FieldValue.increment(1),
              'weekly': {
                for (var day in days)
                  day.toString(): {
                    key: {
                      'sum': FieldValue.increment(value),
                      'count': FieldValue.increment(1)
                    }
                  }
              },
            },
            SetOptions(merge: true),
          );
        });

        await batch.commit();
        res = "Success";
      }
    } catch (e) {
      res = e.toString();
      log(res);
    }
    return res;
  }

  Future<Map<String, Map<String, dynamic>>> getAttributes(String uid) {
    Map<String, Map<String, dynamic>> attributes = {};
    var data =  _firestore
        .collection('swaps').doc(uid + '_swapped_' + _auth.currentUser!.uid).get();
        
  }
}
