import 'package:cloud_firestore/cloud_firestore.dart';

Future<void> seedDatabase() async {
  final firestore = FirebaseFirestore.instance;

  try {
    print("🚀 Starting Database Seed...");

    // --- 1. DEFINE ADDITIONAL STOPS ---
    List<Map<String, dynamic>> additionalStopsData = [
      // --- ROMAN EMPIRE STOPS ---
      {
        "id": "stop_roman_1",
        "name": "The Roman Agora",
        "order": 1,
        "location": const GeoPoint(37.9742, 23.7261),
        "historyContent": "As Athens transitioned into a Roman province, this site became the city's commercial heart.\n\nCommissioned by Julius Caesar and Augustus, the Roman Agora was a vast open-air market surrounded by colonnades. Unlike the older Greek Agora which was for politics, this was strictly for business.\n\nLook for the Gate of Athena Archegetis, the monumental entrance funded by the Roman emperors themselves.",
        "imageUrls": [],
      },
      {
        "id": "stop_roman_2",
        "name": "Hadrian's Library",
        "order": 2,
        "location": const GeoPoint(37.9755, 23.7258),
        "historyContent": "The Emperor Hadrian was a noted 'Philhellene'—a lover of Greek culture—and he gifted this massive complex to the city in 132 AD.\n\nIt wasn't just a place for books; it was a 'university' of its day, containing lecture halls, transcript rooms, and lush gardens with a central pool.\n\nIts impressive Corinthian columns still stand as a reminder of the luxury that Roman rule brought to Athenian intellectual life.",
        "imageUrls": [],
      },
      {
        "id": "stop_roman_3",
        "name": "Arch of Hadrian & Olympieion",
        "order": 3,
        "location": const GeoPoint(37.9702, 23.7322),
        "historyContent": "This monumental gateway once marked the boundary between the 'old' Greek city and the 'new' Roman city of Hadrian.\n\nOn one side, an inscription reads 'This is Athens, the ancient city of Theseus,' while the other side claims 'This is the city of Hadrian, and not of Theseus.'\n\nDirectly behind it sits the Temple of Olympian Zeus, a project started by Greeks but finally completed by Hadrian after 600 years of construction.",
        "imageUrls": [],
      },

      // --- WW2 STOPS ---
      {
        "id": "stop_ww2_1",
        "name": "Syntagma Square",
        "order": 1,
        "location": const GeoPoint(37.9755, 23.7348),
        "historyContent": "Syntagma Square was the epicenter of the most turbulent moments in modern Greek history.\n\nDuring the Axis occupation, the square was a site of quiet resistance and later, massive protests. Most notably, it was the scene of the 'Dekemvriana' clashes in 1944, a tragic prelude to the Greek Civil War.\n\nToday, the Tomb of the Unknown Soldier serves as a place of national mourning and remembrance for those lost in all conflicts, including World War II.",
        "imageUrls": [],
      },
      {
        "id": "stop_ww2_2",
        "name": "Korai 4 (Memorial Site)",
        "order": 2,
        "location": const GeoPoint(37.9791, 23.7331),
        "historyContent": "Hidden beneath a modern office building lies one of the most chilling sites of the Nazi occupation.\n\nKorai 4 served as the headquarters of the German Kommandantur. Its underground air-raid shelters were converted into detention cells and torture chambers for Greek Resistance fighters.\n\nVisitors can still see the inscriptions, names, and calendars scratched into the walls by prisoners who were held here before being sent to execution or concentration camps.",
        "imageUrls": [],
      },
      {
        "id": "stop_ww2_3",
        "name": "The War Museum",
        "order": 3,
        "location": const GeoPoint(37.9758, 23.7448),
        "historyContent": "This museum offers a comprehensive look at Greece’s role in the Second World War.\n\nIt houses rare artifacts from the 1940-41 'Epic of Albania' when Greece successfully repelled the Italian invasion, as well as relics from the subsequent underground resistance movement.\n\nThe outdoor courtyard features aircraft and artillery pieces that were active during the conflict.",
        "imageUrls": [],
      },

      // --- MODERN STOPS ---
      {
        "id": "stop_modern_1",
        "name": "The National Garden",
        "order": 1,
        "location": const GeoPoint(37.9734, 23.7368),
        "historyContent": "Created in the 1830s for Queen Amalia, this park is the 'green lung' of modern Athens.\n\nIt represents the early efforts to turn a small, dusty Ottoman-era town into a modern European capital. \n\nWalking through its shaded paths, you'll see a blend of wild nature and neoclassical monuments, reflecting the city's 19th and 20th-century evolution.",
        "imageUrls": [],
      },
      {
        "id": "stop_modern_2",
        "name": "Panathenaic Stadium",
        "order": 2,
        "location": const GeoPoint(37.9683, 23.7411),
        "historyContent": "While its foundations are ancient, the 'Kallimarmaro' is a masterpiece of the modern era.\n\nIt was reconstructed entirely from white marble for the first modern Olympic Games in 1896. \n\nIt stands as a symbol of the rebirth of Greece and its connection to the international community, still used today as the finishing point for the annual Athens Marathon.",
        "imageUrls": [],
      },
      {
        "id": "stop_modern_3",
        "name": "The Stavros Niarchos Cultural Center",
        "order": 3,
        "location": const GeoPoint(37.9400, 23.6917),
        "historyContent": "A short hop from the center, this is the face of 21st-century Athens.\n\nDesigned by Renzo Piano, the SNFCC houses the National Library and the Greek National Opera. Its innovative 'solar canopy' and Mediterranean park demonstrate how the city is embracing sustainability and cutting-edge architecture.\n\nIt has quickly become the city's most popular contemporary gathering spot for culture and recreation.",
        "imageUrls": [],
      },

      // --- ANCIENT GREECE STOPS ---
      {
        "id": "stop_ancient_2_1",
        "name": "The Pnyx",
        "order": 1,
        "location": const GeoPoint(37.9718, 23.7194),
        "historyContent": "While the Parthenon was for the gods, the Pnyx was for the people.\n\nThis rocky hill is the true birthplace of Democracy. Here, the citizens of Athens would gather for the 'Ekklesia' (Assembly) to debate and vote on the laws of the city.\n\nFrom the stone 'bema' (speaker's platform), legendary orators like Pericles and Demosthenes once addressed the crowds.",
        "imageUrls": [],
      },
      {
        "id": "stop_ancient_2_2",
        "name": "The Theatre of Dionysus",
        "order": 2,
        "location": const GeoPoint(37.9703, 23.7277),
        "historyContent": "Nestled on the south slope of the Acropolis, this is the world's oldest theatre.\n\nIt was here that the concept of tragedy and comedy was born. Plays by Sophocles, Euripides, and Aristophanes were performed during the Great Dionysia festival.\n\nThe stone seats you see today could once hold up to 17,000 spectators, all gathered to witness the birth of Western drama.",
        "imageUrls": [],
      },
      {
        "id": "stop_ancient_2_3",
        "name": "The Lyceum of Aristotle",
        "order": 3,
        "location": const GeoPoint(37.9750, 23.7441),
        "historyContent": "For centuries, the exact location of Aristotle’s school was a mystery until it was rediscovered during construction in 1996.\n\nThis was the site of the Peripatetic school of philosophy, where Aristotle would walk with his students while discussing logic, ethics, and biology.\n\nIt remains one of the most important intellectual landmarks in the world, marking where the foundations of modern science were laid.",
        "imageUrls": [],
      },
    ];

    // --- 2. DEFINE ADDITIONAL ROUTES ---
    List<Map<String, dynamic>> additionalRoutesData = [
      {
        "id": "roman_athens",
        "name": "Imperial Grandeur",
        "description": "Trace the legacy of the Roman Emperors who transformed Athens into a provincial capital of luxury.",
        "routepic": "assets/icons/roman.png",
        "difficulty": "Easy",
        "duration_minutes": 100,
        "rating": 4.6,
        "reviewCount": 62,
        "stops": ["stop_roman_1", "stop_roman_2", "stop_roman_3"],
        "timePeriods": ["Roman Empire"],
        "imageUrl": [],
        "isCompleted": false,
        "color": 4290022400,
      },
      {
        "id": "ww2_athens",
        "name": "Shadows of War",
        "description": "A somber walk through the sites of occupation, resistance, and the struggle for freedom.",
        "routepic": "assets/icons/ww2.png",
        "difficulty": "Medium",
        "duration_minutes": 150,
        "rating": 4.8,
        "reviewCount": 45,
        "stops": ["stop_ww2_1", "stop_ww2_2", "stop_ww2_3"],
        "timePeriods": ["WW2"],
        "imageUrl": [],
        "isCompleted": false,
        "color": 4282334756,
      },
      {
        "id": "modern_athens",
        "name": "The New Metropolis",
        "description": "See how Athens evolved from a 19th-century royal capital to a 21st-century cultural hub.",
        "routepic": "assets/icons/modern.png",
        "difficulty": "Medium",
        "duration_minutes": 160,
        "rating": 4.5,
        "reviewCount": 38,
        "stops": ["stop_modern_1", "stop_modern_2", "stop_modern_3"],
        "timePeriods": ["Modern"],
        "imageUrl": [],
        "isCompleted": false,
        "color": 4278215643,
      },
      {
        "id": "ancient_greece_v2",
        "name": "Demos & Drama",
        "description": "Explore the birthplace of Democracy and the ancient stages where Western theatre began.",
        "routepic": "assets/icons/philosophy.png",
        "difficulty": "Easy",
        "duration_minutes": 110,
        "rating": 4.9,
        "reviewCount": 112,
        "stops": ["stop_ancient_2_1", "stop_ancient_2_2", "stop_ancient_2_3"],
        "timePeriods": ["Ancient Greece"],
        "imageUrl": [],
        "isCompleted": false,
        "color": 4294950912,
      }
    ];

    // --- 3. EXECUTE UPLOAD ---
    for (var stop in additionalStopsData) {
      await firestore.collection('stops').doc(stop['id']).set(stop);
      print("✅ Added Stop: ${stop['id']}");
    }

    for (var route in additionalRoutesData) {
      await firestore.collection('routes').doc(route['id']).set(route);
      print("✅ Added Route: ${route['id']}");
    }

    print("🎉 Database successfully updated with multi-line history!");

  } catch (e) {
    print("❌ Error Seeding Database: $e");
  }
}