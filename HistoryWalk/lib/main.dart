import 'package:flutter/material.dart';
import 'package:historywalk/app.dart';
// import 'package:mapbox_maps_flutter/mapbox_maps_flutter.dart';
import 'package:get_storage/get_storage.dart';
import 'package:firebase_core/firebase_core.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Init Firebase
  await Firebase.initializeApp();

  // Init GetStorage
  await GetStorage.init();

  // // Mapbox token
  // String token = const String.fromEnvironment("ACCESS_TOKEN");
  // MapboxOptions.setAccessToken(token);

  runApp(const App());
}
