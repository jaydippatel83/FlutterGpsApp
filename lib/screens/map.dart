import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_gps_app/model/user_api.dart';
import 'package:flutter_gps_app/notifire/user_notifire.dart';
import 'package:flutter_gps_app/services/geolocator_service.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:provider/provider.dart';

class Map extends StatefulWidget {
  // final Position initialPosition;
  // Map(this.initialPosition);
  @override
  _MapState createState() => _MapState();
}

class _MapState extends State<Map> {
  final GeoLocatorSevice geoService = GeoLocatorSevice();
  Completer<GoogleMapController> _controller = Completer();

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

    return ListView.builder(
      itemCount: userNotifier.userList.length,
      itemBuilder: (BuildContext context, int index) {
        return ListTile(
          title: Text(userNotifier.userList[index].name),
          leading: Column(
            children: [
              Text(userNotifier.userList[index].latitude.toString()),
              Text(userNotifier.userList[index].longitude.toString()),
            ],
          ),
        );
        // return GoogleMap(
        //   initialCameraPosition: CameraPosition(
        //       target: LatLng(userNotifier.userList[index].latitude,
        //           userNotifier.userList[index].longitude),
        //       zoom: 18.0),
        //   mapType: MapType.normal,
        //   myLocationEnabled: true,
        //   onMapCreated: (GoogleMapController controller) {
        //     _controller.complete(controller);
        //   },
        // );
      },
    );
  }

  Future<void> centerScreen(Position position) async {
    final GoogleMapController controller = await _controller.future;
    controller.animateCamera(CameraUpdate.newCameraPosition(CameraPosition(
        target: LatLng(position.latitude, position.longitude), zoom: 18.0)));
  }
}
