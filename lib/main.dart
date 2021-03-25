import 'package:flutter/material.dart';
import 'package:flutter_gps_app/services/geolocator_service.dart';
import 'package:geolocator/geolocator.dart';
import 'package:provider/provider.dart';
import './screens/map.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  final geoService = GeoLocatorSevice();
  @override
  Widget build(BuildContext context) {
    return FutureProvider(
      create: (context) => geoService.getInitialLocation(), 
      child: MaterialApp(
        title: 'Flutter Gps App',
        theme: ThemeData(
          primarySwatch: Colors.purple,
        ),
        home: Consumer<Position>(
          builder: (context, position, widget) {
            return (position != null)
                ? Map(position)
                : Center(child: CircularProgressIndicator());
          },
        ),
      ),
    );
  }
}
