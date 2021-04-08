import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_gps_app/model/user_api.dart';
import 'package:flutter_gps_app/model/user_model.dart';
import 'package:flutter_gps_app/notifire/user_notifire.dart';
import 'package:flutter_gps_app/services/geolocator_service.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:provider/provider.dart';


class Map extends StatefulWidget {
  final Position initialPosition;
  final String name;
  final String id;
  Map(this.initialPosition, this.name, this.id);
  @override
  _MapState createState() => _MapState();
}

class _MapState extends State<Map> {
  final GeoLocatorSevice geoService = GeoLocatorSevice();
  Completer<GoogleMapController> _controller = Completer();
  FirebaseFirestore firestore = FirebaseFirestore.instance;

  static double currentLatitude = 0.0;
  static double currentLongitude = 0.0;
  var data;
  UserData _currentUser;

  Iterable markers = [];
  var docId;

  @override
  void initState() {
    geoService.getCurrentLocation().listen((position) {
      centerScreen(position);
    });
    UserNotifier userNotifier =
        Provider.of<UserNotifier>(context, listen: false);

    if (userNotifier.currentUser != null) {
      _currentUser.name = widget.name;
      _currentUser = userNotifier.currentUser;
    } else {
      _currentUser = UserData();
    }

    userUploaded(UserData userData) {
      userNotifier.addUser(userData);
    }

    uploadUserData(
        _currentUser, widget.name, false, userUploaded, widget.initialPosition);

    // firestore.collection("Location").add({
    //   "id": widget.id,
    //   "latitude": widget.initialPosition.latitude,
    //   "longitude": widget.initialPosition.longitude,
    //   "name": widget.name,
    //   "createdAt": Timestamp.now(),
    //   "updateAt": null,
    // });

    FirebaseFirestore.instance
        .collection('Location')
        .doc(docId)
        .get()
        .then((DocumentSnapshot documentSnapshot) {
      if (documentSnapshot.exists) {
        setState(() {
          currentLatitude = documentSnapshot.data()['latitude'];
          currentLongitude = documentSnapshot.data()['longitude'];
        });
      } else {
        print('Document does not exist on the database');
      }
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    UserNotifier userNotifier = Provider.of<UserNotifier>(context);
    getUserData(userNotifier);
    Future<void> _refreshList() async {
      getUserData(userNotifier);
    }

    Iterable _markers = Iterable.generate(
        userNotifier.userList.length != null
            ? userNotifier.userList.length
            : null, (index) {
      return Marker(
          markerId: MarkerId(userNotifier.userList[index].id),
          position: LatLng(
            userNotifier.userList[index].latitude,
            userNotifier.userList[index].longitude,
          ),
          infoWindow: InfoWindow(
              title: userNotifier.userList[index].name, snippet: "CodeCrunch"));
    });

    setState(() {
      markers = _markers;
    });

//   Marker resultMarker = Marker(
//   markerId: MarkerId(docId),
//   infoWindow: InfoWindow(
//   title: "${widget.name}",
//   ),
//   position: LatLng(currentLatitude,
//   currentLongitude),
// );
// // Add it to Set
// markers.add(resultMarker);

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.name),
      ),
      body: Stack(
        children: [
         widget.initialPosition != null ? GoogleMap(
            initialCameraPosition: CameraPosition(
                target: LatLng(widget.initialPosition.latitude,
                    widget.initialPosition.longitude),
                zoom: 18.0),
            mapType: MapType.normal,
            myLocationEnabled: true,
            onMapCreated: (GoogleMapController controller) {
              _controller.complete(controller);
            },
            markers: Set.from(markers),
          ): Container(),
        ],
      ),
    );
  }

  Future<void> centerScreen(Position position) async {
    final GoogleMapController controller = await _controller.future;
    UserNotifier userNotifier =
        Provider.of<UserNotifier>(context, listen: false);

    userUploaded(UserData userData) {
      userNotifier.addUser(userData);
    }

    uploadUserData(_currentUser, widget.name, true, userUploaded, position);

    controller.animateCamera(CameraUpdate.newCameraPosition(CameraPosition(
        target: LatLng(position.latitude, position.longitude), zoom: 18.0)));
  }
}
