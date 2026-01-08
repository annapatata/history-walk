import 'package:get/get.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../routes/models/stopmodel.dart';
import '../../routes/models/route_model.dart';
import 'package:flutter_tts/flutter_tts.dart';

class MapController extends GetxController {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FlutterTts flutterTts = FlutterTts();
  var currentParagraphIndex = 0.obs;
  var isPaused = false.obs;
  List<String> paragraphs = [];

  void initTts() async {
  await flutterTts.setLanguage("el-GR");
  await flutterTts.setSpeechRate(0.5); // Κανονική ταχύτητα ομιλίας
  await flutterTts.setVolume(1.0);
  }

  Function? onRouteStepFinished;


  double get progress => paragraphs.isEmpty ? 0.0 : (currentParagraphIndex.value + 1) / paragraphs.length;

  void startRouteAudio(String fullText) async{
    paragraphs = fullText.split('\n').where((p)=>p.trim().isNotEmpty).toList();
    currentParagraphIndex.value = 0;
    _readCurrentParagraph();
  }

  void _readCurrentParagraph() async {
    if (currentParagraphIndex.value < paragraphs.length && !isPaused.value) {
      String paragraph = paragraphs[currentParagraphIndex.value];
      await flutterTts.speak(paragraph);
      flutterTts.setCompletionHandler(() {
        if (!isPaused.value && currentParagraphIndex.value < paragraphs.length - 1){
          Future.delayed(Duration(seconds: 2),(){
            nextParagraph();
          });
        }else{
          //Τέλος κειμένου
          if(onRouteStepFinished != null)
          {onRouteStepFinished?.call();}
        }
      });
    }
  }

  void nextParagraph(){
    if (currentParagraphIndex.value < paragraphs.length-1){
      currentParagraphIndex.value++;
      _readCurrentParagraph();
    }
  }

  void togglePause(){
    isPaused.value = !isPaused.value;
    if (!isPaused.value){
      _readCurrentParagraph();
    } else {
      flutterTts.stop();
    }
  }


  void onStopFinished(StopModel currentStop, List<StopModel> allStops, Function(StopModel) onNextStopReady){
    //βρίσκουμε την θέση της τρέχουσας στάσης στη λίστα
    int currentIndex = allStops.indexWhere((stop) => stop.id == currentStop.id);
    if (currentIndex != -1 && currentIndex < allStops.length - 1){
      //υπάρχει επόμενη στάση
      StopModel nextStop = allStops[currentIndex + 1];
      flutterTts.stop(); //σταματάμε την ανάγνωση
      Get.back(); //επιστρέφουμε στο χάρτη
      Future.delayed(Duration(milliseconds: 500), (){
        //μικρή καθυστέρηση για να αποφύγουμε προβλήματα με το Get.back()
        onNextStopReady(nextStop);
      });
    } else {
      //δεν υπάρχει επόμενη στάση
      flutterTts.stop();
      Get.back(); //επιστρέφουμε στο χάρτη
      Get.snackbar("Τέλος Διαδρομής", "Έχετε ολοκληρώσει όλες τις στάσεις της διαδρομής!",
          snackPosition: SnackPosition.BOTTOM);
    }
  }


  // Observable variables (.obs) allow the UI to update automatically
  var stops = <StopModel>[].obs;
  var isLoading = false.obs;
  var allRoutes = <RouteModel>[].obs;

  /// Fetches all routes and populates their full stop data
Future<void> loadAllRoutesWithStops() async {
  try {
    isLoading.value = true;
    
    // 1. Get all routes
    final routeSnapshot = await _firestore.collection('routes').get();
    List<RouteModel> fetchedRoutes = routeSnapshot.docs
        .map((doc) => RouteModel.fromFirestore(doc))
        .toList();

    // 2. For each route, fetch its specific stops if they aren't loaded
    for (var route in fetchedRoutes) {
      if (route.stops.isNotEmpty) {
        final stopSnapshot = await _firestore
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
      final snapshot = await _firestore
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