import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_gps_app/model/user_model.dart';
import 'package:flutter_gps_app/notifire/user_notifire.dart';
import 'package:geolocator/geolocator.dart';
import 'package:path/path.dart' as path;

getUserData(UserNotifier userNotifier) async {
  QuerySnapshot snapshot = await FirebaseFirestore.instance
      .collection('Location')
      .orderBy("createdAt", descending: true)
      .get();

  List<UserData> _userList = [];
  snapshot.docs.forEach((document) {
    UserData userData = UserData.fromMap(document.data());
    _userList.add(userData);
  });
  userNotifier.userList = _userList;
}

uploadUserData(UserData userData, String name, bool isUpdate,
    Function userUploaded, Position position) async {
  CollectionReference userRef =
      FirebaseFirestore.instance.collection('Location');
   userData.latitude = position.latitude;
   userData.longitude = position.longitude;
   userData.name = name;

  if (isUpdate) {
    userData.updatedAt = Timestamp.now();
    await userRef.doc(userData.id).update(userData.toMap()).catchError((e) {
      print(e);
    });
    userUploaded(userData);
  } else {
    userData.createdAt = Timestamp.now();  
    DocumentReference documentRef = await userRef.add(userData.toMap());
    userData.id = documentRef.id;
    print('uploaded food successfully: ${userData.toString()}');
    await documentRef.set(userData.toMap(), SetOptions(merge: true));
    userUploaded(userData);
  }
}
