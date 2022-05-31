import 'dart:developer' as developer;
import 'dart:math';
import 'dart:typed_data';

import 'package:crystull/providers/user_provider.dart';
import 'package:crystull/resources/auth_methods.dart';
import 'package:crystull/resources/models/signup.dart';
import 'package:crystull/screens/connected_friends_screen.dart';
import 'package:crystull/screens/edit_profile.dart';
import 'package:flutter_svg_provider/flutter_svg_provider.dart' as svg;
import 'package:crystull/utils/colors.dart';
import 'package:crystull/utils/utils.dart';
import 'package:crystull/widgets/attribute_grid.dart';
import 'package:crystull/widgets/slider_grid.dart';
import 'package:crystull/widgets/status_button.dart';
import 'package:flutter/material.dart';
import 'package:crystull/screens/search_screen.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import 'package:multi_select_flutter/multi_select_flutter.dart';

const List<String> primaryAttributes = [
  'Personality',
  'Behaviour',
  'Communication',
  'Empathy',
  'Character',
  'Welfare',
];

const List<String> otherAttributes = [
  "Professional Skill",
  "Creativity",
  "Optimism",
  "Leadership",
  "Integrity",
  "Courage",
  "Humour",
  "Loyalty",
  "Enthusiasm",
  "Problem solving",
  "Imagination",
  "Ambitious",
  "Patience",
  "Resilience"
];

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
  bool _loadingPage = true;
  bool isAnonymousPost = false;
  bool _isSwapping = false;
  bool _isUpdatingCoverPhoto = false;
  bool _isUpdatingProfilePic = false;
  bool isSwapEnabled = false;
  CrystullUser? _currentUser;
  List<CrystullUser> connectedUsers = [];
  Map<String, double> _swapValues = {};
  final Map<String, double> _topSwapValues = {};
  final Map<String, double> _primarySwapValues = {};
  final Map<String, double> _moreSwapValues = {};

  @override
  void initState() {
    super.initState();
    sliderValues = {for (var attribute in primaryAttributes) attribute: 0.0};
    refreshUser();
  }

  @override
  void dispose() {
    super.dispose();
  }

  void handleResult(String result, {bool isLoading = true}) {
    if (result == "Success") {
      setState(() {
        refreshUser(isLoading: isLoading);
      });
    } else {
      showSnackBar(result, context);
      developer.log(result);
    }
  }

  Future<Uint8List?> selectImage() async {
    Uint8List? _image = await pickImage(ImageSource.gallery);
    Uint8List _compressedImage;
    if (_image != null) {
      _compressedImage = await compressList(_image);
      return _compressedImage;
    }
    return null;
  }

  void updateProfilePic() async {
    setState(() {
      _isUpdatingProfilePic = true;
    });
    Uint8List? image = await selectImage();
    if (image != null) {
      var result = await AuthMethods().updateProfilePic(image: image);
      handleResult(result, isLoading: false);
    }
    if (mounted) {
      setState(() {
        _isUpdatingProfilePic = false;
      });
    }
  }

  void updateCoverPic() async {
    setState(() {
      _isUpdatingCoverPhoto = true;
    });
    Uint8List? image = await selectImage();
    if (image != null) {
      var result = await AuthMethods().updateCoverPic(image: image);
      handleResult(result, isLoading: false);
    }
    if (mounted) {
      setState(() {
        _isUpdatingCoverPhoto = false;
      });
    }
  }

  swapUser() async {
    setState(() {
      isSwapEnabled = false;
      _isSwapping = true;
    });
    String res = await AuthMethods().swapUser(
      widget.user.uid,
      widget.user.firstName,
      _currentUser!.uid,
      _currentUser!.firstName,
      sliderValues,
      isAnonymousPost,
    );
    if (res == "Success") {
      showSnackBar("Used SWAPed Successfully", context);
    } else {
      showSnackBar("SWAPing failed. Please try again", context);
    }
    setState(() {
      sliderValues = {for (var attribute in primaryAttributes) attribute: 0.0};
      _isSwapping = false;
      isAnonymousPost = false;
      refreshUser();
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

  void refreshUser({bool isLoading = true}) async {
    setState(() {
      _loadingPage = isLoading;
    });
    UserProvider userProvider =
        Provider.of<UserProvider>(context, listen: false);
    await userProvider.refreshUser();

    if (_currentUser!.uid != widget.user.uid) {
      CrystullUser updatedUser = await AuthMethods().refreshUser(widget.user);
      widget.user = updatedUser;
    } else {
      widget.user = userProvider.getUser!;
    }

    _swapValues =
        await AuthMethods().getCombinedAttributes(widget.user.uid) ?? {};

    var mapEntries = _swapValues.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));

    _topSwapValues
      ..clear()
      ..addEntries(mapEntries.sublist(0, min(3, mapEntries.length)));

    _primarySwapValues.clear();
    _moreSwapValues.clear();

    _swapValues.forEach((key, value) {
      if (primaryAttributes.contains(key)) {
        _primarySwapValues[key] = value;
      } else {
        _moreSwapValues[key] = value;
      }
    });

    if (widget.user.uid != _currentUser!.uid) {
      popUpMenuItems.clear();
      int connectionStatus = 0;
      Friend? connectionState = widget.user.connections[_currentUser!.uid];
      if (connectionState != null) {
        connectionStatus = connectionState.status;
      }
      if (connectionStatus <= 3) {
        popUpMenuItems['Block'] = Row(
          children: const [
            Icon(
              Icons.block,
              color: color808080,
              size: 20,
            ),
            SizedBox(
              width: 5,
            ),
            Text(
              'Block',
              style: TextStyle(
                fontFamily: "Poppins",
                color: color808080,
                fontSize: 14,
              ),
            ),
          ],
        );
      } else if (connectionStatus == 5) {
        popUpMenuItems['Unblock'] = Row(
          children: const [
            Icon(
              Icons.check_circle,
              color: color808080,
              size: 20,
            ),
            SizedBox(
              width: 5,
            ),
            Text(
              'Unblock',
              style: TextStyle(
                fontFamily: "Poppins",
                color: color808080,
                fontSize: 14,
              ),
            ),
          ],
        );
      }
      if (connectionStatus == 3) {
        popUpMenuItems['Remove'] = Row(
          children: [
            SvgPicture.asset(
              'images/icons/removeFriend.svg',
              color: const Color(0xFFFF3225),
              width: 20,
              height: 20,
            ),
            const SizedBox(
              width: 5,
            ),
            const Text(
              'Remove',
              style: TextStyle(
                fontFamily: "Poppins",
                color: Color(0xFFFF3225),
                fontSize: 14,
              ),
            ),
          ],
        );
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
    if (mounted) {
      setState(() {
        _loadingPage = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    _currentUser = Provider.of<UserProvider>(context).getUser;

    bool isMe = _currentUser!.uid == widget.user.uid;
    return _loadingPage
        ? Center(
            child: Container(
              width: getSafeAreaWidth(context),
              color: Colors.white,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const CircularProgressIndicator(
                    color: primaryColor,
                    backgroundColor: Colors.white,
                  ),
                  const SizedBox(
                    height: 10,
                  ),
                  isMe
                      ? const Text(
                          'Loading Profile. Please Wait.',
                          style: TextStyle(
                            color: Colors.black87,
                            fontSize: 14,
                          ),
                        )
                      : SvgPicture.asset(
                          'images/crystull_logo.svg',
                          color: primaryColor,
                          width: getSafeAreaWidth(context) * 0.5,
                          height: getSafeAreaHeight(context) * 0.05,
                        ),
                ],
              ),
            ),
          )
        : Scaffold(
            appBar: !widget.isHome
                ? AppBar(
                    elevation: 1,
                    backgroundColor: Colors.white,
                    iconTheme: const IconThemeData(
                      color: Colors.black,
                    ),
                  )
                : null,
            body: Container(
              decoration: const BoxDecoration(color: Color(0xFFEEEEEE)),
              child: ListView(
                children: [
                  // Card for the profile. Could be self or others
                  Card(
                    elevation: 0,
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
                              _isUpdatingCoverPhoto
                                  ? Container(
                                      alignment: Alignment.center,
                                      height:
                                          MediaQuery.of(context).size.height *
                                              0.05,
                                      child: const CircularProgressIndicator(
                                        color: primaryColor,
                                        backgroundColor: Colors.white,
                                      ),
                                    )
                                  : widget.user.coverImageUrl.isNotEmpty
                                      ? FadeInImage(
                                          placeholder: const svg.Svg(
                                              'images/crystull_logo.svg'),
                                          image: NetworkImage(
                                            widget.user.coverImageUrl,
                                          ),
                                          alignment: Alignment.topLeft,
                                          fit: BoxFit.fitWidth,
                                          height: MediaQuery.of(context)
                                                  .size
                                                  .height *
                                              0.1,
                                          width: getSafeAreaWidth(context),
                                        )
                                      : SvgPicture.asset(
                                          'images/crystull_logo.svg',
                                          alignment: Alignment.topLeft,
                                          fit: BoxFit.fitWidth,
                                          height: MediaQuery.of(context)
                                                  .size
                                                  .height *
                                              0.1,
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
                                        onTap: () async => updateCoverPic(),
                                        child: Container(
                                          padding: const EdgeInsets.symmetric(
                                              horizontal: 5),
                                          decoration: BoxDecoration(
                                            borderRadius:
                                                const BorderRadius.all(
                                              Radius.circular(1.71),
                                            ),
                                            border: Border.all(
                                              color: Colors.white,
                                              width: 0.5,
                                            ),
                                            color:
                                                Colors.white.withOpacity(0.5),
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
                                                    fontFamily: "Poppins",
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
                                child: _isUpdatingProfilePic
                                    ? Container(
                                        width: getSafeAreaWidth(context) * 0.25,
                                        height:
                                            getSafeAreaWidth(context) * 0.25,
                                        decoration: const BoxDecoration(
                                          shape: BoxShape.circle,
                                          color: Colors.white,
                                        ),
                                        child: const CircularProgressIndicator(
                                          color: primaryColor,
                                          backgroundColor: Colors.white,
                                        ),
                                      )
                                    : Container(
                                        width: getSafeAreaWidth(context) * 0.25,
                                        height:
                                            getSafeAreaWidth(context) * 0.25,
                                        decoration: BoxDecoration(
                                          shape: BoxShape.circle,
                                          color: Colors.black54,
                                          image: DecorationImage(
                                            fit: BoxFit.cover,
                                            image: widget.user.profileImageUrl
                                                    .isNotEmpty
                                                ? FadeInImage(
                                                    placeholder: const svg.Svg(
                                                        'images/avatar.png'),
                                                    image: NetworkImage(
                                                      widget
                                                          .user.profileImageUrl,
                                                    ),
                                                    alignment:
                                                        Alignment.topLeft,
                                                    fit: BoxFit.fitWidth,
                                                    height:
                                                        MediaQuery.of(context)
                                                                .size
                                                                .height *
                                                            0.1,
                                                    width: getSafeAreaWidth(
                                                        context),
                                                  ).image
                                                : const ExactAssetImage(
                                                    'images/avatar.png'),
                                          ),
                                          border: Border.all(
                                            color: Colors.white,
                                            width: 2.0,
                                          ),
                                        ),
                                      ),
                              ),

                              Positioned(
                                top: MediaQuery.of(context).size.height * 0.15,
                                left: MediaQuery.of(context).size.width * 0.135,
                                child: Container(
                                  padding:
                                      const EdgeInsets.symmetric(vertical: 2.5),
                                  width: getSafeAreaWidth(context) * 0.08,
                                  height: getSafeAreaWidth(context) * 0.08,
                                  decoration: BoxDecoration(
                                      shape: BoxShape.circle,
                                      color: Colors.white,
                                      border: Border.all(
                                        color: primaryColor,
                                        width: 1,
                                      )),
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    crossAxisAlignment:
                                        CrossAxisAlignment.center,
                                    children: [
                                      Text(
                                        _swapValues.isEmpty
                                            ? '0'
                                            : (_swapValues.values.reduce(
                                                        (value, element) =>
                                                            value + element) /
                                                    (_swapValues.values.length *
                                                        10))
                                                .round()
                                                .toString(),
                                        style: const TextStyle(
                                          fontFamily: "Poppins",
                                          fontSize: 10,
                                          height: 1.5,
                                          fontWeight: FontWeight.w600,
                                          color: primaryColor,
                                        ),
                                      ),
                                      const Text(
                                        "SWAP",
                                        style: TextStyle(
                                          fontFamily: "Poppins",
                                          fontSize: 6,
                                          height: 1.5,
                                          fontWeight: FontWeight.w400,
                                          color: primaryColor,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),

                              // edit profile photo
                              Positioned(
                                top: MediaQuery.of(context).size.height * 0.07,
                                left: MediaQuery.of(context).size.width * 0.24,
                                child: InkWell(
                                  child: SvgPicture.asset(
                                    "images/icons/editPhoto.svg",
                                    color: Colors.white,
                                    height: 26,
                                    width: 26,
                                  ),
                                  onTap: () async => updateProfilePic(),
                                ),
                              ),

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
                                            fontFamily: "Poppins",
                                            color: color575757,
                                            fontSize: 12,
                                            height: 1.5,
                                            fontWeight: FontWeight.w600,
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
                                            fontFamily: "Poppins",
                                            color: color808080,
                                            fontSize: 9,
                                            height: 1.5,
                                            fontWeight: FontWeight.w400,
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
                                                    (widget.user.degree
                                                            .isNotEmpty
                                                        ? widget.user.degree
                                                        : "") +
                                                    " at " +
                                                    widget.user.college,
                                                style: const TextStyle(
                                                  fontFamily: "Poppins",
                                                  color: color808080,
                                                  fontSize: 9,
                                                  height: 1.5,
                                                  fontWeight: FontWeight.w400,
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
                                                                user: widget
                                                                    .user),
                                                      ));
                                                  setState(() {});
                                                },
                                                child: const Text(
                                                  "Edit Profile",
                                                  style: TextStyle(
                                                    fontFamily: "Poppins",
                                                    color: color808080,
                                                    fontSize: 8,
                                                    height: 1.5,
                                                    fontWeight: FontWeight.w600,
                                                  ),
                                                ),
                                              ),
                                            ],
                                          )
                                        : Wrap(
                                            children: [
                                              getProfileButton(
                                                  _currentUser!, widget.user)!
                                            ],
                                          )
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
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),

                  // Card for showing the attributes
                  isMe ||
                          (widget.user.connections[_currentUser!.uid] != null &&
                              widget.user.connections[_currentUser!.uid]!
                                      .status ==
                                  3)
                      ? Card(
                          elevation: 0,
                          color: Colors.white,
                          shape: const ContinuousRectangleBorder(),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Container(
                                margin: const EdgeInsets.only(top: 10),
                                padding: const EdgeInsets.all(10),
                                child: const Text(
                                  "Primary Attributes",
                                  style: TextStyle(
                                      fontFamily: "Poppins",
                                      fontSize: 14,
                                      height: 1.5,
                                      fontWeight: FontWeight.w600,
                                      color: color575757),
                                ),
                              ),
                              _primarySwapValues.isNotEmpty
                                  ? getAttributesGridFromValues(
                                      _primarySwapValues, context)
                                  : Container(
                                      alignment: Alignment.center,
                                      margin: const EdgeInsets.only(bottom: 10),
                                      child: const Text(
                                        "The user has not been swapped with primary attributes yet.",
                                        style: TextStyle(
                                            fontSize: 12,
                                            color: Colors.black54),
                                      ),
                                    ),
                              Container(
                                margin: const EdgeInsets.only(top: 10),
                                padding: const EdgeInsets.all(10),
                                child: const Text(
                                  "More Attributes",
                                  style: TextStyle(
                                      fontFamily: "Poppins",
                                      fontSize: 14,
                                      height: 1.5,
                                      fontWeight: FontWeight.w600,
                                      color: color575757),
                                ),
                              ),
                              _moreSwapValues.isNotEmpty
                                  ? getAttributesGridFromValues(
                                      _moreSwapValues, context)
                                  : Container(
                                      alignment: Alignment.center,
                                      margin: const EdgeInsets.only(bottom: 10),
                                      child: const Text(
                                        "The user has not been swapped with other attributes yet.",
                                        style: TextStyle(
                                            fontSize: 12,
                                            color: Colors.black54),
                                      ),
                                    ),
                            ],
                          ))
                      : Card(
                          elevation: 0,
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
                                    fontFamily: "Poppins",
                                    fontSize: 14,
                                    height: 1.5,
                                    fontWeight: FontWeight.w500,
                                    color: color808080,
                                  ),
                                ),
                                getAttributesGridFromValues(
                                    _topSwapValues, context),
                                const Center(
                                  child: Text(
                                    "Send connection request to see all attributes",
                                    style: TextStyle(
                                        fontFamily: "Poppins",
                                        fontSize: 10,
                                        height: 1.5,
                                        fontWeight: FontWeight.w400,
                                        color: color808080,
                                        fontStyle: FontStyle.italic),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),

                  // Card for showing the connections or to post the SWAP
                  isMe
                      ? Card(
                          elevation: 0,
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
                                    fontFamily: "Poppins",
                                    fontSize: 14,
                                    height: 1.5,
                                    fontWeight: FontWeight.w600,
                                    color: color575757,
                                  ),
                                ),
                                Row(
                                  children: [
                                    Text(
                                      connectedUsers.length.toString() +
                                          " Connections",
                                      style: const TextStyle(
                                        fontFamily: "Poppins",
                                        fontSize: 8,
                                        height: 1.5,
                                        fontWeight: FontWeight.w400,
                                        color: color808080,
                                      ),
                                    ),
                                    Flexible(child: Container()),
                                    GestureDetector(
                                      onTap: () {
                                        Navigator.push(
                                            context,
                                            MaterialPageRoute(
                                              builder: (context) =>
                                                  const ConnectedFriendsScreen(),
                                            ));
                                      },
                                      child: const Text(
                                        "See all",
                                        style: TextStyle(
                                          fontFamily: "Poppins",
                                          fontSize: 8,
                                          height: 1.5,
                                          fontWeight: FontWeight.w400,
                                          color: primaryColor,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                                GridView(
                                  shrinkWrap: true,
                                  padding:
                                      const EdgeInsets.symmetric(vertical: 10),
                                  gridDelegate:
                                      const SliverGridDelegateWithFixedCrossAxisCount(
                                    crossAxisCount: 4,
                                    childAspectRatio: 0.6,
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
                                                  image: FadeInImage(
                                                    placeholder: const svg.Svg(
                                                        'images/avatar.png'),
                                                    image: NetworkImage(
                                                      connectedUsers[i]
                                                          .profileImageUrl,
                                                    ),
                                                    alignment:
                                                        Alignment.topLeft,
                                                    fit: BoxFit.fitWidth,
                                                    height:
                                                        MediaQuery.of(context)
                                                                .size
                                                                .height *
                                                            0.1,
                                                    width: getSafeAreaWidth(
                                                        context),
                                                  ).image,
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
                                                    fontFamily: "Poppins",
                                                    fontSize: 12,
                                                    height: 1.5,
                                                    fontWeight: FontWeight.w500,
                                                    color: color575757,
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ],
                                        ),
                                      ),
                                  ],
                                ),
                              ],
                            ),
                          ))
                      : Card(
                          elevation: 0,
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
                                    fontFamily: "Poppins",
                                    fontSize: 14,
                                    height: 1.5,
                                    fontWeight: FontWeight.w500,
                                    color: color808080,
                                  ),
                                ),
                                Row(
                                  children: [
                                    const Text(
                                      "SWAP anonymously",
                                      style: TextStyle(
                                        fontFamily: "Poppins",
                                        fontSize: 13,
                                        height: 1.5,
                                        fontWeight: FontWeight.w400,
                                        color: color808080,
                                      ),
                                    ),
                                    Flexible(child: Container()),
                                    Switch(
                                      activeColor: primaryColor,
                                      inactiveTrackColor: secondaryColor,
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
                                GridView(
                                    shrinkWrap: true,
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
                                Container(
                                  alignment: Alignment.topRight,
                                  child: GestureDetector(
                                    onTap: () {
                                      _showMultiSelect(context);
                                      setState(() {});
                                    },
                                    child: const Text(
                                      "+ More",
                                      style: TextStyle(
                                          fontSize: 13, color: primaryColor),
                                    ),
                                  ),
                                ),
                                Center(
                                  child: isSwapEnabled
                                      ? _isSwapping
                                          ? Container(
                                              alignment: Alignment.center,
                                              padding:
                                                  const EdgeInsets.symmetric(
                                                      vertical: 8),
                                              margin: const EdgeInsets.only(
                                                  top: 40, bottom: 20),
                                              decoration: const BoxDecoration(
                                                  color: primaryColor),
                                              width: getSafeAreaWidth(context) *
                                                  0.25,
                                              child:
                                                  const CircularProgressIndicator(
                                                strokeWidth: 2,
                                                color: Colors.white,
                                              ),
                                            )
                                          : InkWell(
                                              onTap: () {
                                                swapUser();
                                              },
                                              child: Container(
                                                alignment: Alignment.center,
                                                padding:
                                                    const EdgeInsets.symmetric(
                                                        vertical: 8),
                                                margin: const EdgeInsets.only(
                                                    top: 40, bottom: 20),
                                                decoration: const BoxDecoration(
                                                    color: primaryColor),
                                                width:
                                                    getSafeAreaWidth(context) *
                                                        0.25,
                                                child: const Text(
                                                  "SWAP",
                                                  style: TextStyle(
                                                    fontSize: 12,
                                                    fontWeight: FontWeight.bold,
                                                  ),
                                                ),
                                              ),
                                            )
                                      : Container(
                                          alignment: Alignment.center,
                                          padding: const EdgeInsets.symmetric(
                                              vertical: 8),
                                          margin: const EdgeInsets.only(
                                              top: 40, bottom: 20),
                                          decoration: BoxDecoration(
                                            color:
                                                primaryColor.withOpacity(0.5),
                                          ),
                                          width:
                                              getSafeAreaWidth(context) * 0.25,
                                          child: const Text(
                                            "SWAP",
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
          primaryColor,
          primaryColor,
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
            getStatusButton(primaryColor, primaryColor, "Accept", Colors.white,
                () async {
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
                    color: primaryColor),
                const SizedBox(width: 5),
                const Text(
                  "Connected",
                  style: TextStyle(
                    color: primaryColor,
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
              Icon(Icons.block, color: Color(0xFFFF3225)),
              SizedBox(width: 5),
              Text(
                "Blocked",
                style: TextStyle(
                  color: Color(0xFFFF3225),
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

  void _showMultiSelect(BuildContext context) async {
    await showDialog(
      context: context,
      builder: (ctx) {
        return MultiSelectDialog(
          items: otherAttributes
              .map((item) => MultiSelectItem(
                    item,
                    item,
                  ))
              .toList(),
          initialValue: sliderValues.keys
              .toSet()
              .intersection(otherAttributes.toSet())
              .toList(),
          onConfirm: <String>(values) {
            var sliderSet = Set<String>.from(sliderValues.keys);
            // remove primary attributes
            sliderSet = sliderSet.intersection(primaryAttributes.toSet());
            // remove those keys which are there in values
            sliderSet = sliderSet.difference(values.toSet());
            // remove the remaining keys from slider values
            sliderValues.removeWhere((key, value) => sliderSet.contains(key));
            // add the new values
            values.forEach((value) {
              if (!sliderValues.containsKey(value)) {
                sliderValues[value] = 0;
              }
            });
          },
        );
      },
    );
  }
}
