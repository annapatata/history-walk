// map_screen.dart
import 'package:flutter/material.dart';
import 'package:historywalk/common/widgets/searchbar.dart';
import 'package:historywalk/navigation_menu.dart';
import 'package:mapbox_maps_flutter/mapbox_maps_flutter.dart'; // For the MapWidget and Controller
import 'package:flutter/services.dart'; // If loading custom map styles or icons from assets
import 'package:geolocator/geolocator.dart' as geo;
import 'package:get/get.dart';
import '../controller/map_controller.dart';
import '../../routes/models/route_model.dart';
import '../../routes/models/stopmodel.dart';
import 'dart:async';
import '../../routes/screens/routedetails.dart';
import '../../routes/widgets/route_box.dart';
import 'package:historywalk/common/widgets/primaryactionbutton.dart';
import 'package:historywalk/utils/constants/app_colors.dart';
import '../../profile/controller/profile_controller.dart';
import '../../reviews/widgets/writereview.dart';
import 'package:historywalk/features/reviews/controller/review_controller.dart';
import 'dart:ui' as ui;

class MapScreen extends StatefulWidget {
  final RouteModel? selectedRoute; // If null, show all routes
  const MapScreen({super.key, this.selectedRoute});
  @override
  State<MapScreen> createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> {
  final MapController controller = Get.find<MapController>();
  MapboxMap? mapboxMap;
  PointAnnotationManager? pointAnnotationManager;
  PolylineAnnotationManager? polylineAnnotationManager;
  Map<String, StopModel> markerToStopMap = {};

  @override
  void initState() {
    super.initState();
    //listen for when a stop is finished to move the camera
    ever(controller.currentStop, (StopModel? stop) {
      if (stop != null) {
        _moveCameraToStop(stop);
      }
    });
  }

  void _moveCameraToStop(StopModel stop) {
    mapboxMap?.flyTo(
      CameraOptions(
        center: Point(
          coordinates: Position(
            stop.location.longitude,
            stop.location.latitude,
          ),
        ),
        zoom: 16.0,
        pitch: 45, // slight tilt for 3D effect
      ),
      MapAnimationOptions(duration: 2000),
    );
  }

  //  Focus camera on the first stop of the selected route
  void _focusOnFirstStop(List<StopModel> stops) {
    if (stops.isEmpty) return;
    _moveCameraToStop(stops[0]);
  }

  //  Function to find and move to user location
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

  // 1. Map to link Mapbox IDs to your Route objects
  final Map<String, RouteModel> _polylineToRouteMap = {};

  // 2. A flag to ensure we don't register the click listener multiple times
  bool _isRouteListenerAdded = false;
  
  // Show route details popup on polyline tap
  void _showRoutePopup(RouteModel route) {
    final ReviewController reviewController = Get.put(ReviewController());
    final ProfileController profileController = Get.find();

    final bool isCompleted = profileController.isRouteCompleted(route.id);
    final bool isReviewed = profileController.userProfile.value?.reviewedRoutes.contains(route.id)??false;

    String buttonLabel = 'START ROUTE';
      if(isCompleted){
        buttonLabel = isReviewed ? 'EDIT YOUR REVIEW' : 'WRITE A REVIEW';
      }
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent, // Let the container handle the styling
      builder: (context) {
        return Container(
          padding: const EdgeInsets.all(20),
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min, // Wrap content height
            children: [
              // 1. The Route Tile (Reusing your existing widget)
              RouteBox(route: route,
                       onTap: () {
                        reviewController.fetchReviews(route.id);
                        Get.to(() => RouteDetails(route: route));
                        },
                      ), 
              
              const SizedBox(height: 20),

              // 2. The "Start Route" Button
              PrimaryActionButton(
                label: buttonLabel,
                onPressed: () async {

                  if(isCompleted){
                    showDialog(
                      context:context,
                      builder: (context) => WriteReviewModal(routeId: route.id,isEditing: isReviewed),
                    );
                  } else {
                  final MapController mapController = Get.find();

                  // 1. Trigger the fetch
                  // 2. IMPORTANT: Use 'await' so we don't move to the next screen until data is here
                  await mapController.loadRouteStops(route);

                  // 3. Now navigate
                  Get.to(() => MapScreen(selectedRoute: route));
                }
                },
                backgroundcolour: isCompleted ? AppColors.stars : AppColors.searchBarDark,
              ),
              const SizedBox(height: 10), // Safe area spacing
            ],
          ),
        );
      },
    );
  }

  Future<void> _drawRoutes(List<RouteModel> routes) async {
    if (polylineAnnotationManager == null || pointAnnotationManager == null) {
      print("⚠️ Managers not ready yet");
      return;
    }

    try {

      // Clear map and our local ID map
      await polylineAnnotationManager?.deleteAll();
      await pointAnnotationManager?.deleteAll();

      // Load marker icon
      final ByteData bytes = await rootBundle.load('assets/icons/marker.png');
      final Uint8List markerImage = bytes.buffer.asUint8List();

      for (var route in routes) {
        final List<StopModel> stops = route.mapstops;
        if (stops.isEmpty) continue;

        final lineCoordinates = stops
            .map((s) => Position(s.location.longitude, s.location.latitude))
            .toList();
        
        final geometry = LineString(coordinates: lineCoordinates);

        // --- 1. Draw the VISIBLE "Metro Line" ---
        // We don't need to capture its ID, it's just for looks.
        await polylineAnnotationManager?.create(
          PolylineAnnotationOptions(
            geometry: geometry,
            lineColor: route.color, 
            lineWidth: 6.0, // Standard visual width
            lineJoin: LineJoin.ROUND,
            // Ensure visible line is drawn below the tappable one
            lineSortKey: 1.0, 
          ),
        );
        
        // --- 2. Draw the INVISIBLE "Tappable Line" (Ghost Line) ---
        // CHANGE: Only draw the ghost line if NO route is selected.
        if (widget.selectedRoute == null) { // <--- ADD THIS CHECK
          final tappableAnnotation = await polylineAnnotationManager?.create(
            PolylineAnnotationOptions(
              geometry: geometry,
              lineColor: Colors.transparent.value, 
              lineWidth: 35.0, // This was stealing your clicks!
              lineJoin: LineJoin.ROUND,
              lineSortKey: 2.0,
            ),
          );

          if (tappableAnnotation != null) {
            _polylineToRouteMap[tappableAnnotation.id] = route;
          }
        }

        if (widget.selectedRoute != null) {
          // 3. Draw the "Stations" (Markers remain the same)
          final markerOptions = stops.map((stop) {
            return PointAnnotationOptions(
              geometry: Point(
                coordinates: Position(
                  stop.location.longitude,
                  stop.location.latitude,
                ),
              ),
              symbolSortKey: 3.0,
              image: markerImage,
              iconSize: 0.09,
            );
          }).toList();

          final annotations = await pointAnnotationManager?.createMulti(markerOptions);

          if (annotations != null) {
            for (int i = 0; i < annotations.length; i++) {
              markerToStopMap[annotations[i]!.id] = stops[i];
            }
          }
        }
        else {
          // --- 3. Draw "Dots" for non-selected routes ---
          
          // GENERATE DOT IMAGE:
          // We create a colored circle on the fly using the route's color.
          final ui.PictureRecorder pictureRecorder = ui.PictureRecorder();
          final Canvas canvas = Canvas(pictureRecorder);
          const double size = 30.0; // The resolution of the dot (pixels)

          final Paint paint = Paint()
            ..color = Color(route.color) // Convert the int color to a Flutter Color
            ..style = PaintingStyle.fill;

          // Draw the circle
          canvas.drawCircle(
            Offset(size / 2, size / 2), 
            size / 2, 
            paint
          );

          // Convert canvas to a Uint8List image
          final ui.Image image = await pictureRecorder
              .endRecording()
              .toImage(size.toInt(), size.toInt());
          final ByteData? byteData = await image.toByteData(format: ui.ImageByteFormat.png);
          final Uint8List dotImage = byteData!.buffer.asUint8List();

          // CREATE ANNOTATIONS:
          final dotOptions = stops.map((stop) {
            return PointAnnotationOptions(
              geometry: Point(
                coordinates: Position(
                  stop.location.longitude,
                  stop.location.latitude,
                ),
              ),
              symbolSortKey: 1.0, // Ensure dots sit above lines
              image: dotImage,    // Use the generated colored dot
              iconSize: 1,      // Scale down visually if the 30px image is too big
            );
          }).toList();

          await pointAnnotationManager?.createMulti(dotOptions);
        }
        
      }
    } catch (e) {
      print("Error drawing routes: $e");
    }
  }

  //  Show bottom sheet with route progress and controls
  void _showRouteProgress(StopModel stop) {
    //initialize the audio and paragraphs in the controller
    final allStops = widget.selectedRoute!.mapstops;
    controller.startStopPresentation(stop, allStops);

    showModalBottomSheet(
      context: context,
      isDismissible: true,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(25)),
      ),
      builder: (context) {
        return Obx(() {
          // 1. Create safety variables
          final stops = widget.selectedRoute?.mapstops ?? [];

          // 2. Add a 'Guard Clause'
          // If the list is empty, return a placeholder so it doesn't crash during closing
          if (stops.isEmpty || controller.paragraphs.isEmpty) {
            return const SizedBox.shrink();
          }

          // 3. Now define your conditions safely
          final isLastParagraph =
              controller.currentParagraphIndex.value >=
              controller.paragraphs.length - 1;

          // USE .lastOrNull (if using Dart 3) or check length
          final isLastStop = stops.isNotEmpty && stops.last.id == stop.id;
          final bool isFinishState = isLastParagraph && isLastStop;

          return Container(
            padding: const EdgeInsets.all(20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                //handle for dragging
                Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: Colors.grey[300],
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),

                if (stop.imageUrls.isNotEmpty)
                  SizedBox(
                    height: 180,
                    child: ListView.builder(
                      scrollDirection: Axis.horizontal,
                      itemCount: stop.imageUrls.length,
                      itemBuilder: (context, index) {
                        return Padding(
                          padding: const EdgeInsets.only(right: 8.0),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(15),
                            child: Image.asset(
                              stop.imageUrls[index],
                              width: 280,
                              fit: BoxFit.cover,
                              // Error builder helps if you have a typo in the asset path
                              errorBuilder: (context, error, stackTrace) =>
                                  const Center(
                                    child: Icon(Icons.broken_image, size: 50),
                                  ),
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                const SizedBox(height: 15),

                // Progress Bar
                ClipRRect(
                  borderRadius: BorderRadius.circular(10),
                  child: LinearProgressIndicator(
                    value: controller.progress,
                    backgroundColor: Colors.grey[200],
                    valueColor: const AlwaysStoppedAnimation<Color>(
                      Color(0xFFE9B32A),
                    ),
                    minHeight: 8,
                  ),
                ),
                const SizedBox(height: 10),

                // Εμφάνιση αρίθμησης (π.χ. 2 / 5)
                Text(
                  "${controller.currentParagraphIndex.value + 1} από ${controller.paragraphs.length}",
                  style: TextStyle(color: Colors.grey[600], fontSize: 12),
                ),

                const SizedBox(height: 15),
                Text(
                  stop.name,
                  style: const TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 15),

                // 2. Το κείμενο της τρέχουσας παραγράφου
                Container(
                  constraints: BoxConstraints(
                    maxHeight: MediaQuery.of(context).size.height * 0.3,
                  ),
                  child: SingleChildScrollView(
                    child: Text(
                      controller.paragraphs.isNotEmpty
                          ? controller.paragraphs[controller
                                .currentParagraphIndex
                                .value]
                          : "Loading...",
                      style: const TextStyle(fontSize: 16, height: 1.5),
                    ),
                  ),
                ),

                const SizedBox(height: 20),

                // 3. Controls (Play/Pause & Next)
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    IconButton(
                      onPressed: () => controller.moveToPreviousStop(),
                      icon: const Icon(
                        Icons.skip_previous_rounded,
                        size: 30,
                        color: Colors.grey,
                      ),
                    ),
                    IconButton(
                      onPressed: () => controller.previousParagraph(),
                      icon: const Icon(
                        Icons.keyboard_arrow_left_rounded,
                        size: 35,
                        color: Colors.black87,
                      ),
                    ),
                    IconButton(
                      icon: Icon(
                        controller.isPaused.value
                            ? Icons.play_arrow_rounded
                            : Icons.pause_rounded,
                        size: 30,
                        color: Colors.black87,
                      ),
                      onPressed: () => controller.togglePause(),
                    ),

                    ElevatedButton.icon(
                      onPressed: () async {
                        if (!isLastParagraph) {
                          controller.nextParagraph();
                        } else if (!isLastStop) {
                          controller.moveToNextStop();
                        } else {
                          await controller.finalizeRoute();
                        }
                      },
                      icon: Icon(
                        isFinishState ? Icons.flag_rounded : Icons.skip_next,
                      ),
                      label: Text(isFinishState ? "FINISH" : "Next"),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: isFinishState
                            ? Colors.green
                            : const Color(0xFFE9B32A),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
              ],
            ),
          );
        });
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

                try {
                  // 2. Create Managers (IMPORTANT: Must await)
                  pointAnnotationManager = await map.annotations
                      .createPointAnnotationManager();
                  polylineAnnotationManager = await map.annotations
                      .createPolylineAnnotationManager();

                  // 3. Set up marker tap listener

                  pointAnnotationManager?.tapEvents(
                    onTap: (PointAnnotation annotation) {
                      final stop = markerToStopMap[annotation.id];
                      if (stop != null) {
                        _showRouteProgress(stop);
                      }
                    },
                  );

                  polylineAnnotationManager?.tapEvents(
                    onTap: (annotation) {
                      // The listener will now trigger on the wide invisible line.
                      // We look up the route associated with that invisible line's ID.
                      final route = _polylineToRouteMap[annotation.id];
                      if (route != null && widget.selectedRoute == null) {
                        _showRoutePopup(route);
                      }
                    },
                  );

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

                // If in route-specific mode, focus on the first stop
                if (widget.selectedRoute != null) {
                  _focusOnFirstStop(widget.selectedRoute!.mapstops);
                } else {
                  mapboxMap?.setCamera(
                    CameraOptions(
                      center: Point(coordinates: Position(23.7257, 37.9715)),
                      zoom: 12.0,
                    ),
                  );
                }
              },
            ),
Positioned(
  top: 60,
  left: 0,
  right: 0,
  child: Center(
    child: ElevatedButton(
      style: ElevatedButton.styleFrom(
        // Change color based on status: Red for ending, Green for starting
        backgroundColor: widget.selectedRoute != null ? Colors.redAccent : Colors.green,
        foregroundColor: Colors.white,
        shape: const StadiumBorder(),
        elevation: 4,
      ),
      onPressed: () {
        if (widget.selectedRoute != null) {
          Get.defaultDialog(
            title: "End Route?",
            middleText: "Are you sure you want to stop now? Your progress won't be saved.",
            textCancel: "Cancel",
            textConfirm: "End Now",
            confirmTextColor: Colors.white,
            onConfirm: () {
              controller.flutterTts.stop();
              Get.offAll(() => const NavigationMenu());
            },
          );
        } else {
          Get.offAll(() => const NavigationMenu());
        }
      },
      child: Text(
        // Change text based on status
        widget.selectedRoute != null ? "END ROUTE" : "START A ROUTE",
        style: const TextStyle(fontWeight: FontWeight.bold),
      ),
    ),
  ),
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

            // Floating Action Button for Location
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
                //child: Column(children: [HWSearchBar()]),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class PolylineClickListener implements OnPolylineAnnotationClickListener {
  final Function(PolylineAnnotation) onTap;

  PolylineClickListener({required this.onTap});

  @override
  void onPolylineAnnotationClick(PolylineAnnotation annotation) {
    onTap(annotation);
  }
}
