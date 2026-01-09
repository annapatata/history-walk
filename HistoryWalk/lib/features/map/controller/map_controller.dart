import 'package:get/get.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_tts/flutter_tts.dart';
// Assuming your model paths are correct
import '../../routes/models/stopmodel.dart'; 
import '../../routes/models/route_model.dart';


class MapController extends GetxController {
  final FlutterTts flutterTts = FlutterTts();
  
  // Observables
  var currentParagraphIndex = 0.obs;
  var isPaused = false.obs;
  var paragraphs = <String>[].obs;
  var currentStop = Rxn<StopModel>(); // Tracks which stop is active
  
  List<StopModel> allRouteStops = []; // To store all stops of the current route

  @override
  void onInit() {
    super.onInit();
    initTts();
  }

  @override
  void onClose() {
    flutterTts.stop();
    paragraphs.clear();
    currentParagraphIndex.value = 0;
    super.onClose();
  }

  void initTts() async {
    await flutterTts.setSpeechRate(0.5);
    await flutterTts.setVolume(1.0);

    flutterTts.setCompletionHandler(() {
      // Only proceed if the user hasn't paused manually
      if (!isPaused.value) {
        // Check if there are more paragraphs left to read
        if (currentParagraphIndex.value < paragraphs.length - 1) {
          // Move to next paragraph automatically after a small breathing gap
          Future.delayed(const Duration(seconds: 2), () {
            // Check again if we haven't paused/closed during the delay
            if (!isPaused.value) nextParagraph();
          });
        } else {
          // We just finished the very last paragraph
          onStopTextFinished();
        }
      }
    });
  }

  // Call this when the user clicks on a marker or starts a stop
  void startStopPresentation(StopModel stop, List<StopModel> fullRoute) {
    flutterTts.stop();
    currentStop.value = stop;
    allRouteStops = fullRoute;

    currentParagraphIndex.value = 0;
    isPaused.value = false;
    
    // Split the new historyContent by \n and clean empty lines
    paragraphs.value = stop.historyContent
        .split('\n')
        .where((p) => p.trim().isNotEmpty)
        .toList();
    
    print("paragraph length: ${paragraphs.length}");
    currentParagraphIndex.value = 0;
    isPaused.value = false;
    _readCurrentParagraph();
  }

  void _readCurrentParagraph() async {
    if (paragraphs.isNotEmpty && currentParagraphIndex.value < paragraphs.length) {
      String text = paragraphs[currentParagraphIndex.value];
      await flutterTts.speak(text);
    }
    else if(currentParagraphIndex.value >= paragraphs.length) {
      onStopTextFinished();
    }
  }

  void nextParagraph() {
    if (currentParagraphIndex.value < paragraphs.length - 1) {
      currentParagraphIndex.value++;
      _readCurrentParagraph();
    } else {
      // If the user clicks "Next" while on the last paragraph, 
      // it means they want to skip to the next stop immediately.
      flutterTts.stop();
      onStopTextFinished();
    }
  }

  void previousParagraph(){
    if(currentParagraphIndex.value >0 ){
      currentParagraphIndex.value--;
      _readCurrentParagraph();
    } else {
      Get.snackbar(
      "Αρχή Κειμένου", 
      "Βρίσκεστε ήδη στην πρώτη παράγραφο.",
      snackPosition: SnackPosition.BOTTOM,
      duration: const Duration(seconds: 1),
    );
    }
  }
  void togglePause() {
    isPaused.value = !isPaused.value;
    if (isPaused.value) {
      flutterTts.stop();
    } else {
      _readCurrentParagraph();
    }
  }

  // Logic for when the text of the stop ends
  void onStopTextFinished() {
    print("Finished reading stop: ${currentStop.value?.name}");
    
    // Auto-trigger the move to the next stop logic
    moveToNextStop();
  }

  void moveToNextStop() {
    if (currentStop.value == null) return;

    // Find current index
    int currentIndex = allRouteStops.indexWhere((s) => s.id == currentStop.value!.id);

    if (currentIndex != -1 && currentIndex < allRouteStops.length - 1) {
      // There IS a next stop
      StopModel nextStop = allRouteStops[currentIndex + 1];
      
      flutterTts.stop();
      Get.back(); // Close the "History/Details" sheet/page
      
      Get.snackbar(
        "Stop Completed", 
        "Next destination: ${nextStop.name}",
        snackPosition: SnackPosition.BOTTOM,
        duration: const Duration(seconds: 4),
      );

      // Update the current stop (this updates the map UI automatically if bound)
      currentStop.value = nextStop; 
      
      // Optionally: startStopPresentation(nextStop, allRouteStops); 
      // Or wait for the user to reach the location and tap "Start"
    } else {
      // Route Finished
      flutterTts.stop();
      Get.back();
      Get.snackbar(
        "Route Finished", 
        "Congratulations! You have completed the route.",
        snackPosition: SnackPosition.BOTTOM,
      );
    }
  }

  void moveToPreviousStop() {
    if (currentStop.value == null) return;

    flutterTts.stop();

    // Find current index
    int currentIndex = allRouteStops.indexWhere((s) => s.id == currentStop.value!.id);

    if (currentIndex > 0) {
      // There IS a previous stop
      StopModel prevStop = allRouteStops[currentIndex - 1];
      
      flutterTts.stop();
      if(Get.isBottomSheetOpen ?? false) Get.back(); // Close the "History/Details" sheet/page
      
      Get.snackbar(
        "Moved to Previous Stop", 
        "Previous destination: ${prevStop.name}",
        snackPosition: SnackPosition.BOTTOM,
        duration: const Duration(seconds: 4),
      );

      // Update the current stop
      currentStop.value = prevStop; 
      
      startStopPresentation(prevStop, allRouteStops); 
    } else {
      // Already at the first stop
      Get.snackbar(
        "First Stop", 
        "You are already at the first stop of the route.",
        snackPosition: SnackPosition.BOTTOM,
      );
    }
  }

  double get progress => paragraphs.isEmpty 
      ? 0.0 
      : (currentParagraphIndex.value + 1) / paragraphs.length;



  // Observable variables (.obs) allow the UI to update automatically
  var stops = <StopModel>[].obs;
  var isLoading = false.obs;
  var allRoutes = <RouteModel>[].obs;

  /// Fetches all routes and populates their full stop data
Future<void> loadAllRoutesWithStops() async {
  try {
    isLoading.value = true;
    
    // 1. Get all routes
    final routeSnapshot = await FirebaseFirestore.instance.collection('routes').get();
    List<RouteModel> fetchedRoutes = routeSnapshot.docs
        .map((doc) => RouteModel.fromFirestore(doc))
        .toList();

    // 2. For each route, fetch its specific stops if they aren't loaded
    for (var route in fetchedRoutes) {
      if (route.stops.isNotEmpty) {
        final stopSnapshot = await FirebaseFirestore.instance
            .collection('stops')
            .where(FieldPath.documentId, whereIn: route.stops)
            .get();

        List<StopModel> routeStops = stopSnapshot.docs
            .map((doc) => StopModel.fromFirestore(doc))
            .toList();
        
        routeStops.sort((a, b) => a.order.compareTo(b.order));
        
        // Assuming your RouteModel has a field to hold the objects
        // If not, we can use a Map in the controller: Map<String, List<StopModel>>
        route.mapstops = routeStops; 
      }
    }

    allRoutes.assignAll(fetchedRoutes);
  } catch (e) {
    print("Error loading all routes: $e");
  } finally {
    isLoading.value = false;
  }
}

  /// Fetches all StopModel objects for a specific Route
  Future<void> loadRouteStops(RouteModel route) async {
    try {
      isLoading.value = true;
      
      if (route.stops.isEmpty) {
        stops.clear();
        return;
      }

      // Firestore 'whereIn' query: Find all stops whose ID is in the route.stops list
      // Note: route.stops contains the IDs (e.g., stop_ancient_athens_1)
      final snapshot = await FirebaseFirestore.instance
          .collection('stops')
          .where(FieldPath.documentId, whereIn: route.stops)
          .get();

      // Convert the Firestore documents into StopModel objects
      List<StopModel> fetchedStops = snapshot.docs
          .map((doc) => StopModel.fromFirestore(doc))
          .toList();

      // Ensure they follow the 'order' property (Stop 1, Stop 2...)
      fetchedStops.sort((a, b) => a.order.compareTo(b.order));

      // Update the observable list
      stops.assignAll(fetchedStops);
      
    } catch (e) {
      Get.snackbar("Error", "Could not load stops: $e",
          snackPosition: SnackPosition.BOTTOM);
    } finally {
      isLoading.value = false;
    }
  }

  /// Clears the current map state
  void clearStops() {
    stops.clear();
  }
}