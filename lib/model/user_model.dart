import 'package:cloud_firestore/cloud_firestore.dart';

class UserData {
  String id;
  String name;
  double latitude;
  double longitude;
  Timestamp createdAt;
  UserData();

  UserData.fromMap(Map<String, dynamic> data) {
    id = data['id'];
    name = data['name'];
    latitude = data['latitude'];
    longitude = data['longitude'];
    createdAt = data['createdAt'];
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'latitude': latitude,
      'longitude': longitude,
      'createdAt': createdAt,
    };
  }
}
