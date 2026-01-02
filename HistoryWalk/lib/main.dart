import 'package:flutter/material.dart';
import 'package:historywalk/app.dart';
import 'package:mapbox_maps_flutter/mapbox_maps_flutter.dart';
import 'package:get_storage/get_storage.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // ✅ Init GetStorage (for profile persistence)
  await GetStorage.init();

  // Retrieve token from environment variables
  String token = const String.fromEnvironment("ACCESS_TOKEN");
  print("--- VERIFYING TOKEN: ${token.isNotEmpty ? 'SUCCESS' : 'EMPTY!'} ---");

  MapboxOptions.setAccessToken(token);

  runApp(const App());
}
