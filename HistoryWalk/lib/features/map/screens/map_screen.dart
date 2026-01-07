// map_screen.dart
import 'package:flutter/material.dart';
import 'package:historywalk/common/widgets/searchbar.dart';
import 'package:mapbox_maps_flutter/mapbox_maps_flutter.dart'; // For the MapWidget and Controller
import 'package:flutter/services.dart'; // If loading custom map styles or icons from assets
import 'dart:typed_data';               // If processing image data for custom markers
import 'package:geolocator/geolocator.dart' as geo;
import 'package:get/get.dart';
import '../controller/map_controller.dart';
import '../../routes/models/route_model.dart';

class MapScreen extends StatefulWidget {
  final RouteModel? selectedRoute; // Add this
  const MapScreen({super.key, this.selectedRoute});
  @override
  State<MapScreen> createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> {
  final MapController controller = Get.put(MapController());
  MapboxMap? mapboxMap;
  PointAnnotationManager? pointAnnotationManager;

  // 1. Function to find and move to user location
  Future<void> _goToUserLocation() async {
    // Check/Request permissions
    geo.LocationPermission permission = await geo.Geolocator.checkPermission();
    if (permission == geo.LocationPermission.denied) {
      permission = await geo.Geolocator.requestPermission();
    }

    if (permission == geo.LocationPermission.whileInUse || permission == geo.LocationPermission.always) {
      // Get current position
      geo.Position position = await geo.Geolocator.getCurrentPosition();

      // Move camera
      mapboxMap?.setCamera(CameraOptions(
        center: Point(coordinates: Position(position.longitude, position.latitude)),
        zoom: 15.0,
      ));

      // Enable the blue dot puck
      mapboxMap?.location.updateSettings(LocationComponentSettings(enabled: true));
    }
  }


 @override
Widget build(BuildContext context) {
  return Scaffold(
    body: SafeArea(
      child: Stack(
        children: [
          Obx(() {
            if (controller.isLoading.value) {
              return const Center(child: CircularProgressIndicator());
            }

            return MapWidget(
              // 1. Move your initial camera options here
              cameraOptions: CameraOptions(
                center: Point(coordinates: Position(23.7257, 37.9715)),
                zoom: 12.0,
              ),
              onMapCreated: (MapboxMap map) async {
  mapboxMap = map;
  print("🛠️ Map Created. Starting marker logic...");

  try {
    // 1. Load Image
    final ByteData bytes = await rootBundle.load('assets/icons/marker.png');
    final Uint8List list = bytes.buffer.asUint8List();
    print("✅ 1. Icon loaded successfully");

    // 2. Create Manager (IMPORTANT: Must await)
    pointAnnotationManager = await map.annotations.createPointAnnotationManager();
    print("✅ 2. Annotation Manager ready");

    // 3. Check Data
    final displayStops = controller.stops;
    print("📊 3. Found ${displayStops.length} stops in controller");

    if (displayStops.isEmpty) {
      print("⚠️ 4. Stops list is empty. No markers to draw.");
      return;
    }

    // 4. Map Options
    final options = displayStops.map((stop) {
      return PointAnnotationOptions(
        geometry: Point(
          coordinates: Position(stop.location.longitude, stop.location.latitude),
        ),
        image: list,
        iconSize: 0.1,
      );
    }).toList();

    // 5. Add to Map
    await pointAnnotationManager?.createMulti(options);
    print("🚀 5. Markers pushed to Mapbox!");

  } catch (e) {
    print("❌ ERROR in onMapCreated: $e");
  }
},
            );
          }),
          
          
          
          // 2. Floating Action Button for Location
          Positioned(
            bottom: 30,
            right: 20,
            child: FloatingActionButton(
              backgroundColor: Colors.white,
              onPressed: _goToUserLocation,
              child: const Icon(Icons.my_location, color: Colors.blue),
            ),
          ),

          SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 10.0),
              child: Column(
                children: [
                  HWSearchBar(), 
                ],
              ),
            ),
          ),
        ],
      ),
    ),
  );
}
}