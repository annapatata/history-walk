// Routes_screen.dart
import 'package:flutter/material.dart';
import '../widgets/route_box.dart';
import '../models/time_period.dart';
import 'package:historywalk/common/layouts/section_screen.dart';
import '../models/route_model.dart';
import 'routedetails.dart';

//Screen Class
class RoutesScreen extends StatelessWidget {
  const RoutesScreen({super.key});

  static final List<RouteModel> dummyRoutes = [
    RouteModel(
      id: "1",
      name: "Echoes of Rome",
      description: "Explore the ruins of ancient Rome.",
      imageUrl: ["assets/icons/image.png"],
      timePeriods: [TimePeriod(startYear: -10, endYear: 130)],
      duration: Duration(minutes: 45),
      difficulty: "Cakewalk",
      stops: ["Roman Agora", "Hadrian's Library", "Temple of Zeus"],
      rating: 4.0,
      reviewCount: 256,
      routepic: "assets/icons/image.png",
    ),
    RouteModel(
      id: "2",
      name: "Whispers of the Acropolis",
      description: "Discover the ancient Greek ruins.",
      imageUrl: ["assets/icons/acropolis.png"],
      timePeriods: [TimePeriod(startYear: -480, endYear: -404)],
      duration: Duration(minutes: 35),
      difficulty: "Moderate",
      stops: ["Parthenon", "Erechtheion", "Temple of Athena Nike"],
      rating: 4.0,
      reviewCount: 400,
      routepic: "assets/icons/acropolis.png",
    ),
    RouteModel(
      id: "3",
      name: "Whispers of the Acropolis",
      description: "Discover the ancient Greek ruins.",
      imageUrl: ["assets/icons/acropolis.png"],
      timePeriods: [TimePeriod(startYear: -480, endYear: -404)],
      duration: Duration(minutes: 35),
      difficulty: "Moderate",
      stops: ["Parthenon", "Erechtheion", "Temple of Athena Nike"],
      rating: 4.0,
      reviewCount: 400,
      routepic: "assets/icons/acropolis.png",
    ),
    RouteModel(
      id: "4",
      name: "Whispers of the Acropolis",
      description: "Discover the ancient Greek ruins.",
      imageUrl: ["assets/icons/acropolis.png"],
      timePeriods: [TimePeriod(startYear: -480, endYear: -404)],
      duration: Duration(minutes: 35),
      difficulty: "Moderate",
      stops: ["Parthenon", "Erechtheion", "Temple of Athena Nike"],
      rating: 4.0,
      reviewCount: 400,
      routepic: "assets/icons/acropolis.png",
    ),
    RouteModel(
      id: "5",
      name: "Whispers of the Acropolis",
      description: "Discover the ancient Greek ruins.",
      imageUrl: ["assets/icons/acropolis.png"],
      timePeriods: [TimePeriod(startYear: -480, endYear: -404)],
      duration: Duration(minutes: 35),
      difficulty: "Moderate",
      stops: ["Parthenon", "Erechtheion", "Temple of Athena Nike"],
      rating: 4.0,
      reviewCount: 400,
      routepic: "assets/icons/acropolis.png",
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return SectionScreenLayout(
      title: 'ROUTES',
      body: ListView(
        children: dummyRoutes
            .map(
              (route) => RouteBox(
                route: route,
                onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => RouteDetails(
                      route: route,
                    ),
                  ),
                )
              ),
            )
            .toList(),
      ),
    );
  }
}
