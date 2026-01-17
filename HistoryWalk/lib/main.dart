import 'package:flutter/material.dart';
import 'package:historywalk/app.dart';
// import 'package:mapbox_maps_flutter/mapbox_maps_flutter.dart';
import 'package:get_storage/get_storage.dart';
import 'package:firebase_core/firebase_core.dart';
import '../features/map/controller/map_controller.dart';
import 'package:get/get.dart';
import 'firebase_options.dart';
import '../features/profile/controller/profile_controller.dart';
import '../features/profile/controller/badge_controller.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import '../features/routes/controller/route_controller.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Init Firebase
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  // Init GetStorage
  await GetStorage.init();

  Get.put(RouteController(), permanent: true);
  Get.put(ProfileController(), permanent: true);
  Get.put(BadgeController(), permanent: true);
  Get.put(MapController(),permanent:true);

  await dotenv.load(fileName: ".env");
  // // Mapbox token
  // String token = const String.fromEnvironment("ACCESS_TOKEN");
  // MapboxOptions.setAccessToken(token);

  runApp(const App());
}
