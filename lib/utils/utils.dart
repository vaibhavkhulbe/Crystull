import 'dart:typed_data';

import 'package:crystull/resources/models/signup.dart';
import 'package:flutter/material.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:image_picker/image_picker.dart';

pickImage(ImageSource source) async {
  ImagePicker picker = ImagePicker();
  XFile? _file = await picker.pickImage(source: source);

  if (_file != null) {
    return _file;
  } else {
    return null;
  }
}

showSnackBar(String content, BuildContext context) {
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(
      content: Text(content),
    ),
  );
}

double getSafeAreaHeight(BuildContext context) {
  return MediaQuery.of(context).size.height -
      MediaQuery.of(context).padding.top;
}

double getSafeAreaWidth(BuildContext context) {
  return MediaQuery.of(context).size.width -
      MediaQuery.of(context).padding.left;
}

Future<Uint8List> compressList(Uint8List list) async {
  var result = await FlutterImageCompress.compressWithList(
    list,
    minHeight: 192,
    minWidth: 108,
    quality: 25,
  );
  // print(list.length);
  // print(result.length);
  return result;
}

bool isUnblocked(CrystullUser user1, CrystullUser user2) {
  return user1.uid == user2.uid ||
      !user1.connections.containsKey(user2.uid) ||
      (user1.connections.containsKey(user2.uid) &&
          user1.connections[user2.uid]!.status <= 3);
}
