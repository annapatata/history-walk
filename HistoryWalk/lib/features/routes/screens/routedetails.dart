import 'package:flutter/material.dart';
import 'package:historywalk/common/layouts/section_screen.dart';
import '../../routes/models/route_model.dart';
import '../../reviews/widgets/reviewtile.dart';
import '../../../utils/helpers/fullscreenimage.dart';
import '../../../common/widgets/primaryactionbutton.dart';
import 'package:historywalk/utils/constants/app_colors.dart';
import '../../reviews/widgets/writereview.dart';
import 'reviews_screen.dart';
import '../../map/screens/map_screen.dart';
import '../../map/controller/map_controller.dart';
import 'package:get/get.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../reviews/controller/review_controller.dart';
import '../../profile/controller/profile_controller.dart';

class RouteDetails extends StatelessWidget {
  RouteDetails({required this.route, super.key});
  final RouteModel route;
  final ReviewController reviewController = Get.find();
  final ProfileController profileController = Get.find();

  @override
  Widget build(BuildContext context) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      reviewController.fetchReviews(route.id);
    });
    final bool isCompleted = profileController.isRouteCompleted(route.id);
    final bool isReviewed =
        profileController.userProfile.value?.reviewedRoutes.contains(
          route.id,
        ) ??
        false;

    String buttonLabel = 'START ROUTE';
    if (isCompleted) {
      buttonLabel = isReviewed ? 'EDIT YOUR REVIEW' : 'WRITE A REVIEW';
    }
    return Scaffold(
      bottomNavigationBar: Container(
        padding: const EdgeInsets.all(16.0),
        color: Colors.transparent, // Or your background color
        child: PrimaryActionButton(
          label: buttonLabel,
          onPressed: () async {
            if (isCompleted) {
              showDialog(
                context: context,
                builder: (context) =>
                    WriteReviewModal(routeId: route.id, isEditing: isReviewed),
              );
            } else {
              final MapController mapController = Get.find();

              // 1. Trigger the fetch
              // 2. IMPORTANT: Use 'await' so we don't move to the next screen until data is here
              await mapController.loadRouteStops(route);

              // 3. Now navigate
              Get.to(() => MapScreen(selectedRoute: route));
            }
          },
          backgroundcolour: isCompleted
              ? AppColors.stars
              : AppColors.searchBarDark,
        ),
      ),

      body: Stack(
        children: [
          SectionScreenLayout(
            title: route.name,
            showSearch: false,
            body: ListView(
              padding: EdgeInsets.zero,
              children: [
                // Route description with character on left and speech bubble on right
                Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 20,
                  ),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      // Character Image on the left
                      Image.asset(
                        'assets/images/milowave.png',
                        width: 150,
                        height: 150,
                        fit: BoxFit.contain,
                      ),
                      // Text Bubble on the right
                      Expanded(
                        child: Container(
                          margin: const EdgeInsets.only(left: 0),
                          padding: const EdgeInsets.all(48),
                          decoration: BoxDecoration(
                            color: AppColors.searchBarDark,
                            borderRadius: const BorderRadius.only(
                              topRight: Radius.circular(40),
                              bottomRight: Radius.circular(40),
                              topLeft: Radius.circular(40),
                              bottomLeft: Radius.circular(
                                4,
                              ), // Sharp corner for bubble tail effect
                            ),
                            border: Border.all(
                              color: AppColors.searchBarLight,
                              width: 2,
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.1),
                                blurRadius: 8,
                                offset: const Offset(0, 4),
                              ),
                            ],
                          ),
                          child: Text(
                            route.description,
                            style: Theme.of(context).textTheme.bodyMedium
                                ?.copyWith(color: Colors.white, height: 1.4),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),

                Obx(() {
                  final allImages = reviewController.reviews
                      .expand((r) => r.images ?? [])
                      .toList();

                  if (allImages.isEmpty) return const SizedBox.shrink();
                  return Column(
                    children: [
                      Text(
                        'Photo Gallery (${allImages.length})',
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),

                      const SizedBox(height: 16),
                      SizedBox(
                        height: 110,
                        child: ListView.separated(
                          scrollDirection: Axis.horizontal,
                          itemCount: allImages.length,
                          separatorBuilder: (context, index) =>
                              const SizedBox(width: 8),
                          itemBuilder: (context, index) {
                            // Capture the specific image URL for this index
                            String imageUrl = allImages[index];

                            return GestureDetector(
                              onTap: () => Get.to(
                                () => FullScreenImage(imageUrl: imageUrl),
                              ),
                              child: Hero(
                                // Ensure the tag is unique by using the URL
                                tag: imageUrl,
                                child: ClipRRect(
                                  borderRadius: BorderRadius.circular(8),
                                  child: Image.network(
                                    imageUrl,
                                    fit: BoxFit.cover,
                                    width: 110,
                                  ),
                                ),
                              ),
                            );
                          },
                        ),
                      ),
                    ],
                  );
                }),

                const SizedBox(height: 16),

                Obx(() {
                  if (reviewController.isLoading.value) {
                    return const Center(child: CircularProgressIndicator());
                  }
                  return Column(
                    children: [
                      Container(
                        height: 30,
                        color: AppColors.stars,
                        child: Padding(
                          padding: const EdgeInsets.only(left: 10),
                          child: Align(
                            alignment: Alignment.centerLeft,
                            child: Text(
                              'Reviews (${reviewController.reviews.length})',
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ),
                      ),
                      ...reviewController.reviews
                          .take(3)
                          .map((r) => ReviewTile(review: r, onTap: () {})),

                      const SizedBox(height: 8),

                      if (reviewController.reviews.length > 3)
                        TextButton(
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => const ReviewsScreen(),
                              ),
                            );
                          },
                          child: const Text('See All Reviews'),
                        ),

                      const SizedBox(height: 20),
                    ],
                  );
                }),
              ],
            ),
          ),

          Positioned(
            top: MediaQuery.of(context).padding.top + 10,
            left: 10,
            child: IconButton(
              icon: const Icon(Icons.arrow_back, color: Colors.black),
              onPressed: () {
                Navigator.pop(context);
              },
            ),
          ),
        ],
      ),
    );
  }
}
