import 'dart:developer';

import 'package:crystull/providers/user_provider.dart';
import 'package:crystull/resources/auth_methods.dart';
import 'package:crystull/resources/models/signup.dart';
import 'package:crystull/responsive/mobile_screen_layout.dart';
import 'package:crystull/screens/edit_profile.dart';
import 'package:crystull/utils/utils.dart';
import 'package:crystull/widgets/sllider_widget.dart';
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
  Map<String, double> sliderValues = {};
  bool isAnonymousPost = false;
  bool _isSwapping = false;
  bool isSwapEnabled = false;
  CrystullUser? _currentUser;
  List<CrystullUser> connectedUsers = [];
  Map<String, double> _swapValues = {};

  @override
  void initState() {
    sliderValues = {
      'Personality': 0,
      'Behaviour': 0,
      'Communication': 0,
      'Empathy': 0,
      'Character': 0,
      'Welfare': 0,
    };
    refreshUser();
    UserProvider().refreshUser();
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

  swapUser() async {
    setState(() {
      _isSwapping = true;
    });
    String res = await AuthMethods().swapUser(
      widget.user.uid,
      sliderValues,
    );
    if (res == "Success") {
      showSnackBar("Used SWAPPed Successfully", context);
    } else {
      showSnackBar("SWAPPing failed. Please try again", context);
    }
    setState(() {
      _isSwapping = false;
    });
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

    if (widget.user.uid != _currentUser!.uid) {
      Friend? connectionState = widget.user.connections[_currentUser!.uid];
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
    } else {
      List<CrystullUser> localConnectedUsers =
          await AuthMethods.getConnections(widget.user);
      if (mounted) {
        setState(() {
          connectedUsers = localConnectedUsers;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    _currentUser = Provider.of<UserProvider>(context).getUser;

    bool isMe = _currentUser!.uid == widget.user.uid;
    return Scaffold(
        appBar: !widget.isHome
            ? AppBar(
                backgroundColor: Colors.white,
                iconTheme: const IconThemeData(color: Colors.black),
              )
            : null,
        body: Container(
          decoration: const BoxDecoration(color: Color(0xFFEEEEEE)),
          child: ListView(
            children: [
              // Card for the profile. Could be self or others
              Card(
                shadowColor: Colors.white,
                color: Colors.white,
                shape: const ContinuousRectangleBorder(),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    SizedBox(
                      height: isMe
                          ? getSafeAreaHeight(context) * 0.22
                          : getSafeAreaHeight(context) * 0.25,
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
                                  width: getSafeAreaWidth(context) * 0.25,
                                  height: getSafeAreaWidth(context) * 0.25,
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
                              left: MediaQuery.of(context).size.width * 0.35,
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
                                          color: Color(0xFF575757),
                                          fontSize: 12,
                                          fontWeight: FontWeight.bold,
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
                                          fontSize: 9,
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
                                                fontSize: 9,
                                              ),
                                            ),
                                          ],
                                        )
                                      : Container(),
                                  isMe
                                      ? Wrap(
                                          children: [
                                            InkWell(
                                              onTap: () async {
                                                await Navigator.push(
                                                    context,
                                                    MaterialPageRoute(
                                                      builder: (context) =>
                                                          EditProfileScreen(
                                                              user:
                                                                  widget.user),
                                                    ));
                                                setState(() {});
                                              },
                                              child: const Text(
                                                "Edit Profile",
                                                style: TextStyle(
                                                  fontWeight: FontWeight.bold,
                                                  color: Colors.black54,
                                                  fontSize: 8,
                                                ),
                                              ),
                                            ),
                                          ],
                                        )
                                      : Container()
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
                            !isMe
                                ? Positioned(
                                    top: MediaQuery.of(context).size.height *
                                        0.16,
                                    left: MediaQuery.of(context).size.width *
                                        0.35,
                                    child: getProfileButton(
                                        _currentUser!, widget.user)!)
                                : Container(),
                          ]),
                    ),
                  ],
                ),
              ),

              // Card for showing the attributes
              isMe ||
                      (widget.user.connections[_currentUser!.uid] != null &&
                          widget.user.connections[_currentUser!.uid]!.status ==
                              3)
                  ? Card(
                      shadowColor: Colors.white,
                      color: Colors.white,
                      shape: const ContinuousRectangleBorder(),
                      child: Container(
                        margin: const EdgeInsets.only(top: 10),
                        padding: const EdgeInsets.all(10),
                        child: const Text(
                          "Primary Attributes",
                          style: TextStyle(
                              fontSize: 14,
                              // fontWeight: FontWeight.bold,
                              color: Color(0xFF575757)),
                        ),
                      ))
                  : Card(
                      shadowColor: Colors.white,
                      color: Colors.white,
                      shape: const ContinuousRectangleBorder(),
                      child: Container(
                        padding: const EdgeInsets.all(10),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              widget.user.firstName.capitalize() +
                                  "'s Top Attributes",
                              style: const TextStyle(
                                  fontSize: 14, color: Color(0xFF575757)),
                            ),
                            const Center(
                              child: Text(
                                  "Send connection request to see all attributes",
                                  style: TextStyle(
                                      fontSize: 10,
                                      color: Colors.black54,
                                      fontStyle: FontStyle.italic)),
                            ),
                          ],
                        ),
                      ),
                    ),

              // Card for showing the connections or to post the SWAP
              isMe
                  ? Card(
                      shadowColor: Colors.white,
                      color: Colors.white,
                      shape: const ContinuousRectangleBorder(),
                      child: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              "Connections",
                              style: TextStyle(
                                color: Color(0xFF575757),
                                fontWeight: FontWeight.bold,
                                fontSize: 14,
                              ),
                            ),
                            Row(
                              children: [
                                Text(
                                  connectedUsers.length.toString() +
                                      " Connections",
                                  style: const TextStyle(
                                    color: Colors.black54,
                                    fontSize: 8,
                                  ),
                                ),
                                Flexible(child: Container()),
                                GestureDetector(
                                  onTap: () {
                                    Navigator.pushReplacement(
                                        context,
                                        MaterialPageRoute(
                                          builder: (context) =>
                                              MobileScreenLayout(
                                            screen: 1,
                                          ),
                                        ));
                                  },
                                  child: const Text(
                                    "See all",
                                    style: TextStyle(
                                      color: Colors.lightBlueAccent,
                                      fontSize: 8,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            SizedBox(
                                height: getSafeAreaHeight(context) * 0.3,
                                child: GridView(
                                  padding:
                                      const EdgeInsets.symmetric(vertical: 10),
                                  gridDelegate:
                                      const SliverGridDelegateWithFixedCrossAxisCount(
                                    crossAxisCount: 4,
                                    childAspectRatio: 0.6,
                                    // crossAxisSpacing: 10,
                                    // mainAxisSpacing: 10,
                                  ),
                                  children: [
                                    for (var i = 0;
                                        i < connectedUsers.length;
                                        i++)
                                      GestureDetector(
                                        onTap: () {
                                          Navigator.push(
                                              context,
                                              MaterialPageRoute(
                                                builder: (context) =>
                                                    ProfileScreen(
                                                  user: connectedUsers[i],
                                                ),
                                              ));
                                        },
                                        child: Column(
                                          children: [
                                            Container(
                                              margin:
                                                  const EdgeInsets.symmetric(
                                                      vertical: 5),
                                              width: getSafeAreaWidth(context) *
                                                  0.2,
                                              height:
                                                  getSafeAreaWidth(context) *
                                                      0.2,
                                              decoration: BoxDecoration(
                                                borderRadius:
                                                    const BorderRadius.all(
                                                        Radius.circular(4)),
                                                image: DecorationImage(
                                                  image: NetworkImage(
                                                      connectedUsers[i]
                                                          .profileImageUrl),
                                                  fit: BoxFit.cover,
                                                ),
                                              ),
                                            ),
                                            Wrap(
                                              crossAxisAlignment:
                                                  WrapCrossAlignment.start,
                                              children: [
                                                Text(
                                                  connectedUsers[i]
                                                      .fullName
                                                      .capitalize(),
                                                  style: const TextStyle(
                                                    color: Colors.black,
                                                    fontSize: 14,
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ],
                                        ),
                                      ),
                                  ],
                                )),
                          ],
                        ),
                      ))
                  : Card(
                      shadowColor: Colors.white,
                      color: Colors.white,
                      shape: const ContinuousRectangleBorder(),
                      child: Container(
                        padding: const EdgeInsets.all(10),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              "Help " +
                                  widget.user.firstName.capitalize() +
                                  " to improve their skills",
                              style: const TextStyle(
                                color: Colors.black87,
                                fontSize: 14,
                              ),
                            ),
                            Row(
                              children: [
                                const Text("SWAP anonymously",
                                    style: TextStyle(
                                        fontSize: 13, color: Colors.black54)),
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
                            ),
                            SizedBox(
                              height: getSafeAreaHeight(context) * 0.23,
                              child: GridView(
                                  // padding: const EdgeInsets.all(10),
                                  gridDelegate:
                                      const SliverGridDelegateWithFixedCrossAxisCount(
                                    crossAxisCount: 2,
                                    childAspectRatio: 2.5,
                                    crossAxisSpacing: 50,
                                  ),
                                  children: [
                                    for (var entry in sliderValues.entries)
                                      getSliderWidgetWithLabel(
                                        entry.key,
                                        entry.value,
                                        (value) {
                                          sliderValues[entry.key] = value;
                                          setState(() {
                                            if (sliderValues.values.any(
                                                (element) => element != 0)) {
                                              isSwapEnabled = true;
                                            } else {
                                              isSwapEnabled = false;
                                            }
                                          });
                                        },
                                      )
                                  ]),
                            ),
                            Container(
                              alignment: Alignment.topRight,
                              child: GestureDetector(
                                onTap: () => {},
                                child: const Text("+ More",
                                    style: TextStyle(
                                        fontSize: 13,
                                        color: Colors.lightBlueAccent)),
                              ),
                            ),
                            Center(
                              child: Container(
                                alignment: Alignment.center,
                                padding:
                                    const EdgeInsets.symmetric(vertical: 8),
                                margin:
                                    const EdgeInsets.only(top: 40, bottom: 20),
                                decoration: BoxDecoration(
                                  color: isSwapEnabled
                                      ? Colors.lightBlueAccent
                                      : Colors.lightBlueAccent.withOpacity(0.5),
                                ),
                                width: getSafeAreaWidth(context) * 0.25,
                                child: isSwapEnabled
                                    ? InkWell(
                                        onTap: () {
                                          swapUser();
                                        },
                                        child: _isSwapping
                                            ? SizedBox(
                                                width:
                                                    getSafeAreaHeight(context) *
                                                        0.02,
                                                height:
                                                    getSafeAreaHeight(context) *
                                                        0.02,
                                                child:
                                                    const CircularProgressIndicator(
                                                        strokeWidth: 2,
                                                        color: Colors.white),
                                              )
                                            : const Text(
                                                "Submit",
                                                style: TextStyle(
                                                  fontSize: 12,
                                                  fontWeight: FontWeight.bold,
                                                ),
                                              ),
                                      )
                                    : const Text(
                                        "Submit",
                                        style: TextStyle(
                                          fontSize: 12,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    )
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

  Widget getSliderWidgetWithLabel(
      String columnName, double value, void Function(double) onchanged,
      {double min = 0, double max = 100}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Text(
          columnName,
          style: const TextStyle(color: Colors.black54, fontSize: 12),
        ),
        const SizedBox(height: 10),
        SliderTheme(
          data: SliderThemeData(
            overlayShape: SliderComponentShape.noOverlay,
            trackHeight: 6,
            activeTrackColor: Colors.lightBlueAccent,
            inactiveTrackColor: const Color(0xFFEEEEEE),
            thumbColor: Colors.white,
            thumbShape: const CircleThumbShape(),
            // trackShape:
          ),
          child: Slider(
            value: value,
            label: value.toString(),
            min: min,
            max: max,
            onChanged: onchanged,
          ),
        ),
      ],
    );
  }
}
