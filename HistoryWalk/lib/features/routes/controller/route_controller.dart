import 'package:get/get.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/route_model.dart';
import '../models/stopmodel.dart';

class RouteController extends GetxController {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  var allRoutes = <RouteModel>[].obs;
  var isLoading = true.obs;

  // Active filter states
  var selectedPeriod = 'All'.obs;
  var selectedDifficulty = 'All'.obs;
  var selectedDuration = 'All'.obs;

  var selectedFilter = 'All'.obs;

  @override
  void onInit() {
    super.onInit();
    // Handle incoming preferences from Onboarding
    if (Get.arguments != null) {
      final List<String> periods = Get.arguments['periods'] ?? [];
      if (periods.isNotEmpty) {
        print('user chose period');
        selectedPeriod.value = _mapToDisplayName(periods.first);
      }
      final List<String> durations = Get.arguments['durations'] ?? [];
    if (durations.isNotEmpty) {
      // Set the duration filter to whatever they picked (e.g., '60+ min')
      print('user chose a duration');
      selectedDuration.value = durations.first; 
    }
    }
    fetchRoutesWithStops();
  }

  // Sorting Logic: Routes matching ANY active filter move to top
  List<RouteModel> get displayRoutes {
    List<RouteModel> sortedList = List.from(allRoutes);

    // If all filters are default, return original list
    if (selectedPeriod.value == 'All' && 
        selectedDifficulty.value == 'All' && 
        selectedDuration.value == 'All') {
      return allRoutes;
    }

    sortedList.sort((a, b) {
      bool aMatch = checkMatch(a);
      bool bMatch = checkMatch(b);

      if (aMatch && !bMatch) return -1;
      if (!aMatch && bMatch) return 1;
      return 0;
    });

    return sortedList;
  }

  bool checkMatch(RouteModel route) {
    // 1. Check Period
    bool periodMatch = selectedPeriod.value == 'All' || 
        route.timePeriods.any((tp) => tp.displayName == selectedPeriod.value);

    // 2. Check Difficulty
    bool difficultyMatch = selectedDifficulty.value == 'All' || 
        route.difficulty == selectedDifficulty.value;

    // 3. Check Duration
    bool durationMatch = true;
    int minutes = route.duration.inMinutes;
    if (selectedDuration.value == '15+ min') durationMatch = minutes >= 15;
    if (selectedDuration.value == '30+ min') durationMatch = minutes >= 30;
    if (selectedDuration.value == '60+ min') durationMatch = minutes >= 60;

    // A route "Matches" if it satisfies all active (non-'All') filters
    return periodMatch && difficultyMatch && durationMatch;
  }

  void updateFilter(String type, String value) {
    if (type == 'period') {
      selectedPeriod.value = value;
      selectedFilter.value = value;
    }
    if (type == 'difficulty') selectedDifficulty.value = value;
    if (type == 'duration') selectedDuration.value = value;
  }

  // Same helper as before for Onboarding arguments
  String _mapToDisplayName(String raw) {
    switch (raw) {
      case 'ancient': return 'Ancient Greece';
      case 'roman': return 'Roman Empire';
      case 'ww2': return 'WW2';
      case 'medieval' : return 'Medieval';
      case 'modern' : return 'Modern';
      case 'byzantine' : return 'Byzantine';
      default: return 'All';
    }
  }

  Future<void> fetchRoutesWithStops() async {
    try {
      isLoading(true);
      final routeSnapshot = await _firestore.collection('routes').get();
      List<RouteModel> fullRoutes = [];

      for (var routeDoc in routeSnapshot.docs) {
        RouteModel route = RouteModel.fromFirestore(routeDoc);
        if (route.stops.isNotEmpty) {
          final stopsSnapshot = await _firestore
              .collection('stops')
              .where(FieldPath.documentId, whereIn: route.stops)
              .get();

          List<StopModel> fetchedStops = stopsSnapshot.docs
              .map((doc) => StopModel.fromFirestore(doc))
              .toList();
          
          fetchedStops.sort((a, b) => a.order.compareTo(b.order));
          route.mapstops = fetchedStops;
        }
        fullRoutes.add(route);
      }

      allRoutes.assignAll(fullRoutes);
    } catch (e) {
      Get.snackbar("Error", e.toString());
    } finally {
      isLoading(false);
    }
  }

  
}