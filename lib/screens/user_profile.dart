import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_gps_app/model/user_api.dart';
import 'package:flutter_gps_app/model/user_model.dart';
import 'package:flutter_gps_app/notifire/user_notifire.dart';
import 'package:flutter_gps_app/services/geolocator_service.dart';
import 'package:geolocator/geolocator.dart';
import 'dart:ui';

import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:provider/provider.dart';
import 'map.dart';

class UserProfile extends StatefulWidget {
  final Position initialPosition;
  final String name; 
  UserProfile(this.initialPosition, this.name );
  @override
  _UserProfileState createState() => _UserProfileState();
}

class _UserProfileState extends State<UserProfile> {
  GoogleMapController _controller;

  UserData _currentUser;
 

  @override
  void initState() {
    super.initState();
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
  }

  @override
  Widget build(BuildContext context) {
    UserNotifier userNotifier = Provider.of<UserNotifier>(context);
    getUserData(userNotifier);
    Future<void> _refreshList() async {
      getUserData(userNotifier);
    }

    return SafeArea(
      child: Scaffold(
        body: Container(
          color: Colors.blue[700],
          child: Stack(
            children: [
              widget.initialPosition != null
                  ? GoogleMap(
                      initialCameraPosition: CameraPosition(
                          target: LatLng(widget.initialPosition.latitude,
                              widget.initialPosition.longitude),
                          zoom: 18.0),
                      mapType: MapType.normal,
                      myLocationEnabled: true,
                      onMapCreated: (GoogleMapController controller) {
                        setState(() {
                          _controller = controller;
                        });
                      },
                    )
                  : CircularProgressIndicator(),
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 8, vertical: 50),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    GestureDetector(
                      onTap: () {
                        Navigator.of(context).pop();
                      },
                      child: CircleAvatar(
                        child: Icon(
                          Icons.arrow_back_ios_new,
                          color: Colors.white,
                        ),
                      ),
                    ),
                    SizedBox(
                      width: 20,
                    ),
                    widget.name != null
                        ? Text(
                            "${widget.name} Profile",
                            style: TextStyle(
                              color: Colors.deepPurple,
                              fontSize: 20,
                              fontWeight: FontWeight.w500,
                            ),
                          )
                        : CircularProgressIndicator(),
                  ],
                ),
              ),
              // Padding(
              //   padding: EdgeInsets.symmetric(vertical: 100, horizontal: 110),
              //   child: Container(child: Text("User Profile")),
              // ),
              DraggableScrollableSheet(
                initialChildSize: 0.7,
                minChildSize: 0.6,
                builder: (BuildContext context,
                    ScrollController myScrollController) {
                  return Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.only(
                        topLeft: Radius.circular(25),
                        topRight: Radius.circular(25),
                      ),
                    ),
                    height: 150,
                    padding: EdgeInsets.all(20),
                    width: double.infinity,
                    child: GridView.builder(
                      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 4,
                      ),
                      itemCount: userNotifier.userList.length,
                      controller: myScrollController,
                      itemBuilder: (context, i) {
                        return GridTile(
                          child: GestureDetector(
                            onTap: () {
                              Navigator.of(context).push(MaterialPageRoute(
                                  builder: (_) => Map(
                                      widget.initialPosition != null
                                          ? widget.initialPosition
                                          : null,
                                      userNotifier.userList[i],
                                      widget.name != null
                                          ? widget.name
                                          : "user",
                                      _currentUser)));
                            },
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                CircleAvatar(
                                  backgroundColor: Colors.deepPurple,
                                  child: Text(
                                    userNotifier
                                        .userList[i].name.characters.first,
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 20,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                  radius: 30,
                                ),
                                SizedBox(
                                  width: 10,
                                ),
                                Text(
                                  userNotifier.userList[i].name,
                                  overflow: TextOverflow.fade,
                                  style: TextStyle(
                                    color: Colors.black54,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
