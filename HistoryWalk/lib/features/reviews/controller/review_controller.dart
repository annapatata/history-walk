import 'package:get/get.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/review_model.dart';

class ReviewController extends GetxController {
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  
  // Observable list of reviews
  RxList<ReviewModel> reviews = <ReviewModel>[].obs;
  RxBool isLoading = false.obs;

  // Fetch reviews for a specific route
  void fetchReviews(String routeId) {
    isLoading.value = true;
    _db.collection('reviews')
       .where('routeId', isEqualTo: routeId)
       .snapshots()
       .listen((snapshot) {
         reviews.value = snapshot.docs
             .map((doc) => ReviewModel.fromSnapshot(doc.data(), doc.id))
             .toList();
         isLoading.value = false;
       });
  }
}