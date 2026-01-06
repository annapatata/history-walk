import 'package:mapbox_maps_flutter/mapbox_maps_flutter.dart';

class StopModel {
  final String id;
  final String name;
  final List<String> imageUrls;
  final Point location; // Essential for placing the pin on the map
  final int order; // To handle "Stop 1", "Stop 2", etc.
  final String historyContent;

  StopModel({
    required this.id,
    required this.name,
    required this.imageUrls,
    required this.location,
    required this.order,
    required this.historyContent,
  });
}