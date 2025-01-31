import 'dart:developer';
import 'dart:typed_data';

import 'package:carousel_slider/carousel_slider.dart';
import 'package:crystull/resources/auth_methods.dart';
import 'package:crystull/resources/drawer_list.dart';
import 'package:crystull/resources/models/signup.dart';
import 'package:crystull/resources/models/weekly_attributes.dart';
import 'package:crystull/screens/profile_screen.dart';
import 'package:crystull/screens/search_screen.dart';
import 'package:crystull/utils/colors.dart';
import 'package:crystull/utils/utils.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:flutter_svg_provider/flutter_svg_provider.dart' as svg;
import 'package:provider/provider.dart';

import '../providers/user_provider.dart';
import '../resources/storage_methods.dart';

class HomeScreen extends StatefulWidget {
  CrystullUser user;
  HomeScreen({Key? key, required this.user}) : super(key: key);

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  late final Future<WeeklyAttributes> weeklyAttributes;
  int _current = 0;
  bool isloading = false;
  Map<String, double> _swapValues = {};
  final CarouselController _controller = CarouselController();
  List<String> imgList = ['images/home/1.png', 'images/home/2.png'];
  List<Uint8List> images = [];
  bool loadingWeeklyAttributes = true;

  @override
  initState() {
    super.initState();
    weeklyAttributes = AuthMethods().getWeeklyUserWiseAttributes(widget.user);
    getImagesFromServer();
  }

  @override
  void dispose() {
    super.dispose();
  }

  void getImagesFromServer() async {
    setState(() {
      isloading = true;
    });

    UserProvider userProvider =
        Provider.of<UserProvider>(context, listen: false);
    await userProvider.refreshUser();
    images = await StorageMethods().downloadAllImage("homePics");
    setState(() {
      isloading = false;
    });
  }

  // this is the image slider for home screen images
  sliderPlugin(images, double height) {
    return CarouselSlider(
      options: CarouselOptions(
        height: height,
        viewportFraction: 1.0,
        enlargeCenterPage: false,
        onPageChanged: (position, reason) {
          setState(
            () {
              _current = position;
            },
          );
        },
        enableInfiniteScroll: false,
      ),
      items: images.map<Widget>((i) {
        return Builder(
          builder: (BuildContext context) {
            return Container(
              width: MediaQuery.of(context).size.width,
              decoration: BoxDecoration(
                image: DecorationImage(
                  image: i.runtimeType == String
                      ? AssetImage(i)
                      : Image.memory(i).image,
                ),
              ),
            );
          },
        );
      }).toList(),
    );
  }

  @override
  Widget build(BuildContext context) {
    AuthMethods()
        .getCombinedAttributes(widget.user.uid)
        .then((value) => _swapValues = value.attributes);
    return Scaffold(
      drawer: SizedBox(
        width: MediaQuery.of(context).size.width * 0.6,
        child: Drawer(
          backgroundColor: mobileBackgroundColor,
          child: ListView(
              children: getDrawerList(context, widget.user, _swapValues)),
        ),
      ),
      appBar: AppBar(
        elevation: 1,
        backgroundColor: mobileBackgroundColor,
        leading: Builder(
          builder: (BuildContext context) {
            return IconButton(
              icon: SvgPicture.asset(
                'images/icons/drawer.svg',
                color: Colors.black54,
              ),
              onPressed: () {
                Scaffold.of(context).openDrawer();
              },
              tooltip: MaterialLocalizations.of(context).openAppDrawerTooltip,
            );
          },
        ),
      ),
      backgroundColor: const Color.fromRGBO(0, 0, 0, 0.04),
      body: Container(
        decoration: const BoxDecoration(color: colorEEEEEE),
        child: ListView(
          children: [
            if (isloading)
              SizedBox(
                height: getSafeAreaHeight(context) * 0.5,
                width: getSafeAreaWidth(context),
                child: const Center(
                  child: CircularProgressIndicator(
                    color: primaryColor,
                    backgroundColor: mobileBackgroundColor,
                  ),
                ),
              ),
            if (!isloading)
              Stack(
                children: [
                  sliderPlugin(images.isEmpty ? imgList : images,
                      getSafeAreaHeight(context) * 0.5),
                  Positioned(
                    left: getSafeAreaWidth(context) * 0.5,
                    bottom: getSafeAreaHeight(context) * 0.06,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: (images.isEmpty ? imgList : images)
                          .asMap()
                          .entries
                          .map(
                        (entry) {
                          return GestureDetector(
                            onTap: () => _controller.animateToPage(entry.key),
                            child: Container(
                              width: 6.0,
                              height: 6.0,
                              margin: const EdgeInsets.symmetric(
                                  vertical: 8.0, horizontal: 4.0),
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: _current == entry.key
                                    ? primaryColor
                                    : Colors.black54,
                              ),
                            ),
                          );
                        },
                      ).toList(),
                    ),
                  )
                ],
              ),

            // this is the trending users section
            Container(
              padding: const EdgeInsets.all(8),
              width: getSafeAreaWidth(context),
              decoration: const BoxDecoration(
                color: mobileBackgroundColor,
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    "Trending Crystullites of the week",
                    style: TextStyle(
                      fontFamily: "Poppins",
                      color: color575757,
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  FutureBuilder<WeeklyAttributes>(
                    future: weeklyAttributes,
                    builder: (context, snapshot) {
                      if (snapshot.hasData) {
                        List<Map<String, dynamic>> attributes =
                            snapshot.data != null
                                ? snapshot.data!.attributes.values.toList()
                                : [];
                        Map<String, CrystullUser> users =
                            snapshot.data != null ? snapshot.data!.users : {};
                        return ListView.builder(
                            shrinkWrap: true,
                            physics: const NeverScrollableScrollPhysics(),
                            itemCount:
                                snapshot.data == null ? 0 : attributes.length,
                            itemBuilder: (context, index) {
                              var doc = attributes[index];
                              return ListTile(
                                title: InkWell(
                                  onTap: () {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) => ProfileScreen(
                                            user: users[doc['uid']]!),
                                      ),
                                    );
                                  },
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(
                                        vertical: 15, horizontal: 5),
                                    child: Row(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.center,
                                      children: [
                                        SvgPicture.asset(
                                          "images/icons/trending.svg",
                                          height: 14,
                                          width: 14,
                                        ),
                                        const SizedBox(width: 10),
                                        CircleAvatar(
                                            backgroundImage: FadeInImage(
                                          placeholder: Image.asset(
                                            'images/avatar.png',
                                          ).image,
                                          image: users[doc['uid']]!
                                                      .profileImage !=
                                                  null
                                              ? Image.memory(
                                                  users[doc['uid']]!
                                                      .profileImage!,
                                                ).image
                                              : Image.asset('images/avatar.png')
                                                  .image,
                                        ).image),
                                        const SizedBox(width: 10),
                                        Expanded(
                                          child: Wrap(
                                            children: [
                                              Text(
                                                users[doc['uid']]!
                                                    .firstName
                                                    .capitalize(),
                                                style: const TextStyle(
                                                  fontSize: 12,
                                                  height: 1.5,
                                                  color: color808080,
                                                  fontWeight: FontWeight.w500,
                                                ),
                                              ),
                                              const Text(
                                                " trending in ",
                                                style: TextStyle(
                                                  fontSize: 12,
                                                  height: 1.5,
                                                  color: color808080,
                                                  fontWeight: FontWeight.w500,
                                                ),
                                              ),
                                              Text(
                                                doc['attribute'],
                                                style: const TextStyle(
                                                  fontSize: 12,
                                                  height: 1.5,
                                                  color: color808080,
                                                  fontWeight: FontWeight.w500,
                                                ),
                                              ),
                                              const Text(
                                                " attribute",
                                                style: TextStyle(
                                                  fontSize: 12,
                                                  height: 1.5,
                                                  color: color808080,
                                                  fontWeight: FontWeight.w500,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              );
                            });
                      } else if (snapshot.hasError) {
                        return Text("${snapshot.error}");
                      }

                      return const Center(child: CircularProgressIndicator());
                    },
                  )
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
