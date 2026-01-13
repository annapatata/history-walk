import 'package:get/get.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:historywalk/features/profile/controller/profile_controller.dart';
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

ReviewModel? getExistingReview(String userId, String routeId) {
  return reviews.firstWhereOrNull(
    (r) => r.userId == userId && r.routeId == routeId
  );
}

Future<void> saveOrUpdateReview(ReviewModel review, bool isEditing) async{
  try{
    isLoading.value = true;
    if(isEditing){
      final query = await _db.collection('reviews')
        .where('userId',isEqualTo: review.userId)
        .where('routeId',isEqualTo: review.routeId)
        .get();

      if (query.docs.isNotEmpty){
        //update the existing review
        await query.docs.first.reference.update(review.toJson());
      }
    } else {
      // 3. Create new review
      await _db.collection('reviews').add(review.toJson());
      
      // 4. Update the user's ReviewedRoutes list in Firestore
      await _db.collection('users').doc(review.userId).update({
        'reviewedRoutes': FieldValue.arrayUnion([review.routeId])
      });
    }
    
    Get.snackbar("Success", "Review saved!");
  } catch (e) {
    Get.snackbar("Error", e.toString());
  } finally {
    isLoading.value = false;
  }
}

Future<void> deleteReview(String reviewId, String routeId, String userId) async {
  try {
    await _db.collection('reviews').doc(reviewId).delete();
    await _db.collection('users').doc(userId).update({
      'reviewedRoutes': FieldValue.arrayRemove([routeId])
    });
    
    final  profileController= Get.find<ProfileController>();
    if(profileController.userProfile.value!=null){
      List<String> updatedList = List.from(profileController.userProfile.value!.reviewedRoutes);
      updatedList.remove(routeId);
      profileController.userProfile.value = profileController.userProfile.value!.copyWith(
        reviewedRoutes: updatedList,
      );
    }
    
    Get.back();
    Get.snackbar("Success", "Review deleted successfully");
  } catch(e) {
    Get.snackbar("Error", "Failed to delete review");
  }
}
}
