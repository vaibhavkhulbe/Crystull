import 'dart:developer';

import 'package:crystull/providers/user_provider.dart';
import 'package:crystull/resources/auth_methods.dart';
import 'package:crystull/resources/models/signup.dart';
import 'package:crystull/screens/edit_profile.dart';
import 'package:crystull/utils/utils.dart';
import 'package:flutter/material.dart';
import 'package:crystull/screens/search_screen.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:provider/provider.dart';

class ProfileScreen extends StatefulWidget {
  CrystullUser user;
  final bool isHome;
  ProfileScreen({Key? key, required this.user, this.isHome = false})
      : super(key: key);

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  Map<String, Widget> popUpMenuItems = {};
  
  bool isAnonymousPost = false;
  @override
  void initState() {
    refreshUser();
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  void handleResult(String result) {
    if (result == "Success") {
      setState(() {
        refreshUser();
      });
    } else {
      log(result);
    }
  }

  onSelect(item) {
    UserProvider userProvider =
        Provider.of<UserProvider>(context, listen: false);
    switch (item) {
      case "Block":
        () async {
          String result = await AuthMethods()
              .addFriendRequest(userProvider.getUser!, widget.user, 4, 5);
          handleResult(result);
        }();
        break;
      case "Unblock":
        () async {
          String result = await AuthMethods()
              .removeFriend(userProvider.getUser!, widget.user);
          handleResult(result);
        }();
        break;
      case "Remove":
        () async {
          String result = await AuthMethods()
              .removeFriend(userProvider.getUser!, widget.user);
          handleResult(result);
        }();
        break;
    }
  }

  void refreshUser() async {
    UserProvider userProvider =
        Provider.of<UserProvider>(context, listen: false);
    await userProvider.refreshUser();
    CrystullUser updatedUser = await AuthMethods().refreshUser(widget.user);
    widget.user = updatedUser;

    if (widget.user.uid != userProvider.getUser!.uid) {
      Friend? connectionState =
          widget.user.connections[userProvider.getUser!.uid];
      if (connectionState != null) {
        if (connectionState.status <= 3) {
          popUpMenuItems['Block'] = Row(
            children: const [
              Icon(
                Icons.block,
                color: Colors.black87,
                size: 20,
              ),
              SizedBox(
                width: 5,
              ),
              Text(
                'Block',
                style: TextStyle(
                  color: Colors.black87,
                  fontSize: 14,
                ),
              ),
            ],
          );
        } else if (connectionState.status == 5) {
          popUpMenuItems['Unblock'] = Row(
            children: const [
              Icon(
                Icons.check_circle,
                color: Colors.black87,
                size: 20,
              ),
              SizedBox(
                width: 5,
              ),
              Text(
                'Unblock',
                style: TextStyle(
                  color: Colors.black87,
                  fontSize: 14,
                ),
              ),
            ],
          );
        }
        if (connectionState.status == 3) {
          popUpMenuItems['Remove'] = Row(
            children: [
              SvgPicture.asset(
                'images/icons/removeFriend.svg',
                color: Colors.redAccent,
                width: 20,
                height: 20,
              ),
              const SizedBox(
                width: 5,
              ),
              const Text(
                'Remove',
                style: TextStyle(
                  color: Colors.redAccent,
                  fontSize: 14,
                ),
              ),
            ],
          );
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    CrystullUser? _currentUser = Provider.of<UserProvider>(context).getUser;
    bool isMe = _currentUser!.email == widget.user.email;
    return Scaffold(
        appBar: !widget.isHome
            ? AppBar(
                backgroundColor: Colors.white,
                iconTheme: const IconThemeData(color: Colors.black),
              )
            : null,
        body: Container(
          decoration: BoxDecoration(color: Color(0xFFE5E5E5)),
          child: ListView(
            children: [
              Card(
                color: Colors.white,
                shape: const RoundedRectangleBorder(
                  borderRadius: BorderRadius.zero,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    SizedBox(
                      height: MediaQuery.of(context).size.height * 0.25,
                      child: Stack(
                          clipBehavior: Clip.none,
                          alignment: Alignment.topLeft,
                          children: [
                            // background image
                            Image.asset(
                              'images/home/1.png',
                              alignment: Alignment.topLeft,
                              fit: BoxFit.fitWidth,
                              height: MediaQuery.of(context).size.height * 0.1,
                              width: getSafeAreaWidth(context),
                            ),

                            // edit background image
                            isMe
                                ? Positioned(
                                    top: MediaQuery.of(context).size.height *
                                        0.01,
                                    right: MediaQuery.of(context).size.width *
                                        0.05,
                                    child: InkWell(
                                      onTap: () {
                                        Navigator.pop(context);
                                      },
                                      child: Container(
                                        decoration: BoxDecoration(
                                          border: Border.all(
                                              color: Colors.white, width: 2),
                                          color: Colors.white.withOpacity(0.5),
                                        ),
                                        child: Row(
                                          children: const [
                                            Icon(
                                              Icons.camera_alt_rounded,
                                              color: Colors.black45,
                                              size: 8,
                                            ),
                                            SizedBox(width: 5),
                                            Text(
                                              'Edit Photo',
                                              style: TextStyle(
                                                  fontSize: 8,
                                                  color: Colors.black45),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                  )
                                : Container(),

                            // User profile image
                            Positioned(
                                top: MediaQuery.of(context).size.height * 0.06,
                                left: MediaQuery.of(context).size.width * 0.05,
                                child: Container(
                                  width: getSafeAreaWidth(context) * 0.3,
                                  height: getSafeAreaWidth(context) * 0.3,
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    color: Colors.black54,
                                    image: DecorationImage(
                                      fit: BoxFit.cover,
                                      image: widget.user.profileImage != null
                                          ? Image.memory(
                                                  widget.user.profileImage!)
                                              .image
                                          : widget.user.profileImageUrl
                                                  .isNotEmpty
                                              ? Image.network(widget
                                                      .user.profileImageUrl)
                                                  .image
                                              : const ExactAssetImage(
                                                  'images/avatar.png'),
                                    ),
                                    border: Border.all(
                                      color: Colors.white,
                                      width: 4.0,
                                    ),
                                  ),
                                )),

                            // User details
                            Positioned(
                              width: MediaQuery.of(context).size.width * 0.5,
                              top: MediaQuery.of(context).size.height * 0.11,
                              left: MediaQuery.of(context).size.width * 0.4,
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Wrap(
                                    alignment: WrapAlignment.start,
                                    crossAxisAlignment:
                                        WrapCrossAlignment.start,
                                    children: [
                                      Text(
                                        widget.user.fullName.capitalize(),
                                        style: const TextStyle(
                                          color: Colors.black87,
                                          fontSize: 14,
                                          // fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ],
                                  ),
                                  Wrap(
                                    alignment: WrapAlignment.start,
                                    crossAxisAlignment:
                                        WrapCrossAlignment.start,
                                    children: [
                                      Text(
                                        widget.user.bio,
                                        style: const TextStyle(
                                          color: Colors.black54,
                                          fontSize: 10,
                                        ),
                                      ),
                                    ],
                                  ),
                                  widget.user.college.isNotEmpty
                                      ? Wrap(
                                          alignment: WrapAlignment.start,
                                          crossAxisAlignment:
                                              WrapCrossAlignment.start,
                                          children: [
                                            Text(
                                              "Studied " +
                                                  (widget.user.degree.isNotEmpty
                                                      ? widget.user.degree
                                                      : "") +
                                                  " at " +
                                                  widget.user.college,
                                              style: const TextStyle(
                                                color: Colors.black54,
                                                fontSize: 10,
                                              ),
                                            ),
                                          ],
                                        )
                                      : Container(),
                                ],
                              ),
                            ),
                            !isMe
                                ? Positioned(
                                    top: MediaQuery.of(context).size.height *
                                        0.1,
                                    right: MediaQuery.of(context).size.width *
                                        0.01,
                                    child: PopupMenuButton<String>(
                                      icon: const Icon(
                                        Icons.more_vert,
                                        color: Colors.black54,
                                      ),
                                      color: Colors.white,
                                      onSelected: onSelect,
                                      itemBuilder: (BuildContext context) {
                                        return popUpMenuItems.entries
                                            .map(
                                              (mapEntry) =>
                                                  PopupMenuItem<String>(
                                                      value: mapEntry.key,
                                                      child: mapEntry.value),
                                            )
                                            .toList();
                                      },
                                    ),
                                  )
                                : Container(),
                            isMe
                                ? Positioned(
                                    top: MediaQuery.of(context).size.height *
                                        0.17,
                                    left:
                                        MediaQuery.of(context).size.width * 0.4,
                                    child: InkWell(
                                      onTap: () async {
                                        await Navigator.push(
                                            context,
                                            MaterialPageRoute(
                                              builder: (context) =>
                                                  EditProfileScreen(
                                                      user: widget.user),
                                            ));
                                        setState(() {});
                                      },
                                      child: const Text(
                                        "Edit Profile",
                                        style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                          decoration: TextDecoration.underline,
                                          color: Colors.black54,
                                          fontSize: 12,
                                        ),
                                      ),
                                    ),
                                  )
                                : Positioned(
                                    top: MediaQuery.of(context).size.height *
                                        0.16,
                                    left:
                                        MediaQuery.of(context).size.width * 0.4,
                                    child: getProfileButton(
                                        _currentUser, widget.user)!),
                          ]),
                    ),
                  ],
                ),
              ),
              Card(
                  color: Colors.white,
                  shape: const RoundedRectangleBorder(
                    borderRadius: BorderRadius.zero,
                  ),
                  child: Container(
                    padding: EdgeInsets.all(10),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Text(
                          "Help " +
                              widget.user.firstName.capitalize() +
                              " to improve their skills",
                          style: const TextStyle(
                            color: Colors.black87,
                            fontSize: 16,
                          ),
                        ),
                        Row(
                          children: [
                            const Text("SWAP anonymously",
                                style: TextStyle(
                                    fontSize: 16, color: Colors.black54)),
                            Flexible(child: Container()),
                            Switch(
                              activeColor: Colors.lightBlueAccent,
                              inactiveTrackColor: Colors.grey,
                              value: isAnonymousPost,
                              onChanged: (value) async {
                                if (value) {
                                  isAnonymousPost = true;
                                } else {
                                  isAnonymousPost = false;
                                }
                                setState(() {});
                              },
                            ),
                          ],
                        )
                      ],
                    ),
                  ))
            ],
          ),
        ));
  }

  Widget? getProfileButton(CrystullUser currentUser, CrystullUser otherUser) {
    int status = getFriendStatus(currentUser.connections, otherUser.uid);
    switch (status) {
      // user is not connected or requested
      case 0:
        return getStatusButton(
          Colors.lightBlueAccent,
          Colors.lightBlueAccent,
          "Connect",
          Colors.white,
          () async {
            String result = await AuthMethods()
                .addFriendRequest(currentUser, otherUser, 1, 2);
            handleResult(result);
          },
        );
      // Current user is the one requesting
      case 1:
        return getStatusButton(
            Colors.white, Colors.black54, "Request sent", Colors.black54,
            () async {
          String result =
              await AuthMethods().removeFriend(currentUser, otherUser);
          handleResult(result);
        });
      // Current user is the one accepting
      case 2:
        return Row(
          children: [
            getStatusButton(Colors.lightBlueAccent, Colors.lightBlueAccent,
                "Accept", Colors.white, () async {
              String result = await AuthMethods()
                  .addFriendRequest(currentUser, otherUser, 3, 3);
              handleResult(result);
            }),
            getStatusButton(
                Colors.white, Colors.black54, "Remove", Colors.black54,
                () async {
              String result =
                  await AuthMethods().removeFriend(otherUser, currentUser);
              handleResult(result);
            })
          ],
        );
      // The two users are connected
      case 3:
        return Container(
            padding: const EdgeInsets.symmetric(vertical: 8),
            decoration: const BoxDecoration(
              color: Colors.white,
            ),
            child: Row(
              children: [
                SvgPicture.asset("images/icons/friendRequests.svg",
                    color: Colors.lightBlueAccent),
                const SizedBox(width: 5),
                const Text(
                  "Connected",
                  style: TextStyle(
                    color: Colors.lightBlueAccent,
                    fontSize: 14,
                  ),
                ),
              ],
            ));

      // Current user has blocked the other user
      case 4:
        return Container(
          padding: const EdgeInsets.symmetric(vertical: 8),
          decoration: const BoxDecoration(
            color: Colors.white,
          ),
          child: Row(
            children: const [
              Icon(Icons.block, color: Colors.red),
              SizedBox(width: 5),
              Text(
                "Blocked",
                style: TextStyle(
                  color: Colors.red,
                  fontSize: 14,
                ),
              ),
            ],
          ),
        );
    }
    return null;
  }

  int getFriendStatus(Map<String, Friend> connections, String uid) {
    int status = 0;
    if (connections.containsKey(uid)) {
      Friend friend = connections[uid]!;
      status = friend.status;
    }
    return status;
  }

  Widget getStatusButton(Color boxColor, Color borderColor, String text,
      Color textColor, Function() function) {
    return InkWell(
      onTap: function,
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 4, vertical: 10),
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
        decoration: BoxDecoration(
          border: Border.all(color: borderColor, width: 1),
          color: boxColor,
        ),
        child: Text(
          text,
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: textColor,
            fontSize: 12,
          ),
        ),
      ),
    );
  }
}
