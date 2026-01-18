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
                _buildAnimatedRouteTimeline(route),

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

Widget _buildAnimatedRouteTimeline(RouteModel route) {
  final stops = route.mapstops;
  if (stops.isEmpty) return const SizedBox.shrink();

  // Use a Future.delayed to wait for the page transition to finish (approx 300-500ms)
  return FutureBuilder(
    future: Future.delayed(const Duration(milliseconds: 600)), 
    builder: (context, snapshot) {
      // While waiting, show the "empty" gray line so the layout doesn't jump
      if (snapshot.connectionState == ConnectionState.waiting) {
        return _buildStaticBaseLine(stops.length);
      }

      return TweenAnimationBuilder<double>(
        duration: const Duration(milliseconds: 90000), // Slower for better effect
        curve: Curves.easeOutCubic,
        tween: Tween<double>(begin: 0.0, end: 1.0),
        builder: (context, value, child) {
          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 20),
            child: Stack(
              alignment: Alignment.centerLeft,
              children: [
                // 1. Background Gray Line
                Container(height: 2, width: double.infinity, color: Colors.grey[200]),
                
                // 2. The Gold Drawing Line
                LayoutBuilder(builder: (context, constraints) {
                  return Container(
                    height: 2,
                    width: constraints.maxWidth * value,
                    color: const Color(0xFFE9B32A),
                  );
                }),

                // 3. The Pins and Text
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: List.generate(stops.length, (index) {
                    // Logic: Each pin appears when the line is 90% of the way to it
                    double stopPosition = index / (stops.length - 1);
                    bool isReached = value >= (stopPosition * 0.9);

                    return AnimatedScale(
                      duration: const Duration(milliseconds: 400),
                      scale: isReached ? 1.0 : 0.0,
                      curve: Curves.elasticOut,
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Container(
                            width: 12,
                            height: 12,
                            decoration: BoxDecoration(
                              color: const Color(0xFFE9B32A),
                              shape: BoxShape.circle,
                              border: Border.all(color: Colors.white, width: 2),
                              boxShadow: const [BoxShadow(blurRadius: 2, color: Colors.black12)]
                            ),
                          ),
                          const SizedBox(height: 8),
                          SizedBox(
                            width: 50,
                            child: Text(
                              stops[index].name,
                              textAlign: TextAlign.center,
                              style: const TextStyle(fontSize: 9, fontWeight: FontWeight.w600),
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                    );
                  }),
                ),
              ],
            ),
          );
        },
      );
    },
  );
}

// Helper to prevent layout jumping while waiting for delay
Widget _buildStaticBaseLine(int stopCount) {
  return Padding(
    padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 20),
    child: Stack(
      children: [
        Container(height: 2, width: double.infinity, color: Colors.grey[200]),
        const SizedBox(height: 40), // Height of the text area
      ],
    ),
  );
}