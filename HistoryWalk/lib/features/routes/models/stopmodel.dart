import 'package:cloud_firestore/cloud_firestore.dart';

class StopModel {
  final String id;
  final String name;
  final List<String> imageUrls;
  final GeoPoint location; // Use GeoPoint for Firestore compatibility
  final int order;
  final String historyContent;
  
  StopModel({
    required this.id,
    required this.name,
    required this.imageUrls,
    required this.location,
    required this.order,
    required this.historyContent,
  });

  
  factory StopModel.fromFirestore(DocumentSnapshot doc) {
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
    
    return StopModel(
      id: doc.id,
      name: data['name'] ?? '',
      // Safely convert Firestore dynamic list to String list
      imageUrls: List<String>.from(data['imageUrls'] ?? []),
      location: data['location'] as GeoPoint,
      order: data['order'] ?? 0,
      historyContent: data['historyContent'] ?? '',
    );
  }
}