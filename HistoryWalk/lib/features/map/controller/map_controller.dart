import 'package:get/get.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../routes/models/stopmodel.dart';
import '../../routes/models/route_model.dart';

class MapController extends GetxController {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Observable variables (.obs) allow the UI to update automatically
  var stops = <StopModel>[].obs;
  var isLoading = false.obs;

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