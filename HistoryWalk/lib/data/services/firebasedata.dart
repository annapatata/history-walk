import 'package:cloud_firestore/cloud_firestore.dart';

Future<void> seedDatabase() async {
  final firestore = FirebaseFirestore.instance;

  try {
    print("🚀 Starting Database Seed...");

    // --- 1. DEFINE STOPS ---
    List<Map<String, dynamic>> stopsData = [
      {
        "id": "stop_ancient_athens_1",
        "name": "The Parthenon",
        "order": 1,
        "location": const GeoPoint(37.9715, 23.7267),
        "historyContent": "The Parthenon stands as the ultimate symbol of Ancient Greek civilization.\n\nBuilt between 447 and 432 BC, it was dedicated to the goddess Athena Parthenos. The temple is famous for its Doric columns and the 'optical illusions' used by its architects to make the structure appear perfectly straight.\n\nOver the centuries, it has served as a treasury, a Christian church, and even an Ottoman mosque.",
        "imageUrls": [],
      },
      {
        "id": "stop_ancient_athens_2",
        "name": "Ancient Agora",
        "order": 2,
        "location": const GeoPoint(37.9750, 23.7225),
        "historyContent": "The Ancient Agora was the 'heartbeat' of Athens.\n\nThis wasn't just a marketplace; it was the center of democracy, philosophy, and social life. Here, citizens would gather to discuss politics, and philosophers like Socrates would challenge passersby with deep questions.\n\nDon't miss the Temple of Hephaestus, which is one of the best-preserved Greek temples in the world.",
        "imageUrls": [],
      },
      {
        "id": "stop_ancient_athens_3",
        "name": "Kerameikos",
        "order": 3,
        "location": const GeoPoint(37.9780, 23.7180),
        "historyContent": "Kerameikos was the potters' quarter of the city and later became its most important cemetery.\n\nLocated just outside the ancient city walls, it features the Dipylon Gate—the main entrance to Athens. \n\nWalking through this site offers a somber and beautiful look at the funerary monuments and the Sacred Way, which led all the way to Eleusis.",
        "imageUrls": [],
      },
      {
        "id": "stop_byzantine_trail_1",
        "name": "Kapnikarea Church",
        "order": 1,
        "location": const GeoPoint(37.9763, 23.7285),
        "historyContent": "Sitting right in the middle of the busy Ermou Street, the Church of Panagia Kapnikarea is a 11th-century masterpiece.\n\nIt is a classic example of the 'cross-in-square' Byzantine architectural style. \n\nIn the 1830s, the church was almost demolished to make way for the new city plan, but it was saved by the intervention of King Ludwig I of Bavaria.",
        "imageUrls": [],
      },
      {
        "id": "stop_byzantine_trail_2",
        "name": "Monastery of Kaisariani",
        "order": 2,
        "location": const GeoPoint(37.9610, 23.7980),
        "historyContent": "Escape the city noise at this peaceful monastery nestled on the slopes of Mount Hymettus.\n\nEstablished in the late 11th century, it was built over the ruins of an ancient temple dedicated to Aphrodite.\n\nThe monastery is famous for its natural springs, which were believed in ancient times to aid fertility and health.",
        "imageUrls": [],
      },
      {
        "id": "stop_byzantine_trail_3",
        "name": "Daphni Monastery",
        "order": 3,
        "location": const GeoPoint(38.0130, 23.6358),
        "historyContent": "A UNESCO World Heritage site, Daphni Monastery is a jewel of the 'Macedonian Renaissance'.\n\nIt is world-renowned for its stunning 11th-century mosaics, especially the 'Christ Pantocrator' in the dome, which gazes down with a stern, powerful expression.\n\nDespite suffering damage from earthquakes over the centuries, the golden mosaics remain some of the finest examples of Byzantine art in existence.",
        "imageUrls": [],
      },
    ];

    // --- 2. DEFINE ROUTES (Kept the same) ---
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
        "color": 4280483835,
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
        "color": 4294910862,
      }
    ];

    // --- 3. EXECUTE UPLOAD ---
    for (var stop in stopsData) {
      await firestore.collection('stops').doc(stop['id']).set(stop);
      print("✅ Updated Stop: ${stop['id']}");
    }

    for (var route in routesData) {
      await firestore.collection('routes').doc(route['id']).set(route);
      print("✅ Updated Route: ${route['id']}");
    }

// --- 3. DEFINE REVIEWS ---
    List<Map<String, dynamic>> reviewsData = [
      // Reviews for "The Ancient Heart" (ancient_athens)
      {
        "id": "rev_1",
        "routeId": "ancient_athens",
        "userId": "user_alpha",
        "userName": "Marcus Aurelius",
        "rating": 5.0,
        "text": "An incredible journey through time. Standing at the Parthenon at sunrise was a spiritual experience. The app's history content is spot on!",
        "images": ["https://upload.wikimedia.org/wikipedia/commons/e/e6/Classic_view_of_Acropolis.jpg"],
        "createdAt": Timestamp.now(),
      },
      {
        "id": "rev_2",
        "routeId": "ancient_athens",
        "userId": "user_beta",
        "userName": "Sophia G.",
        "rating": 4.0,
        "text": "Great walk! The Ancient Agora section was very detailed. It's a bit of a climb to the Acropolis, so wear good shoes.",
        "images": ["https://upload.wikimedia.org/wikipedia/commons/thumb/f/f0/The_Acropolis_of_Athens_as_seen_from_the_Pnyx_in_October_2025.jpg/960px-The_Acropolis_of_Athens_as_seen_from_the_Pnyx_in_October_2025.jpg"],
        "createdAt": Timestamp.now(),
      },
      {
        "id": "rev_3",
        "routeId": "ancient_athens",
        "userId": "user_gamma",
        "userName": "Nikolas P.",
        "rating": 5.0,
        "text": "I've lived in Athens for years and never knew the details about Kerameikos. This route turned a Sunday walk into a history lesson.",
        "images": ["https://www.grayline.com/wp-content/uploads/2025/03/Gray-Line-Athens-Cover-Photo-scaled.jpg"],
        "createdAt": Timestamp.now(),
      },
      {
        "id": "rev_4",
        "routeId": "ancient_athens",
        "userId": "user_delta",
        "userName": "Elena_Travels",
        "rating": 3.5,
        "text": "Beautiful sites, but very crowded near the Parthenon. The app guided me perfectly through the side streets to avoid some of the heat.",
        "images": ["https://upload.wikimedia.org/wikipedia/commons/c/c4/Akropolis_by_Leo_von_Klenze.jpg"],
        "createdAt": Timestamp.now(),
      },

      // Reviews for "Byzantine Echoes" (byzantine_trail)
      {
        "id": "rev_5",
        "routeId": "byzantine_trail",
        "userId": "user_epsilon",
        "userName": "John Doe",
        "rating": 5.0,
        "text": "The Daphni Monastery mosaics are breathtaking. This route is a must for anyone interested in medieval art. Very peaceful compared to the city center.",
        "images": ["https://www.greece-is.com/wp-content/uploads/2024/09/shutterstock_2144161825.jpg"],
        "createdAt": Timestamp.now(),
      },
      {
        "id": "rev_6",
        "routeId": "byzantine_trail",
        "userId": "user_zeta",
        "userName": "Maria K.",
        "rating": 4.5,
        "text": "Kapnikarea is such a gem in the middle of the shopping district. I loved the contrast between the old church and the modern city.",
        "images": ["https://images.unsplash.com/photo-1503152394-c571994fd383?q=80&w=400"],
        "createdAt": Timestamp.now(),
      },
      {
        "id": "rev_7",
        "routeId": "byzantine_trail",
        "userId": "user_theta",
        "userName": "HistoryBuff99",
        "rating": 5.0,
        "text": "Kaisariani Monastery was the highlight. The natural springs and the quiet atmosphere made the Medium difficulty walk totally worth it.",
        "images": ["https://whyathens.com/wp-content/uploads/2019/03/Byzantine-Churches-Athens-Ermou-Kapnikarea-I-1024x683.jpg"],
        "createdAt": Timestamp.now(),
      },
      {
        "id": "rev_8",
        "routeId": "byzantine_trail",
        "userId": "user_iota",
        "userName": "Alex Smith",
        "rating": 4.0,
        "text": "Interesting route, although the travel between the monasteries takes some time. The 'Echoes' theme is very fitting.",
        "images": [],
        "createdAt": Timestamp.now(),
      },
    ];

    // --- 4. EXECUTE UPLOAD (Add this to your upload loop) ---
    for (var review in reviewsData) {
      await firestore.collection('reviews').doc(review['id']).set(review);
      print("✅ Seeded Review: ${review['id']}");
    }

    print("🎉 Database successfully updated with multi-line history!");

  } catch (e) {
    print("❌ Error Seeding Database: $e");
  }
}