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

  // 1. Add the variable
  var searchQuery = ''.obs;

  // 2. Add the update method
  void updateSearchQuery(String query) {
    searchQuery.value = query;
  }

  @override
  void onInit() {
    super.onInit();
    // Keep this as a backup if you still want to support direct argument passing
    if (Get.arguments != null) {
      preffilters(
        periods: Get.arguments['periods'],
        durations: Get.arguments['durations'],
      );
    } else {
      fetchRoutesWithStops();
    }
  }

  // Sorting Logic: Routes matching ANY active filter move to top
  List<RouteModel> get displayRoutes {
    List<RouteModel> sortedList = List.from(allRoutes);

    // If all filters are default, return original list
    if (selectedPeriod.value == 'All' && 
        selectedDifficulty.value == 'All' && 
        selectedDuration.value == 'All' &&
        searchQuery.value.isEmpty) {
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

    bool searchMatch = searchQuery.value.isEmpty || 
      route.name.toLowerCase().contains(searchQuery.value.toLowerCase());

    // A route "Matches" if it satisfies all active (non-'All') filters
    return periodMatch && difficultyMatch && durationMatch && searchMatch;
  }

  void preffilters({List<String>? periods, List<String>? durations}) {
    if (periods != null && periods.isNotEmpty) {
      selectedPeriod.value = _mapToDisplayName(periods.first);
    }
    if (durations != null && durations.isNotEmpty) {
      selectedDuration.value = durations.first;
    }
    // Fetch data immediately with new filters
    fetchRoutesWithStops();
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