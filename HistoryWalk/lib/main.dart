import 'package:flutter/material.dart';
import 'package:historywalk/app.dart';
import 'package:mapbox_maps_flutter/mapbox_maps_flutter.dart'; // Core Mapbox


void main() async{
  WidgetsFlutterBinding.ensureInitialized(); //if flutter needs to call native code this makes sure you have an instance of the widgetsbinding which is required to use platform channels to use native code

  // Retrieve token from environment variables
  String token = const String.fromEnvironment("ACCESS_TOKEN");
  print("--- VERIFYING TOKEN: ${token.isNotEmpty ? 'SUCCESS' : 'EMPTY!'} ---");
  MapboxOptions.setAccessToken(token);
  
  runApp(const App());
}

