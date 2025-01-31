import 'dart:async';
import 'dart:typed_data';

import 'package:crystull/resources/auth_methods.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:crystull/resources/models/signup.dart';
import 'package:crystull/resources/storage_methods.dart';
import 'package:crystull/screens/profile_screen.dart';
import 'package:crystull/utils/colors.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/user_provider.dart';
import '../utils/utils.dart';

class Debouncer {
  final int milliseconds;
  VoidCallback? action;
  Timer? _timer;

  Debouncer({required this.milliseconds});

  run(VoidCallback action) {
    if (_timer != null) {
      _timer!.cancel();
    }
    _timer = Timer(Duration(milliseconds: milliseconds), action);
  }
}

class SearchScreen extends StatefulWidget {
  CrystullUser user;
  SearchScreen({Key? key, required this.user}) : super(key: key);

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  final StorageMethods _storageMethods = StorageMethods();
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final TextEditingController _searchController = TextEditingController();
  bool _isShowUsers = false;
  final _debouncer = Debouncer(milliseconds: 500);

  @override
  void initState() {
    super.initState();
    refreshUser();
  }

  @override
  void dispose() {
    super.dispose();
    _searchController.dispose();
  }

  void refreshUser() async {
    UserProvider userProvider =
        Provider.of<UserProvider>(context, listen: false);
    await userProvider.refreshUser();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        elevation: 1,
        automaticallyImplyLeading: false,
        backgroundColor: mobileBackgroundColor,
        centerTitle: false,
        title: Container(
          decoration: BoxDecoration(
            color: const Color(0xF0F2F5FF),
            borderRadius: BorderRadius.circular(60),
          ),
          child: TextFormField(
            controller: _searchController,
            onChanged: (value) {
              _debouncer.run(() {
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
              });
            },
            style: const TextStyle(
              fontFamily: "Poppins",
              fontSize: 14,
              color: Colors.black,
              fontWeight: FontWeight.w400,
            ),
            decoration: InputDecoration(
                contentPadding:
                    const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
                hintText: 'Search people',
                hintStyle: const TextStyle(
                  fontFamily: "Poppins",
                  fontSize: 14,
                  height: 1.5,
                  color: colorB5B5B5,
                  fontWeight: FontWeight.w400,
                ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(60),
                ),
                suffixIcon: IconButton(
                  icon: Icon(
                    Icons.close_rounded,
                    color: colorBCBCBC,
                    size: MediaQuery.of(context).size.height * 0.02,
                  ),
                  onPressed: () {
                    // Update the state i.e. toogle the state of passwordVisible variable
                    setState(() {
                      _searchController.text = "";
                    });
                  },
                )),
          ),
        ),
      ),
      body: _isShowUsers && _searchController.text.isNotEmpty
          ? FutureBuilder(
              future: FirebaseFirestore.instance
                  .collection("users")
                  .where('fullName',
                      isGreaterThanOrEqualTo:
                          _searchController.text.toLowerCase(),
                      isLessThanOrEqualTo:
                          _searchController.text.toLowerCase() + '\uf8ff')
                  .get(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(
                    child: CircularProgressIndicator(
                      color: primaryColor,
                    ),
                  );
                } else if (!snapshot.hasData) {
                  return const Center(
                    child: Text(
                      'No data',
                      style: TextStyle(
                        fontFamily: "Poppins",
                        fontSize: 20,
                        color: color808080,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  );
                }
                return ListView.builder(
                  itemCount: (snapshot.data! as dynamic).docs.length,
                  itemBuilder: (context, index) {
                    final DocumentSnapshot doc =
                        (snapshot.data! as dynamic).docs[index];
                    final searchedUser = CrystullUser.fromSnapshot(doc);
                    if (searchedUser.profileImageUrl.isNotEmpty &&
                        searchedUser.profileImage == null) {
                      StorageMethods()
                          .downloadUserImage("profilePics", searchedUser.uid)
                          .then((imgvalue) =>
                              compressList(imgvalue!).then((value) {
                                searchedUser.profileImage = value;
                                _firestore
                                    .collection('users')
                                    .doc(searchedUser.uid)
                                    .update({"profileImage": value});
                              }));
                    }
                    return ListTile(
                      title: InkWell(
                        onTap: () {
                          // !isUnblocked(CrystullUser.fromSnapshot(doc), )
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) =>
                                    ProfileScreen(user: searchedUser)),
                          );
                        },
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            searchedUser.profileImage != null &&
                                    isUnblocked(searchedUser, widget.user)
                                ? CircleAvatar(
                                    backgroundImage:
                                        Image.memory(searchedUser.profileImage!)
                                            .image,
                                  )
                                : CircleAvatar(
                                    backgroundImage:
                                        Image.asset('images/avatar.png').image,
                                  ),
                            const SizedBox(width: 10),
                            Wrap(
                              alignment: WrapAlignment.start,
                              crossAxisAlignment: WrapCrossAlignment.start,
                              children: [
                                Text(
                                  searchedUser.fullName.capitalize(),
                                  style: const TextStyle(
                                    fontFamily: "Poppins",
                                    fontSize: 14,
                                    height: 1.5,
                                    fontWeight: FontWeight.w400,
                                    color: color808080,
                                  ),
                                ),
                                const SizedBox(
                                  width: 5,
                                ),
                                if (searchedUser.isVerified)
                                  const Icon(
                                    Icons.verified_rounded,
                                    color: primaryColor,
                                    size: 12,
                                  ),
                              ],
                            ),
                            Container(
                              margin: const EdgeInsets.symmetric(horizontal: 4),
                              width: 5,
                              height: 5,
                              decoration: const BoxDecoration(
                                  color: color808080, shape: BoxShape.circle),
                            ),
                            Text(
                              searchedUser.bio,
                              strutStyle:
                                  const StrutStyle(forceStrutHeight: true),
                              style: const TextStyle(
                                fontFamily: "Poppins",
                                fontSize: 10,
                                height: 1.5,
                                fontWeight: FontWeight.w400,
                                color: color808080,
                              ),
                            ),
                            // const Spacer( flex: 6),
                          ],
                        ),
                      ),
                    );
                  },
                );
              },
            )
          : const Center(
              child: Text(
                'Enter a user name to search',
                style: TextStyle(
                  fontFamily: "Poppins",
                  fontSize: 20,
                  color: color808080,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
    );
  }
}

extension StringExtension on String {
  String capitalize() => replaceAll(RegExp(' +'), ' ')
      .split(' ')
      .map((str) => str.isNotEmpty
          ? "${str[0].toUpperCase()}${str.substring(1).toLowerCase()}"
          : str)
      .join(' ');
}
