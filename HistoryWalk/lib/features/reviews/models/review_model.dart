import 'package:cloud_firestore/cloud_firestore.dart';

class ReviewModel {
  final String id;          // Unique ID 
  final String userName;    // Name of the reviewer
  final double rating;      // 1.0 to 5.0
  final String text;        // The actual review content
  final List<String>? images; // Optional: list of image URLs
  final String userId; //link to user model
  final String routeId; //link to route model
  final DateTime createdAt;
  // Constructor
  ReviewModel({
    required this.id,
    required this.userName,
    required this.rating,
    required this.text,
    required this.userId,
    required this.routeId,
    required this.createdAt,
    this.images,
  });

  // Convert to Map for Firestore/Database
  Map<String, dynamic> toJson() => {
    'id': id,
    'userId': userId,
    'routeId': routeId,
    'rating': rating,
    'text': text,
    'images': images,
    'createdAt': createdAt?.toIso8601String(),
  };

  factory ReviewModel.fromSnapshot(Map<String, dynamic> data, String id) {
    return ReviewModel(
      id: id,
      userId: data['userId'] ?? '',
      userName: data['userName'] ?? 'Anonymous',
      routeId: data['routeId'] ?? '',
      rating: (data['rating'] ?? 0.0).toDouble(),
      text: data['text'] ?? '',
      images: data['images'] != null ? List<String>.from(data['images']) : [],
      createdAt: data['createdAt'] !=null
        ? (data['createdAt'] as Timestamp).toDate()
        : DateTime.now(),
    );
  }
}