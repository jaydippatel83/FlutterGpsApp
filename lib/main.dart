import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_gps_app/notifire/user_notifire.dart';
import 'package:flutter_gps_app/screens/user_info.dart';
import 'package:flutter_gps_app/services/geolocator_service.dart';
import 'package:geolocator/geolocator.dart';
import 'package:provider/provider.dart';
import './screens/map.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  runApp(
    MultiProvider(providers: [
      ChangeNotifierProvider(
        create: (context) => UserNotifier(),
      ),
    ], child: MyApp()),
  );
}

class MyApp extends StatelessWidget {
  final geoService = GeoLocatorSevice();
  @override
  Widget build(BuildContext context) {
    return FutureProvider(
      initialData: null,
      create: (context) => geoService.getInitialLocation(),
      child: MaterialApp(
        title: 'Flutter Gps App',
        theme: ThemeData(
          primarySwatch: Colors.purple,
        ),
        home: Consumer<Position>(
          builder: (context, position, widget) {
            return (position != null)
                ? UserInfo(initialPosition: position)
                : Center(child: CircularProgressIndicator());
          },
        ),
      ),
    );
  }
}
