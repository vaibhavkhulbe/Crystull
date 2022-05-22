import 'dart:developer';

import 'package:crystull/providers/user_provider.dart';
import 'package:crystull/resources/auth_methods.dart';
import 'package:crystull/resources/models/signup.dart';
import 'package:crystull/screens/connected_friends_screen.dart';
import 'package:crystull/screens/profile_screen.dart';
import 'package:crystull/screens/search_screen.dart';
import 'package:crystull/utils/utils.dart';
import 'package:crystull/widgets/status_button.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class FriendRequestScreen extends StatefulWidget {
  const FriendRequestScreen({Key? key}) : super(key: key);

  @override
  State<FriendRequestScreen> createState() => _FriendRequestScreenState();
}

class _FriendRequestScreenState extends State<FriendRequestScreen> {
  CrystullUser? _currentUser;
  List<int> friendCount = [0, 0, 0, 0, 0, 0];

  void handleResult(String result) {
    if (result == "Success") {
      setState(() {
        // refreshUser();
      });
    } else {
      showSnackBar(result, context);
      log(result);
    }
  }

  @override
  Widget build(BuildContext context) {
    _currentUser = Provider.of<UserProvider>(context).getUser;
    friendCount = [0, 0, 0, 0, 0, 0];
    _currentUser!.connections.forEach((key, value) {
      friendCount[value.status]++;
    });
    return Scaffold(
        appBar: AppBar(
          backgroundColor: Colors.white,
          elevation: 1,
          centerTitle: false,
          title: const Text(
            'Requests',
            style: TextStyle(
                color: Colors.black87,
                fontSize: 16,
                height: 1.5,
                fontWeight: FontWeight.bold),
          ),
        ),
        body: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              decoration: const BoxDecoration(
                color: Color(0xFFFBFEFF),
              ),
              padding: const EdgeInsets.all(15),
              child: Row(
                children: [
                  const Text(
                    'Connections',
                    style: TextStyle(
                      color: Colors.black,
                      fontSize: 16,
                      height: 1.5,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    ' (${friendCount[3].toString()})',
                    style: const TextStyle(
                      color: Colors.lightBlueAccent,
                      fontSize: 16,
                      height: 1.5,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Flexible(child: Container()),
                  GestureDetector(
                    onTap: () => Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (context) => const ConnectedFriendsScreen(),
                      ),
                    ),
                    child: const Text(
                      "See all",
                      style: TextStyle(
                        color: Colors.black54,
                        fontSize: 14,
                        height: 1.5,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            friendCount[2] == 0
                ? const Center(
                    child: Text('No new requests',
                        style: TextStyle(fontSize: 20, color: Colors.black54)),
                  )
                : ListView(
                    shrinkWrap: true,
                    children: [
                      FutureBuilder<List<CrystullUser>>(
                        future: AuthMethods.getConnections(_currentUser!,
                            status: 2),
                        builder: (context, snapshot) {
                          if (snapshot.hasData) {
                            return ListView.builder(
                              shrinkWrap: true,
                              physics: const NeverScrollableScrollPhysics(),
                              itemCount: snapshot.data == null
                                  ? 0
                                  : snapshot.data!.length,
                              itemBuilder: (context, index) {
                                var doc = snapshot.data![index];
                                Set<String> connectedFriends =
                                    Set<String>.from(doc.connections.keys)
                                        .intersection(Set<String>.from(
                                            _currentUser!.connections.keys));
                                return ListTile(
                                  title: InkWell(
                                    onTap: () {
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                            builder: (context) =>
                                                ProfileScreen(user: doc)),
                                      );
                                    },
                                    child: Row(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        CircleAvatar(
                                          backgroundImage: NetworkImage(
                                              doc.profileImageUrl.toString()),
                                        ),
                                        const SizedBox(width: 10),
                                        Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              doc.fullName.capitalize(),
                                              style: const TextStyle(
                                                fontSize: 14,
                                                height: 1.5,
                                                color: Colors.black54,
                                                fontWeight: FontWeight.bold,
                                              ),
                                            ),
                                            connectedFriends.isNotEmpty
                                                ? Text(
                                                    '${connectedFriends.length} other shared connections',
                                                    style: const TextStyle(
                                                      fontSize: 12,
                                                      height: 1.5,
                                                      decoration: TextDecoration
                                                          .underline,
                                                      color: Colors.black54,
                                                    ),
                                                  )
                                                : Container(),
                                            Text(
                                              doc.bio,
                                              style: const TextStyle(
                                                fontSize: 12,
                                                height: 1.5,
                                                color: Colors.black54,
                                              ),
                                            ),
                                            Row(children: [
                                              getStatusButton(
                                                Colors.white,
                                                Colors.lightBlueAccent,
                                                "Accept",
                                                Colors.lightBlueAccent,
                                                () async {
                                                  String result =
                                                      await AuthMethods()
                                                          .addFriendRequest(
                                                              _currentUser!,
                                                              doc,
                                                              3,
                                                              3);
                                                  handleResult(result);
                                                },
                                                radius: 20.0,
                                                fontSize: 12,
                                                fontWeight: null,
                                              ),
                                              getStatusButton(
                                                Colors.white,
                                                Colors.black54,
                                                "Remove",
                                                Colors.black54,
                                                () async {
                                                  String result =
                                                      await AuthMethods()
                                                          .removeFriend(doc,
                                                              _currentUser!);
                                                  handleResult(result);
                                                },
                                                radius: 20.0,
                                                fontSize: 12,
                                                fontWeight: null,
                                              )
                                            ]),
                                          ],
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
                          return const Center(
                              child: CircularProgressIndicator());
                        },
                      ),
                    ],
                  ),
          ],
        ));
  }
}
