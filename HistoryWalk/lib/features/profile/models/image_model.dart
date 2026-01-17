import 'package:cloud_firestore/cloud_firestore.dart';

class MemoryModel {
  final String imageUrl;
  final String stopName;
  final String routeId;
  final DateTime timestamp;

  MemoryModel({
    required this.imageUrl,
    required this.stopName,
    required this.routeId,
    required this.timestamp,
  });

  factory MemoryModel.fromFirestore(Map<String, dynamic> data) {
    return MemoryModel(
      imageUrl: data['url'] ?? '',
      stopName: data['stopName'] ?? 'Unknown Stop',
      routeId: data['routeId'] ?? '',
      timestamp: (data['timestamp'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }
}