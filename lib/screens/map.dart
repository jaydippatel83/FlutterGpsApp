import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_gps_app/model/user_api.dart';
import 'package:flutter_gps_app/model/user_model.dart';
import 'package:flutter_gps_app/notifire/user_notifire.dart';
import 'package:flutter_gps_app/services/geolocator_service.dart';
import 'package:flutter_polyline_points/flutter_polyline_points.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';

class Map extends StatefulWidget {
  final Position initialPosition;
  final destination;
  final String name;
  final _currentUser;
  Map(this.initialPosition, this.destination, this.name, this._currentUser);
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

  Iterable markers = [];
  var docId;

  final Set<Marker> _markers = {};
  List<Polyline> _polyLine = [];

  @override
  void initState() {
    geoService.getCurrentLocation().listen((position) {
      centerScreen(position);
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

    LatLng _lat1 =
        LatLng(widget.destination.latitude, widget.destination.longitude);
    LatLng _lat2 = LatLng(
        widget.initialPosition.latitude, widget.initialPosition.longitude);

    double distance = Geolocator.distanceBetween(
        widget.destination.latitude,
        widget.destination.longitude,
        widget.initialPosition.latitude,
        widget.initialPosition.longitude);

    _polyLine.add(Polyline(
      polylineId: PolylineId("route1"),
      color: Colors.blue,
      patterns: [PatternItem.dash(20.0), PatternItem.gap(10)],
      width: 4,
      points: [
        widget.destination != null ? _lat1 : null,
        widget.initialPosition != null ? _lat2 : null
      ],
    ));

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.name != null
            ? widget.name + "  To  " + widget.destination.name
            : "No user"),
      ),
      body: Stack(
        children: [
          widget.initialPosition != null
              ? GoogleMap(
                  initialCameraPosition: CameraPosition(
                      target: LatLng(widget.initialPosition.latitude,
                          widget.initialPosition.longitude),
                      zoom: 18.0),
                  mapType: MapType.normal,
                  myLocationEnabled: true,
                  polylines: _polyLine.toSet(),
                  onMapCreated: (GoogleMapController controller) {
                    _controller.complete(controller);
                  },
                  markers: Set.from(markers),
                )
              : CircularProgressIndicator(),
          distance != null
              ? Positioned(
                  child: Container(
                    padding: EdgeInsets.all(10),
                    color: Colors.black38,
                    child: Text(
                      "Distance ${distance.floorToDouble() / 1000} Km",
                      style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 20,
                          color: Colors.white),
                    ),
                  ),
                )
              : CircularProgressIndicator(),
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

    uploadUserData(
        widget._currentUser, widget.name, true, userUploaded, position);
    controller.animateCamera(CameraUpdate.newCameraPosition(CameraPosition(
        target: LatLng(position.latitude, position.longitude), zoom: 18.0)));
  }
}
