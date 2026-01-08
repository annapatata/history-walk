import 'time_period.dart';
import 'stopmodel.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class RouteModel {
  final String id;
  final String name;
  final String description;
  final List<String> imageUrl; //current unused because we use the images in the reviews for the gallery
  final String routepic;
  final List<TimePeriod> timePeriods;
  final Duration duration;
  final String difficulty;
  final List<String> stops;
  List<StopModel> mapstops;
  final double rating;
  final int reviewCount;
  final bool isCompleted;
  final int color; 

  RouteModel({
    required this.id,
    required this.name,
    required this.description,
    required this.imageUrl,
    required this.timePeriods,
    required this.duration,
    required this.stops,
    required this.mapstops,
    required this.difficulty,
    required this.rating,
    required this.reviewCount,
    required this.routepic,
    this.isCompleted = false,
    required this.color,
  });

  // Helper method to get stops in the correct sequence
  List<StopModel> get sortedStops {
    return mapstops..sort((a, b) => a.order.compareTo(b.order));
  }

  factory RouteModel.fromFirestore(DocumentSnapshot doc) {
  Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
  return RouteModel(
    id: doc.id,
    name: data['name'] ?? '',
    description: data['description'] ?? '',
    routepic: data['routepic'] ?? '',
    difficulty: data['difficulty'] ?? '',
    rating: (data['rating'] ?? 0.0).toDouble(),
    reviewCount: data['reviewCount'] ?? 0,
    stops: List<String>.from(data['stops'] ?? []),
    mapstops: [], // We leave this empty initially
    imageUrl: List<String>.from(data['imageUrl'] ?? []),
    timePeriods: [], // Map these if you have a TimePeriod enum/class
    duration: Duration(minutes: data['duration_minutes'] ?? 0),
    color: data['color'] ?? 0xFF000000,
  );
}
}
