import 'time_period.dart';

class RouteModel {
  final String id;
  final String name;
  final String description;
  final List<String> imageUrl;
  final String routepic;
  final List<TimePeriod> timePeriods;
  final Duration duration;
  final String difficulty;
  final List<String> stops;
  final double rating;
  final int reviewCount;
  final bool isCompleted;

  RouteModel({
    required this.id,
    required this.name,
    required this.description,
    required this.imageUrl,
    required this.timePeriods,
    required this.duration,
    required this.stops,
    required this.difficulty,
    required this.rating,
    required this.reviewCount,
    required this.routepic,
    this.isCompleted = false,
  });
}
