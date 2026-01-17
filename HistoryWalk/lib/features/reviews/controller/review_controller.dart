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
    _db
        .collection('reviews')
        .where('routeId', isEqualTo: routeId)
        .snapshots()
        .listen((snapshot) {
          reviews.value = snapshot.docs
              .map((doc) => ReviewModel.fromSnapshot(doc.data(), doc.id))
              .toList();
          // Update local stats so RouteBox shows the count from the actual list
          if (reviews.isNotEmpty) {
            final routeId = reviews.first.routeId;
            double avg =
                reviews.fold(0.0, (sum, r) => sum + r.rating) / reviews.length;
            updateLocalStats(routeId, avg, reviews.length);
          }
          isLoading.value = false;
        });
  }

  // Key: routeId, Value: { 'rating': double, 'count': int }
  RxMap<String, Map<String, dynamic>> routeStats =
      <String, Map<String, dynamic>>{}.obs;

  // Call this whenever you fetch reviews or update a rating
  void updateLocalStats(String routeId, double avg, int count) {
    routeStats[routeId] = {'rating': avg, 'count': count};
  }

  ReviewModel? getExistingReview(String userId, String routeId) {
    return reviews.firstWhereOrNull(
      (r) => r.userId == userId && r.routeId == routeId,
    );
  }

  Future<void> saveOrUpdateReview(ReviewModel review, bool isEditing) async {
    try {
      isLoading.value = true;
      double? oldRatingForAdjustment;

      if (isEditing) {
        final query = await _db
            .collection('reviews')
            .where('userId', isEqualTo: review.userId)
            .where('routeId', isEqualTo: review.routeId)
            .get();

        if (query.docs.isNotEmpty) {
          // Capture the old rating before we overwrite it
          oldRatingForAdjustment = query.docs.first
              .data()['rating']
              ?.toDouble();
          await query.docs.first.reference.update(review.toJson());
        }
      } else {
        await _db.collection('reviews').add(review.toJson());
        await _db.collection('users').doc(review.userId).update({
          'reviewedRoutes': FieldValue.arrayUnion([review.routeId]),
        });
      }

      // --- NEW: Trigger the Route document update ---
      await updateRouteRating(
        review.routeId,
        review.rating,
        isEditing: isEditing,
        oldRatingIfEditing: oldRatingForAdjustment,
      );

      Get.snackbar("Success", "Review saved!");
    } catch (e) {
      Get.snackbar("Error", e.toString());
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> deleteReview(
    String reviewId,
    String routeId,
    String userId,
  ) async {
    try {
      await _db.collection('reviews').doc(reviewId).delete();
      await _db.collection('users').doc(userId).update({
        'reviewedRoutes': FieldValue.arrayRemove([routeId]),
      });

      final profileController = Get.find<ProfileController>();
      if (profileController.userProfile.value != null) {
        List<String> updatedList = List.from(
          profileController.userProfile.value!.reviewedRoutes,
        );
        updatedList.remove(routeId);
        profileController.userProfile.value = profileController
            .userProfile
            .value!
            .copyWith(reviewedRoutes: updatedList);
      }

      Get.back();
      Get.snackbar("Success", "Review deleted successfully");
    } catch (e) {
      Get.snackbar("Error", "Failed to delete review");
    }
  }

  double getAverageRatingForRoute(String routeId) {
    // If you haven't fetched reviews yet, this might be 0.
    // This is why we ideally keep a 'cached' version in the Route document.
    final routeReviews = reviews.where((r) => r.routeId == routeId).toList();
    if (routeReviews.isEmpty) return 0.0;

    double total = routeReviews.fold(0, (sum, item) => sum + item.rating);
    return total / routeReviews.length;
  }

  Future<void> updateRouteRating(
    String routeId,
    double newRating, {
    required bool isEditing,
    double? oldRatingIfEditing,
  }) async {
    final routeRef = _db.collection('routes').doc(routeId);

    await _db.runTransaction((transaction) async {
      DocumentSnapshot snapshot = await transaction.get(routeRef);
      if (!snapshot.exists) return;

      double currentRating = snapshot.get('rating')?.toDouble() ?? 0.0;
      int currentCount = snapshot.get('reviewCount') ?? 0;

      double updatedAverage;
      int updatedCount;

      if (isEditing && oldRatingIfEditing != null) {
        // Logic for Editing: Replace old score with new score, count stays same
        updatedCount = currentCount;
        // Formula: ((TotalSum - OldScore) + NewScore) / Count
        double totalSum =
            (currentRating * currentCount) - oldRatingIfEditing + newRating;
        updatedAverage = currentCount > 0 ? totalSum / currentCount : newRating;
      } else {
        // Logic for New: Add new score and increment count
        updatedCount = currentCount + 1;
        updatedAverage =
            ((currentRating * currentCount) + newRating) / updatedCount;
      }

      transaction.update(routeRef, {
        'rating': updatedAverage,
        'reviewCount': updatedCount,
      });
      updateLocalStats(routeId, updatedAverage, updatedCount);
    });
  }
}
