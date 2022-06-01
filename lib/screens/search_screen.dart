import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:crystull/resources/models/signup.dart';
import 'package:crystull/screens/profile_screen.dart';
import 'package:crystull/utils/colors.dart';
import 'package:flutter/material.dart';

class SearchScreen extends StatefulWidget {
  const SearchScreen({Key? key}) : super(key: key);

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  final TextEditingController _searchController = TextEditingController();
  bool _isShowUsers = false;

  @override
  void dispose() {
    super.dispose();
    _searchController.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        elevation: 1,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.of(context).pop(),
        ),
        backgroundColor: mobileBackgroundColor,
        centerTitle: false,
        title: Container(
          decoration: BoxDecoration(
            color: Colors.black12,
            borderRadius: BorderRadius.circular(60),
          ),
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
            style: const TextStyle(
              fontFamily: "Poppins",
              fontSize: 12,
              color: Colors.black,
              fontWeight: FontWeight.w400,
            ),
            decoration: InputDecoration(
              contentPadding:
                  const EdgeInsets.symmetric(vertical: 10, horizontal: 16),
              hintText: 'Search people',
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
                    return ListTile(
                      title: InkWell(
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => ProfileScreen(
                                    user: CrystullUser.fromSnapshot(doc))),
                          );
                        },
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            CircleAvatar(
                              backgroundImage: NetworkImage(
                                  doc['profileImageUrl'].toString()),
                            ),
                            const SizedBox(width: 10),
                            Text(
                              (doc['fullName'] as String).capitalize(),
                              style: const TextStyle(
                                fontFamily: "Poppins",
                                fontSize: 14,
                                height: 1.5,
                                fontWeight: FontWeight.w400,
                                color: color808080,
                              ),
                            ),
                            Container(
                              margin: const EdgeInsets.symmetric(horizontal: 4),
                              width: 5,
                              height: 5,
                              decoration: const BoxDecoration(
                                  color: color808080, shape: BoxShape.circle),
                            ),
                            Text(
                              doc['bio'],
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
                            // Flexible(child: Container(), flex: 6),
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
  String capitalize() {
    return "${this[0].toUpperCase()}${substring(1).toLowerCase()}";
  }
}
