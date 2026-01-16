import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:mapbox_maps_flutter/mapbox_maps_flutter.dart'; // Ensure this is imported for Position
import '../../routes/models/stopmodel.dart'; 
import 'package:flutter_dotenv/flutter_dotenv.dart';

Future<List<Position>> getRoadPath(List<StopModel> stops) async {
  if (stops.length < 2) return [];

  // 1. Format coordinates into a string "long,lat;long,lat;..."
  String coordinates = stops
      .map((s) => "${s.location.longitude},${s.location.latitude}")
      .join(';');

  // 2. Build the API URL
  // profile: 'driving' (cars/buses), 'walking', 'cycling'
  final String profile = 'mapbox/walking'; 
  final String accessToken = dotenv.env['MAPBOX_ACCESS_TOKEN']!; // Replace or use config
  
  // geometries=geojson: gives us raw coordinates we can easily use
  // overview=full: gives the highest precision path
  final String url = 
      'https://api.mapbox.com/directions/v5/$profile/$coordinates?geometries=geojson&overview=full&access_token=$accessToken';

  try {
    final response = await http.get(Uri.parse(url));

    if (response.statusCode == 200) {
      final jsonResponse = json.decode(response.body);
      
      // 3. Extract the geometry coordinates
      final List<dynamic> routes = jsonResponse['routes'];
      if (routes.isNotEmpty) {
        final Map<String, dynamic> geometry = routes[0]['geometry'];
        final List<dynamic> coords = geometry['coordinates'];
        
        // Convert dynamic list to List<Position>
        return coords.map((c) => Position(c[0], c[1])).toList();
      }
    } else {
      print("Error fetching directions: ${response.body}");
    }
  } catch (e) {
    print("Exception fetching directions: $e");
  }

  // Fallback: If API fails, just return straight lines between stops
  return stops
      .map((s) => Position(s.location.longitude, s.location.latitude))
      .toList();
}