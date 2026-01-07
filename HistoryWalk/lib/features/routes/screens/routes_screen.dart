import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart'; // Add this
import '../widgets/route_box.dart';
import '../models/route_model.dart';
import 'routedetails.dart';
import 'package:historywalk/common/layouts/section_screen.dart';
import '../models/stopmodel.dart';

class RoutesScreen extends StatelessWidget {
  const RoutesScreen({super.key});

  // Function to fetch data from Firestore
  Future<List<RouteModel>> getRoutesWithStops() async {
  final firestore = FirebaseFirestore.instance;

  // 1. Fetch all Routes
  final routeSnapshot = await firestore.collection('routes').get();
  
  List<RouteModel> fullRoutes = [];

  for (var routeDoc in routeSnapshot.docs) {
    // Create the route from Firestore data
    RouteModel route = RouteModel.fromFirestore(routeDoc);

    // 2. Fetch the specific stops for THIS route
    if (route.stops.isNotEmpty) {
      final stopsSnapshot = await firestore
          .collection('stops')
          .where(FieldPath.documentId, whereIn: route.stops)
          .get();

      // Convert stop docs to StopModel objects
      List<StopModel> fetchedStops = stopsSnapshot.docs
          .map((doc) => StopModel.fromFirestore(doc))
          .toList();

      // Sort them by your 'order' field to ensure Stop 1 is before Stop 2
      fetchedStops.sort((a, b) => a.order.compareTo(b.order));

      // 3. Attach them to the mapstops field
      route = RouteModel(
        id: route.id,
        name: route.name,
        description: route.description,
        imageUrl: route.imageUrl,
        routepic: route.routepic,
        timePeriods: route.timePeriods,
        duration: route.duration,
        difficulty: route.difficulty,
        stops: route.stops,
        mapstops: fetchedStops, 
        rating: route.rating,
        reviewCount: route.reviewCount,
      );
    }
    
    fullRoutes.add(route);
  }

  return fullRoutes;
}

  @override
  Widget build(BuildContext context) {
    return SectionScreenLayout(
      title: 'ROUTES',
      body: FutureBuilder<List<RouteModel>>(
        future: getRoutesWithStops(),
        builder: (context, snapshot) {
          // 1. Show loading spinner while waiting
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          // 2. Show error message if something goes wrong
          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }

          // 3. Show message if database is empty
          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text('No routes found.'));
          }

          // 4. Show the list of actual routes
          final routes = snapshot.data!;
          return ListView.builder(
            itemCount: routes.length,
            itemBuilder: (context, index) {
              final route = routes[index];
              return RouteBox(
                route: route,
                onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => RouteDetails(route: route),
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}