import 'dart:developer';

import 'package:crystull/providers/user_provider.dart';
import 'package:crystull/resources/auth_methods.dart';
import 'package:crystull/resources/models/signup.dart';
import 'package:crystull/screens/profile_screen.dart';
import 'package:crystull/screens/search_screen.dart';
import 'package:crystull/utils/utils.dart';
import 'package:flutter/material.dart';
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
    friendCount = 0;
    _currentUser!.connections.forEach((key, value) {
      if (value.status == 3) {
        friendCount++;
      }
    });
    return Scaffold(
        appBar: AppBar(
          backgroundColor: Colors.white,
          elevation: 1,
          centerTitle: false,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back, color: Colors.black),
            onPressed: () => Navigator.of(context).pop(),
          ),
          title: const Text(
            'Your connections',
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
              decoration: BoxDecoration(
                color: Colors.black12,
                borderRadius: BorderRadius.circular(60),
              ),
              height: getSafeAreaHeight(context) * 0.04,
              margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 5),
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
                  hoverColor: const Color(0xFFF0F2F5),
                  fillColor: const Color(0xFFF0F2F5),
                  contentPadding:
                      const EdgeInsets.symmetric(vertical: 2, horizontal: 16),
                  prefixIcon: const Icon(
                    Icons.search,
                    color: Colors.black38,
                    size: 16,
                  ),
                  hintText: 'Search from $friendCount connections',
                  hintStyle: const TextStyle(
                      fontSize: 14,
                      color: Colors.black38,
                      fontWeight: FontWeight.w400),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(60),
                  ),
                ),
              ),
            ),
            friendCount == 0
                ? const Center(
                    child: Text(
                      'Add friends and see them appear here',
                      style: TextStyle(fontSize: 20, color: Colors.black54),
                    ),
                  )
                : ListView(
                    shrinkWrap: true,
                    children: [
                      FutureBuilder<List<CrystullUser>>(
                        future: AuthMethods.getConnections(_currentUser!),
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
