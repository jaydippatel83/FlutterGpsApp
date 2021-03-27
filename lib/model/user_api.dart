import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_gps_app/model/user_model.dart';
import 'package:flutter_gps_app/notifire/user_notifire.dart';
import 'package:geolocator/geolocator.dart';
import 'package:path/path.dart' as path;

getUserData(UserNotifier userNotifier) async {
  QuerySnapshot snapshot = await  Firestore.instance
      .collection('UserData')
      .orderBy("createdAt", descending: true)
      .getDocuments();

  List<UserData> _userList = [];
  snapshot.documents.forEach((document) {
    UserData userData = UserData.fromMap(document.data);
    _userList.add(userData);
  });
  userNotifier.userList = _userList;
}

uploadUserData(UserData userData, Function userUploaded,Position position) async {
  CollectionReference userRef =
      Firestore.instance.collection('UserData');
  userData.createdAt = Timestamp.now();
  userData.latitude=position.latitude.toDouble();
  userData.longitude=position.longitude.toDouble();
  
  DocumentReference documentRef = await userRef.add(userData.toMap());
  userData.id = documentRef.documentID;
  print('uploaded food successfully: ${userData.toString()}');
  await documentRef.setData(userData.toMap(), merge: true);
  userUploaded(userData);
}
