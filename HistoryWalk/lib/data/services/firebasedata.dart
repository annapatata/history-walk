import 'package:cloud_firestore/cloud_firestore.dart';

Future<void> seedDatabase() async {
  final firestore = FirebaseFirestore.instance;

  try {
    print("🚀 Starting Database Seed...");

    // --- 1. DEFINE STOPS ---
    List<Map<String, dynamic>> stopsData = [
      // Stops for Route 1: The Ancient Heart
      {
        "id": "stop_ancient_athens_1",
        "name": "The Parthenon",
        "order": 1,
        "location": const GeoPoint(37.9715, 23.7267),
        "historyContent": "The iconic temple dedicated to Athena, built in the 5th century BC.",
        "imageUrls": [],
      },
      {
        "id": "stop_ancient_athens_2",
        "name": "Ancient Agora",
        "order": 2,
        "location": const GeoPoint(37.9750, 23.7225),
        "historyContent": "The heart of ancient social and political life.",
        "imageUrls": [],
      },
      {
        "id": "stop_ancient_athens_3",
        "name": "Kerameikos",
        "order": 3,
        "location": const GeoPoint(37.9780, 23.7180),
        "historyContent": "The ancient cemetery and the site of the Dipylon Gate.",
        "imageUrls": [],
      },
      // Stops for Route 2: Byzantine Echoes
      {
        "id": "stop_byzantine_trail_1",
        "name": "Kapnikarea Church",
        "order": 1,
        "location": const GeoPoint(37.9763, 23.7285),
        "historyContent": "One of the oldest Greek Orthodox churches in Athens.",
        "imageUrls": [],
      },
      {
        "id": "stop_byzantine_trail_2",
        "name": "Monastery of Kaisariani",
        "order": 2,
        "location": const GeoPoint(37.9610, 23.7980),
        "historyContent": "An Eastern Orthodox monastery built on the slopes of Mt. Hymettus.",
        "imageUrls": [],
      },
      {
        "id": "stop_byzantine_trail_3",
        "name": "Daphni Monastery",
        "order": 3,
        "location": const GeoPoint(38.0130, 23.6358),
        "historyContent": "A 11th-century Byzantine monastery known for its mosaics.",
        "imageUrls": [],
      },
    ];

    // --- 2. DEFINE ROUTES ---
    List<Map<String, dynamic>> routesData = [
      {
        "id": "ancient_athens",
        "name": "The Ancient Heart",
        "description": "Walk through the birthplace of Democracy and explore the majestic Acropolis.",
        "routepic": "assets/icons/acropolis.png",
        "difficulty": "Easy",
        "duration_minutes": 120, 
        "rating": 4.9,
        "reviewCount": 150,
        "stops": ["stop_ancient_athens_1", "stop_ancient_athens_2", "stop_ancient_athens_3"],
        "timePeriods": ["Ancient"],
        "imageUrl": [],
        "isCompleted": false,
        "color": "0xFFE0C097",
      },
      {
        "id": "byzantine_trail",
        "name": "Byzantine Echoes",
        "description": "Discover the hidden spiritual gems of the medieval Orthodox era.",
        "routepic": "assets/icons/byzantine.png",
        "difficulty": "Medium",
        "duration_minutes": 180,
        "rating": 4.7,
        "reviewCount": 85,
        "stops": ["stop_byzantine_trail_1", "stop_byzantine_trail_2", "stop_byzantine_trail_3"],
        "timePeriods": ["Medieval", "Byzantine"],
        "imageUrl": [],
        "isCompleted": false,
        "color": "0xFF9FA8DA",
      }
    ];

    // --- 3. EXECUTE UPLOAD ---
    // Upload Stops
    for (var stop in stopsData) {
      await firestore.collection('stops').doc(stop['id']).set(stop);
      print("✅ Added Stop: ${stop['id']}");
    }

    // Upload Routes
    for (var route in routesData) {
      await firestore.collection('routes').doc(route['id']).set(route);
      print("✅ Added Route: ${route['id']}");
    }

    print("🎉 Database successfully seeded!");

  } catch (e) {
    print("❌ Error Seeding Database: $e");
  }
}