// map_screen.dart
import 'package:flutter/material.dart';
import 'package:historywalk/common/widgets/searchbar.dart';
import 'package:mapbox_maps_flutter/mapbox_maps_flutter.dart'; // For the MapWidget and Controller
import 'package:flutter/services.dart'; // If loading custom map styles or icons from assets
import 'dart:typed_data'; // If processing image data for custom markers
import 'package:geolocator/geolocator.dart' as geo;
import 'package:get/get.dart';
import '../controller/map_controller.dart';
import '../../routes/models/route_model.dart';
import '../../routes/models/stopmodel.dart';
import 'dart:async';

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
  PolylineAnnotationManager? polylineAnnotationManager;
  Map<String, StopModel> markerToStopMap = {};
  StreamSubscription? markerSubscription;

  // 1. Function to find and move to user location
  Future<void> _goToUserLocation() async {
    // Check/Request permissions
    geo.LocationPermission permission = await geo.Geolocator.checkPermission();
    if (permission == geo.LocationPermission.denied) {
      permission = await geo.Geolocator.requestPermission();
    }

    if (permission == geo.LocationPermission.whileInUse ||
        permission == geo.LocationPermission.always) {
      // Get current position
      geo.Position position = await geo.Geolocator.getCurrentPosition();

      // Move camera
      mapboxMap?.setCamera(
        CameraOptions(
          center: Point(
            coordinates: Position(position.longitude, position.latitude),
          ),
          zoom: 15.0,
        ),
      );

      // Enable the blue dot puck
      mapboxMap?.location.updateSettings(
        LocationComponentSettings(enabled: true),
      );
    }
  }

  Future<void> _drawRoutes(List<RouteModel> routes) async {
    if (polylineAnnotationManager == null || pointAnnotationManager == null) {
      print("⚠️ Managers not ready yet");
      return;
    }
    try {
      // Clear map before drawing to prevent duplicates
      await polylineAnnotationManager?.deleteAll();
      await pointAnnotationManager?.deleteAll();

      // Load the marker icon once outside the loop for better performance
      final ByteData bytes = await rootBundle.load('assets/icons/marker.png');
      final Uint8List markerImage = bytes.buffer.asUint8List();

      for (var route in routes) {
        // mapstops must be populated by the controller before calling this
        final List<StopModel> stops = route.mapstops;

        if (stops.isEmpty) continue;

        // 1. Draw the "Metro Line"
        final lineCoordinates = stops
            .map((s) => Position(s.location.longitude, s.location.latitude))
            .toList();

        await polylineAnnotationManager?.create(
          PolylineAnnotationOptions(
            geometry: LineString(coordinates: lineCoordinates),
            lineColor: route.color, // Now a direct int from Firebase!
            lineWidth: 6.0,
            lineJoin: LineJoin.ROUND,
          ),
        );

        // 2. Draw the "Stations"
        final markerOptions = stops.map((stop) {
          return PointAnnotationOptions(
            geometry: Point(
              coordinates: Position(
                stop.location.longitude,
                stop.location.latitude,
              ),
            ),
            image: markerImage,
            iconSize: 0.09,
          );
        }).toList();
        final annotations = await pointAnnotationManager?.createMulti(
          markerOptions,
        );

        if (annotations != null) {
          for (int i = 0; i < annotations.length; i++) {
            markerToStopMap[annotations[i]!.id] = stops[i];
          }
        }
      }
    } catch (e) {
      print("Error drawing routes: $e");
    }
  }

  void _showStopDetails(StopModel stop) {
    showModalBottomSheet(
      context: context,
      backgroundColor:
          Colors.transparent, // Για να φαίνονται οι στρογγυλεμένες γωνίες
      isScrollControlled: true, // Επιτρέπει στο sheet να μεγαλώσει αν χρειαστεί
      builder: (context) {
        return Container(
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(25)),
          ),
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min, // Προσαρμόζεται στο περιεχόμενο
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Μια μικρή γραμμή στην κορυφή (handle)
              Center(
                child: Container(
                  width: 40,
                  height: 5,
                  decoration: BoxDecoration(
                    color: Colors.grey[300],
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
              ),
              const SizedBox(height: 20),
              Text(
                stop.name,
                style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 15),
              ConstrainedBox(
                constraints: BoxConstraints(
                  maxHeight: MediaQuery.of(context).size.height * 0.4,
                ),
                child: SingleChildScrollView(
                  child: Text(
                    stop.historyContent, // Χρήση του πεδίου από το μοντέλο σου
                    style: const TextStyle(fontSize: 16, height: 1.5),
                  ),
                ),
              ),
              const SizedBox(height: 20),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Stack(
          children: [
            MapWidget(
              // 1. Move your initial camera options here
              cameraOptions: CameraOptions(
                center: Point(coordinates: Position(23.7257, 37.9715)),
                zoom: 12.0,
              ),
              onMapCreated: (MapboxMap map) async {
                mapboxMap = map;
                print("🛠️ Map Created. Starting marker logic...");

                try {
                  // 2. Create Managers (IMPORTANT: Must await)
                  pointAnnotationManager = await map.annotations
                      .createPointAnnotationManager();
                  print("✅ 2. Annotation Manager ready");
                  polylineAnnotationManager = await map.annotations
                      .createPolylineAnnotationManager();
                  print("✅ 2b. Polyline Annotation Manager ready");

                  // 3. Set up marker tap listener

                  
                  pointAnnotationManager?.tapEvents(
                    onTap: (PointAnnotation annotation) {
                      print("Marker tapped: ${annotation.id}");
                      final stop = markerToStopMap[annotation.id];
                      if (stop != null) {
                        _showStopDetails(stop);
                      }
                    },
                  );

                  print("✅ 3. Marker tap listener set up");
                  @override
                  void dispose() {
                    markerSubscription?.cancel(); // Πολύ σημαντικό!
                    super.dispose();
                  }

                  // Give the platform channel a tiny breath to establish connection
                  await Future.delayed(const Duration(milliseconds: 100));
                  // 2. Decide what data to show
                  // If widget.selectedRoute is null, we are in "Global Map" mode
                  if (widget.selectedRoute != null) {
                    await controller.loadRouteStops(widget.selectedRoute!);
                    widget.selectedRoute!.mapstops = controller.stops;
                    _drawRoutes([widget.selectedRoute!]);
                  } else {
                    await controller.loadAllRoutesWithStops();
                    _drawRoutes(controller.allRoutes);
                  }
                  print("✅ 3. Markers and routes drawn on map");
                } catch (e) {
                  print("Error in map creation: $e");
                } finally {
                  controller.isLoading.value = false;
                }
              },
            ),
            Obx(() {
              if (controller.isLoading.value) {
                return Container(
                  color: Colors.white70,
                  child: const Center(child: CircularProgressIndicator()),
                );
              } else {
                return const SizedBox.shrink();
              }
            }),

            // 2. Floating Action Button for Location
            Positioned(
              bottom: 30,
              right: 20,
              child: FloatingActionButton(
                backgroundColor: Colors.white,
                onPressed: _goToUserLocation,
                child: const Icon(
                  Icons.my_location,
                  color: Color.fromARGB(255, 233, 179, 42),
                ),
              ),
            ),

            SafeArea(
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16.0,
                  vertical: 10.0,
                ),
                child: Column(children: [HWSearchBar()]),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
