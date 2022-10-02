import 'dart:developer';

import 'package:crystull/providers/user_provider.dart';
import 'package:crystull/resources/auth_methods.dart';
import 'package:crystull/resources/models/signup.dart';
import 'package:crystull/screens/profile_screen.dart';
import 'package:crystull/screens/search_screen.dart';
import 'package:crystull/utils/colors.dart';
import 'package:crystull/utils/utils.dart';
import 'package:crystull/widgets/alert_dialog.dart';
import 'package:crystull/widgets/app_bar.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:provider/provider.dart';

class ConnectedFriendsScreen extends StatefulWidget {
  const ConnectedFriendsScreen({Key? key}) : super(key: key);

  @override
  State<ConnectedFriendsScreen> createState() => _ConnectedFriendsScreenState();
}

class _ConnectedFriendsScreenState extends State<ConnectedFriendsScreen> {
  CrystullUser? _currentUser;
  int friendCount = 0;
  final TextEditingController _searchController = TextEditingController();
  bool _isShowUsers = false;

  void handleResult(String result) {
    if (result == "Success") {
      setState(() {
        var userProvider = Provider.of<UserProvider>(context, listen: false);
        userProvider.refreshUser();
      });
    } else {
      showSnackBar(result, context);
      log(result);
    }
  }

  @override
  Widget build(BuildContext context) {
    _currentUser = Provider.of<UserProvider>(context).getUser;

    friendCount = 0;
    _currentUser!.connections.forEach((key, value) {
      if (value.status == 3) {
        friendCount++;
      }
    });
    return Scaffold(
      appBar: getAppBar(context, "Your connections"),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          friendCount == 0
              ? Container(
                  height: MediaQuery.of(context).size.height * 0.7,
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  alignment: Alignment.center,
                  child: const Center(
                    child: Text(
                      'Add friends and see them appear here',
                      style: TextStyle(
                        fontFamily: "Poppins",
                        fontSize: 20,
                        color: color808080,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                )
              : Container(
                  decoration: BoxDecoration(
                    color: const Color(0xFFF0F2F5),
                    borderRadius: BorderRadius.circular(30),
                  ),
                  height: getSafeAreaHeight(context) * 0.04,
                  margin:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 5),
                  child: TextFormField(
                    controller: _searchController,
                    onFieldSubmitted: (value) {
                      if (value.isNotEmpty) {
                        setState(
                          () {
                            _isShowUsers = true;
                          },
                        );
                      } else {
                        setState(
                          () {
                            _isShowUsers = false;
                          },
                        );
                      }
                    },
                    style: const TextStyle(color: Colors.black, fontSize: 12),
                    decoration: InputDecoration(
                      hoverColor: const Color(0x00F0F2F5),
                      fillColor: const Color(0x00F0F2F5),
                      contentPadding: const EdgeInsets.symmetric(
                          vertical: 2, horizontal: 16),
                      prefixIcon: SvgPicture.asset(
                        'images/icons/search.svg',
                        color: colorB5B5B5,
                        fit: BoxFit.none,
                        height: 14,
                        width: 14,
                      ),
                      hintText: 'Search from $friendCount connections',
                      hintStyle: const TextStyle(
                        fontFamily: "Poppins",
                        fontSize: 12,
                        height: 1.5,
                        color: colorB5B5B5,
                        fontWeight: FontWeight.w400,
                      ),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(60),
                      ),
                    ),
                  ),
                ),
          ListView(
            shrinkWrap: true,
            children: [
              FutureBuilder<List<CrystullUser>>(
                future: AuthMethods.getConnections(_currentUser!),
                builder: (context, snapshot) {
                  if (snapshot.hasData) {
                    return ListView.builder(
                      shrinkWrap: true,
                      physics: const AlwaysScrollableScrollPhysics(),
                      itemCount:
                          snapshot.data == null ? 0 : snapshot.data!.length,
                      itemBuilder: (context, index) {
                        var doc = snapshot.data![index];
                        Set<String> connectedFriends =
                            Set<String>.from(doc.connections.keys).intersection(
                          Set<String>.from(_currentUser!.connections.keys),
                        );
                        return ListTile(
                          title: InkWell(
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) =>
                                      ProfileScreen(user: doc),
                                ),
                              );
                            },
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                CircleAvatar(
                                  backgroundImage: NetworkImage(
                                      doc.profileImageUrl.toString()),
                                ),
                                const SizedBox(width: 10),
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Wrap(
                                      alignment: WrapAlignment.start,
                                      crossAxisAlignment:
                                          WrapCrossAlignment.start,
                                      children: [
                                        Text(
                                          doc.fullName.capitalize(),
                                          style: const TextStyle(
                                            fontFamily: "Poppins",
                                            fontSize: 12,
                                            height: 1.5,
                                            fontWeight: FontWeight.w600,
                                            color: color808080,
                                          ),
                                        ),
                                        const SizedBox(
                                          width: 5,
                                        ),
                                        if (doc.isVerified)
                                          const Icon(
                                            Icons.verified_rounded,
                                            color: primaryColor,
                                            size: 12,
                                          ),
                                      ],
                                    ),
                                    if (connectedFriends.isNotEmpty)
                                      Row(
                                        children: [
                                          SvgPicture.asset(
                                            'images/icons/otherConnections.svg',
                                            color: color7A7A7A,
                                            width: 12,
                                            height: 9,
                                          ),
                                          const SizedBox(width: 5),
                                          Text(
                                            '${connectedFriends.length} other shared connections',
                                            style: const TextStyle(
                                              fontFamily: "Poppins",
                                              fontSize: 9,
                                              height: 1.5,
                                              fontWeight: FontWeight.w400,
                                              decoration:
                                                  TextDecoration.underline,
                                              color: color7A7A7A,
                                            ),
                                          ),
                                        ],
                                      ),
                                  ],
                                ),
                                const Spacer(),
                                IconButton(
                                  onPressed: () => {
                                    showModalBottomSheet(
                                      context: context,
                                      builder: (BuildContext context) {
                                        return Container(
                                          height:
                                              getSafeAreaHeight(context) * 0.2,
                                          padding: const EdgeInsets.symmetric(
                                              horizontal: 20),
                                          color: mobileBackgroundColor,
                                          child: Center(
                                            child: Column(
                                              mainAxisAlignment:
                                                  MainAxisAlignment.spaceEvenly,
                                              children: [
                                                InkWell(
                                                  onTap: () {
                                                    String message =
                                                        "Are you sure you want to block " +
                                                            doc.firstName
                                                                .capitalize() +
                                                            "?";
                                                    showAlertDialog(
                                                      context,
                                                      "Block " +
                                                          doc.firstName
                                                              .capitalize(),
                                                      message,
                                                      () {},
                                                      () async {
                                                        String res =
                                                            await AuthMethods()
                                                                .addFriendRequest(
                                                                    _currentUser!,
                                                                    doc,
                                                                    4,
                                                                    5);
                                                        handleResult(res);
                                                        Navigator.pop(context);
                                                      },
                                                    );
                                                  },
                                                  child: Row(children: const [
                                                    Icon(
                                                      Icons.block,
                                                      color: color808080,
                                                      size: 20,
                                                    ),
                                                    SizedBox(
                                                      width: 10,
                                                    ),
                                                    Text(
                                                      'Block',
                                                      style: TextStyle(
                                                        fontFamily: "Poppins",
                                                        color: color808080,
                                                        fontSize: 14,
                                                        height: 1.5,
                                                        fontWeight:
                                                            FontWeight.w500,
                                                      ),
                                                    ),
                                                  ]),
                                                ),
                                                InkWell(
                                                  onTap: () {
                                                    String message =
                                                        "Are you sure you want to remove " +
                                                            doc.firstName
                                                                .capitalize() +
                                                            " from your connections?";
                                                    showAlertDialog(
                                                      context,
                                                      "Remove " +
                                                          doc.firstName
                                                              .capitalize(),
                                                      message,
                                                      () {},
                                                      () async {
                                                        String res =
                                                            await AuthMethods()
                                                                .removeFriend(
                                                                    _currentUser!,
                                                                    doc);
                                                        handleResult(res);
                                                        Navigator.pop(context);
                                                      },
                                                    );
                                                  },
                                                  child: Row(
                                                    children: [
                                                      SvgPicture.asset(
                                                        'images/icons/removeFriend.svg',
                                                        color: colorFF3225,
                                                        width: 20,
                                                        height: 20,
                                                      ),
                                                      const SizedBox(
                                                        width: 10,
                                                      ),
                                                      const Text(
                                                        'Remove',
                                                        style: TextStyle(
                                                          fontFamily: "Poppins",
                                                          color: colorFF3225,
                                                          fontSize: 14,
                                                          height: 1.5,
                                                          fontWeight:
                                                              FontWeight.w500,
                                                        ),
                                                      ),
                                                    ],
                                                  ),
                                                )
                                              ],
                                            ),
                                          ),
                                        );
                                      },
                                    )
                                  },
                                  icon: const Icon(
                                    Icons.more_vert,
                                    size: 24,
                                    color: color808080,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    );
                  } else if (snapshot.hasError) {
                    return Text("${snapshot.error}");
                  }
                  return const Center(child: CircularProgressIndicator());
                },
              ),
            ],
          ),
        ],
      ),
    );
  }
}
