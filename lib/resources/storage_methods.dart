import 'dart:typed_data';

import 'package:crystull/resources/models/signup.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';

class StorageMethods {
  final FirebaseStorage _storage = FirebaseStorage.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  Future<String> uploadImage(
      String childName, Uint8List file, bool isPost) async {
    Reference ref =
        _storage.ref().child(childName).child(_auth.currentUser!.uid);
    UploadTask uploadTask = ref.putData(file);

    TaskSnapshot taskSnapshot = await uploadTask;
    String downloadURL = await taskSnapshot.ref.getDownloadURL();
    return downloadURL;
  }

  Future<Uint8List?> downloadImage(String childName) async {
    Reference ref =
        _storage.ref().child(childName).child(_auth.currentUser!.uid);
    Uint8List? image = await ref.getData();
    return image;
  }

  static Future<Uint8List?> downloadUserImage(
      String childName, CrystullUser user) async {
    FirebaseStorage _storage = FirebaseStorage.instance;
    Reference ref = _storage.ref().child(childName).child(user.uid);
    Uint8List? image = await ref.getData();
    return image;
  }
}
