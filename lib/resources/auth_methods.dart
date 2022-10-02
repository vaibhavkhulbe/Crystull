import 'dart:developer';
import 'dart:typed_data';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:crystull/resources/models/signup.dart';
import 'package:crystull/resources/models/weekly_attributes.dart';
import 'package:crystull/resources/storage_methods.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/services.dart';
import 'package:flutter_facebook_auth/flutter_facebook_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:uuid/uuid.dart';

class AuthMethods {
  final FacebookAuth fbSignIn = FacebookAuth.instance;
  final GoogleSignIn googleSignIn = GoogleSignIn();
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

  Future<Map<String, CrystullUser>> getUserDetailsFromid(
      List<String> uids) async {
    Map<String, CrystullUser> users = {};
    await _firestore
        .collection('users')
        .where('uid', whereIn: uids)
        .get()
        .then((QuerySnapshot snapshot) async {
      for (var doc in snapshot.docs) {
        users[doc['uid']] = CrystullUser.fromSnapshot(doc);
      }
    });
    return users;
  }

  Future<Uint8List?> getUserImage() async {
    Uint8List? image = await StorageMethods()
        .downloadUserImage("profilePics", _auth.currentUser!.uid);
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
            signupForm.uid = credValue.user!.uid;
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

    if (signupForm.email.isNotEmpty || signupForm.password.isNotEmpty) {
      try {
        // register the user
        UserCredential cred = await _auth.signInWithEmailAndPassword(
            email: signupForm.email, password: signupForm.password);

        log("User logged in successfully " + cred.user!.uid);
        res = "Success";
      } on FirebaseAuthException catch (e) {
        if (e.code == 'wrong-password') {
          var methods =
              await _auth.fetchSignInMethodsForEmail(signupForm.email);
          if (methods.contains('facebook.com')) {
            res = "Account already exists with Facebook";
          } else if (methods.contains('google.com')) {
            res = "Account already exists with Google";
          } else {
            res = "Wrong password";
          }
        } else {
          res = e.code;
        }
      } catch (e) {
        res = e.toString();
        log(res);
      }
    }
    return res;
  }

  Future<String> loginWithGoogle() async {
    String res = "Some error occured";
    UserCredential cred;
    try {
      final googleUser = await googleSignIn.signIn();
      if (googleUser == null) return res;
      final googleAuth = await googleUser.authentication;
      final credentials = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );
      try {
        cred = await _auth.signInWithCredential(credentials);
        if (cred.additionalUserInfo!.isNewUser) {
          log("New user created");
          String uid = cred.user!.uid;
          String photoUrl = "";
          if (googleUser.photoUrl != null) {
            Uint8List profilePic =
                (await NetworkAssetBundle(Uri.parse(googleUser.photoUrl!))
                        .load(googleUser.photoUrl!))
                    .buffer
                    .asUint8List();
            photoUrl = await StorageMethods()
                .uploadImage("profilePics", profilePic, false);
          }
          if (photoUrl.isNotEmpty) {
            log("Photo uploaded " + photoUrl);
            CrystullUser user = CrystullUser(
              googleUser.displayName!.split(" ")[0],
              googleUser.displayName!.split(" ")[1],
              googleUser.email,
              "",
              uid: uid,
              profileImageUrl: photoUrl,
            );
            await _firestore
                .collection('users')
                .doc(cred.user!.uid)
                .set(user.toMap());
            log("User created successfully " + cred.user!.uid);
          } else {
            log("Photo upload failed " + photoUrl + "Deleting user");
            cred.user!.delete();
          }
        } else {
          log("User logged in successfully " + cred.user!.uid);
        }
      } on FirebaseAuthException catch (e) {
        if (e.code == 'account-exists-with-different-credential') {
          var methods = await _auth.fetchSignInMethodsForEmail(e.email!);
          if (methods.contains('facebook.com')) {
            res = "Account already exists with Facebook";
          } else {
            res = "Account already exists with Email and Password";
          }
          // final LoginResult result = await fbSignIn.login();
          // if (result.status == LoginStatus.success) {
          //   // you are logged in
          //   final AccessToken accessToken = result.accessToken!;
          //   var fbcredentials = FacebookAuthProvider.credential(
          //     accessToken.token,
          //   );
          //   await _auth.signInWithCredential(fbcredentials);
          //   await _auth.currentUser!.linkWithCredential(credentials);
          // }
        }
      }
      res = "Success";
    } catch (e) {
      res = e.toString();
      log(res);
    }
    return res;
  }

  Future<String> loginWithFacebook() async {
    String res = "Some error occured";
    final OAuthCredential credentials;
    UserCredential cred;
    try {
      final LoginResult result = await fbSignIn.login();
      // by default we request the email and the public profile or FacebookAuth.i.login()
      if (result.status == LoginStatus.success) {
        // you are logged in
        final AccessToken accessToken = result.accessToken!;
        credentials = FacebookAuthProvider.credential(
          accessToken.token,
        );
        try {
          cred = await _auth.signInWithCredential(credentials);
          if (cred.additionalUserInfo!.isNewUser) {
            log("New user created");
            String uid = cred.user!.uid;
            String photoUrl = "";
            if (cred.additionalUserInfo!.profile!["picture"] != null &&
                cred.additionalUserInfo!.profile!["picture"]!["data"]!["url"] !=
                    null) {
              String url =
                  cred.additionalUserInfo!.profile!["picture"]!["data"]!["url"];
              Uint8List profilePic =
                  (await NetworkAssetBundle(Uri.parse(url)).load(url))
                      .buffer
                      .asUint8List();
              photoUrl = await StorageMethods()
                  .uploadImage("profilePics", profilePic, false);

              if (photoUrl.isNotEmpty) {
                log("Photo uploaded " + photoUrl);
                CrystullUser user = CrystullUser(
                  cred.user!.displayName!.split(" ")[0],
                  cred.user!.displayName!.split(" ")[1],
                  cred.user!.email!,
                  "",
                  uid: uid,
                  profileImage: profilePic,
                  profileImageUrl: photoUrl,
                );
                await _firestore
                    .collection('users')
                    .doc(cred.user!.uid)
                    .set(user.toMap());
                log("User created successfully " + cred.user!.uid);
              } else {
                log("Photo upload failed " + photoUrl + "Deleting user");
                cred.user!.delete();
              }
            }
          } else {
            log("User logged in successfully " + cred.user!.uid);
          }
          res = "Success";
        } on FirebaseAuthException catch (e) {
          if (e.code == 'account-exists-with-different-credential') {
            var methods = await _auth.fetchSignInMethodsForEmail(e.email!);
            if (methods.contains('google.com')) {
              res = "Account already exists with Google";
            } else {
              res = "Account already exists with Email and Password";
            }
            // uncomment this if you want to link two accounts
            // final googleUser = await googleSignIn.signIn();
            // if (googleUser == null) return res;
            // final googleAuth = await googleUser.authentication;
            // final googleCredentials = GoogleAuthProvider.credential(
            //   accessToken: googleAuth.accessToken,
            //   idToken: googleAuth.idToken,
            // );
            // await _auth.signInWithCredential(googleCredentials);
            // await _auth.currentUser!.linkWithCredential(credentials);
          }
        }
      } else {
        res = "Login failed with status " +
            result.status.toString() +
            (result.message != null ? " and error " + result.message! : "");
        log(res);
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
          'firstName': user.firstName,
          'lastName': user.lastName,
          'fullName': (user.firstName + " " + user.lastName).toLowerCase(),
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

  Future<CrystullUser?> refreshUser(String userId) async {
    String res = "Some error occured";
    CrystullUser? user;
    try {
      if (userId.isNotEmpty) {
        // update the user
        await _firestore.collection('users').doc(userId).get().then((doc) {
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
    // 1 is the current user sending request
    // 2 is the friend receiving request
    // 3 is the friends status
    // 4 is the current user blocking
    // 5 is the current user blocked
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
      String toUserId,
      String toUserName,
      String fromUserId,
      String fromUserName,
      Map<String, double> sliderValues,
      bool isAnonymous) async {
    String res = "Some error occured";
    try {
      if (toUserId.isNotEmpty) {
        // remove all the zero values from the map
        Map<String, double> nonEmptySliderValues = {};

        sliderValues.forEach((key, value) {
          if (value != 0) {
            nonEmptySliderValues[key] = value;
          }
        });

        DateTime now = DateTime.now();
        DateTime start = DateTime(now.year, now.month, now.day);
        List<DateTime> days =
            List.generate(8, (i) => start.subtract(Duration(days: i)));
        String swapId = const Uuid().v4();
        Swap individual = Swap(
          id: swapId,
          fromUid: fromUserId,
          toUid: toUserId,
          addedAt: now,
          anonymous: isAnonymous,
          unread: true,
          swaps: nonEmptySliderValues,
          swapList: nonEmptySliderValues.keys.toList(),
        );

        var batch = _firestore.batch();

        // for each key in the map update the swap collection:
        // 1. if the user is not swapped for a property then add it
        // 2. if the user is swapped for a property then append it to individual and update weekly and cumulative

        batch.set(
          _firestore.collection("individual").doc(swapId),
          individual.toJson(),
          SetOptions(merge: true),
        );
        nonEmptySliderValues.forEach((key, value) {
          batch.set(
            _firestore.collection('swaps').doc(toUserId),
            {
              _auth.currentUser!.uid: {
                'lastSwappedAt': now,
                'lastSwappedID': swapId,
              },
              'cumulative': {
                key: {
                  'sum': FieldValue.increment(value),
                  'count': FieldValue.increment(1),
                }
              },
            },
            SetOptions(merge: true),
          );
          batch.set(
            _firestore.collection('swaps').doc(_auth.currentUser!.uid),
            {
              'cumulative_given': {
                key: {
                  'sum': FieldValue.increment(value),
                  'count': FieldValue.increment(1),
                }
              },
            },
            SetOptions(merge: true),
          );
          for (var day in days) {
            batch.set(
              _firestore
                  .collection("weekly")
                  .doc(day.toString())
                  .collection('swaps')
                  .doc(toUserId),
              {
                key: {
                  'sum': FieldValue.increment(value),
                  'count': FieldValue.increment(1)
                }
              },
              SetOptions(merge: true),
            );
          }
        });
        // _firestore.collection('swaps').doc(userId).collection("weekly").where();

        await batch.commit();
        res = "Success";
      }
    } catch (e) {
      res = e.toString();
      log(res);
    }
    return res;
  }

  Future<SwapAttributes> getCombinedAttributes(
    String uid,
  ) async {
    Map<String, double> attributes = {};
    Map<String, SwapInfo> swapInfo = {};

    var snapshot = await _firestore.collection('swaps').doc(uid).get();
    if (snapshot.exists) {
      Map<String, dynamic> swap = snapshot.data() ?? {};
      Map<String, dynamic> cumulative = swap['cumulative'] ?? {};
      cumulative.forEach((key, value) {
        if (value['count'] != null && value['count'] != 0) {
          attributes[key] = value['sum'] / value['count'];
        }
      });

      for (var entry in swap.entries) {
        if (entry.key != 'cumulative' &&
            entry.key != 'cumulative_given' &&
            entry.key != 'weekly') {
          swapInfo[entry.key] = SwapInfo(
            lastSwappedAt: (entry.value['lastSwappedAt'] as Timestamp).toDate(),
            lastSwappedID: entry.value['lastSwappedID'] as String,
          );
        }
      }
    }
    return SwapAttributes(attributes: attributes, swapInfo: swapInfo);
  }

  Future<WeeklyAttributes> getWeeklyUserWiseAttributes(
      CrystullUser _user) async {
    Map<String, Map<String, dynamic>> attributes = {};
    Map<String, CrystullUser> users = {};
    List<String> uids = [];
    _user.connections.forEach(
      (key, value) {
        if (value.status == 3) {
          uids.add(key);
        }
      },
    );

    // return Future<Map<String, double>>.value(null);
    DateTime now = DateTime.now();
    DateTime weekBefore = DateTime(now.year, now.month, now.day)
        .subtract(const Duration(days: 7));
    var snapshot = await _firestore
        .collection('weekly')
        .doc(weekBefore.toString())
        .collection('swaps')
        .where(FieldPath.documentId, whereIn: uids)
        .get();

    if (snapshot.size != 0) {
      for (var doc in snapshot.docs) {
        Map<String, dynamic> swap = doc.data();
        for (var entry in swap.entries) {
          double score = entry.value['count'] > 0
              ? entry.value['sum'] / entry.value['count']
              : 0;
          if (attributes.containsKey(entry.key)) {
            if (attributes[entry.key]!['score'] < score) {
              attributes[entry.key] = {
                'attribute': entry.key,
                'score': score,
                'uid': doc.id,
              };
            }
          } else if (score > 50) {
            attributes[entry.key] = {
              'attribute': entry.key,
              'score': score,
              'uid': doc.id,
            };
          }
        }
      }
    }
    // log(attributes.toString());

    Set<String> uniqueUids = Set.from(attributes.values.map((e) => e['uid']));

    if (uniqueUids.isNotEmpty) {
      await _firestore
          .collection('users')
          .where('uid', whereIn: uniqueUids.toList())
          .get()
          .then((QuerySnapshot snapshot) async {
        for (var doc in snapshot.docs) {
          users[doc.id] = CrystullUser.fromSnapshot(doc);
        }
      });
    }

    return WeeklyAttributes(attributes: attributes, users: users);

    // return data.then((snapshot) {
    //   if (snapshot.exists) {
    //     Map<String, double> swap = snapshot.data() ?? {};
    //     swap.forEach((key, value) {
    //       Map<String, double> weekly = value;
    //       weekly.forEach((key, value) {
    //         attributes[key] = value;
    //       });
    //     });
    //   }
    //   return attributes;
    // }).catchError((e) {
    //   log(e.toString());
    // });

    // return SwapAttributes(attributes: attributes, swapInfo: swapInfo);
  }

  Future<Map<String, Map<String, int>>> getAttributesCounts(
    String uid,
  ) async {
    Map<String, Map<String, int>> attributes = {
      "cumulative": {},
      "cumulative_given": {},
    };

    var snapshot = await _firestore.collection('swaps').doc(uid).get();
    if (snapshot.exists) {
      Map<String, dynamic> swap = snapshot.data() ?? {};
      Map<String, dynamic> cumulative = swap['cumulative'] ?? {};
      Map<String, dynamic> cumulativeGiven = swap['cumulative_given'] ?? {};
      cumulative.forEach((key, value) {
        if (value['count'] != null && value['count'] != 0) {
          attributes['cumulative']![key] = value['count'];
        }
      });
      cumulativeGiven.forEach((key, value) {
        if (value['count'] != null && value['count'] != 0) {
          attributes['cumulative_given']![key] = value['count'];
        }
      });
    }

    // log(attributes.toString());
    return attributes;
  }

  Future<List<Swap>> getIndividualAttributes(
      String fromUserId, String toUserId, String attribute,
      {bool unreadOnly = false}) async {
    List<Swap> swaps = [];
    var collectionRef = _firestore.collection('individual');
    Query<Map<String, dynamic>> query;
    if (fromUserId.isNotEmpty) {
      query = collectionRef.where('fromUid', isEqualTo: fromUserId);
    } else {
      query = collectionRef.where('toUid', isEqualTo: toUserId);
    }
    if (attribute.isNotEmpty) {
      query = query.where('swapList', arrayContains: attribute);
    }
    if (unreadOnly) {
      query = query.where('unread', isEqualTo: true);
    }
    QuerySnapshot<Map<String, dynamic>> snapshot =
        await query.orderBy('addedAt', descending: true).limit(20).get();

    if (snapshot.size != 0) {
      List<QueryDocumentSnapshot<Map<String, dynamic>>> swapData =
          snapshot.docs;
      for (var element in swapData) {
        swaps.add(Swap.fromJson(element.data()));
      }
    }
    return swaps;
  }

  Future<String> markSwapRead(String swapId) async {
    String res = "Some error occured";
    try {
      if (swapId.isNotEmpty) {
        // update the user
        await _firestore.collection('individual').doc(swapId).update({
          'unread': false,
        });
        res = "Success";
      }
    } catch (e) {
      res = e.toString();
      log(res);
    }
    return res;
  }

  Future<String> updateProfilePic({
    required Uint8List image,
  }) async {
    String res = "Some error occurred";
    try {
      String photoUrl =
          await StorageMethods().uploadImage("profilePics", image, false);
      if (photoUrl.isNotEmpty) {
        log("Photo uploaded " + photoUrl);
        await _firestore
            .collection('users')
            .doc(_auth.currentUser!.uid)
            .update({'profileImageUrl': photoUrl});
        res = "Success";
      } else {
        log("Photo upload failed " + photoUrl);
      }
    } catch (e) {
      res = e.toString();
      log(res);
    }
    return res;
  }

  Future<String> updateCoverPic({
    required Uint8List image,
  }) async {
    String res = "Some error occurred";
    try {
      String photoUrl =
          await StorageMethods().uploadImage("coverPics", image, false);
      if (photoUrl.isNotEmpty) {
        log("Photo uploaded " + photoUrl);
        await _firestore
            .collection('users')
            .doc(_auth.currentUser!.uid)
            .update({'coverImageUrl': photoUrl});
        res = "Success";
      } else {
        log("Photo upload failed " + photoUrl);
      }
    } catch (e) {
      res = e.toString();
      log(res);
    }
    return res;
  }

  Future<Swap?> getSwapFromID(String swapID) async {
    var snapshot = await _firestore.collection('individual').doc(swapID).get();

    if (snapshot.exists) {
      return Swap.fromJson(snapshot.data()!);
    }
    return null;
  }

  // Future<Map<String, List<String>>> getAttributes() async {
  //   Map<String, List<String>> attributes = {};
  //   var snapshot = await _firestore.collection('attributes').;
  //   for (var data in snapshot.data()) {

  //   }
  //   return attributes;
  // }
}
