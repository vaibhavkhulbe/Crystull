import 'dart:typed_data';

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

  Future<Uint8List?> downloadUserImage(String childName, String userUid) async {
    Reference ref = _storage.ref().child(childName).child(userUid);
    Uint8List? image = await ref.getData();
    return image;
  }

  Future<List<Uint8List>> downloadAllImage(String childName) async {
    Reference ref = _storage.ref().child(childName);
    List<Uint8List> images = [];
    await ref.listAll().then((value) async {
      for (var item in value.items) {
        await item.getData().then((value) {
          if (value != null) images.add(value);
        });
      }
    });
    return images;
  }
}
