// map_screen.dart
import 'package:flutter/material.dart';
import 'package:historywalk/common/widgets/searchbar.dart';
import 'package:mapbox_maps_flutter/mapbox_maps_flutter.dart'; // For the MapWidget and Controller
import 'package:flutter/services.dart'; // If loading custom map styles or icons from assets
import 'dart:typed_data';               // If processing image data for custom markers
import 'package:geolocator/geolocator.dart' as geo;

class MapScreen extends StatefulWidget {
  @override
  State<MapScreen> createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> {
  MapboxMap? mapboxMap;

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
      child:Stack(
        children: [

          MapWidget(
            onMapCreated: (controller) => mapboxMap = controller,
            cameraOptions: CameraOptions(
              center: Point(coordinates: Position(23.7257, 37.9715)),
              zoom: 12.0,
            ),
          ),
          
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
                  // Your Search Bar Widget
                  HWSearchBar(), 
                  // You can add more floating buttons here (like a "Recenter" button)
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