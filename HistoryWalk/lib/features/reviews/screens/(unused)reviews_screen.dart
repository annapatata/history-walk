// Reviews_screen.dart
import 'package:flutter/material.dart';
import 'package:historywalk/common/layouts/section_screen.dart';
import '../../routes/models/route_model.dart';
import '../widgets/reviewtile.dart';
import '../models/review_model.dart';
import '../../../common/widgets/primaryactionbutton.dart';
import '../../../common/widgets/photo_gallery.dart';
import 'package:historywalk/utils/constants/app_colors.dart';
import '../widgets/writereview.dart';

// Your dummy data remains the same
final List<Review> dummyReviews = [
  Review(
    id: '1',
    userName: 'Marcus A.',
    rating: 4.0,
    text: 'what happens in the Roman Agora stays in the Roman Agora. Great tour!',
  ),
  Review(
    id: '2',
    userName: 'Cleopatra',
    rating: 5.0,
    text: 'Absolutely stunning views. The history really comes alive here.',
  ),
  Review(
    id: '3',
    userName: 'Julius C.',
    rating: 3.0,
    text: 'I came, I saw, I walked a lot. Good exercise but bring water.',
  ),
];

class ReviewsScreen extends StatelessWidget {
  const ReviewsScreen({
    required this.route,
    super.key
  });

  static const int reviews = 255;

  final RouteModel route;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SectionScreenLayout(
        title: 'REVIEWS',
        body: ListView(
          padding: EdgeInsets.zero,
          children: [
            // Route description message at top
            Container(
              margin: const EdgeInsets.all(16),
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.grey.shade100,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.grey.shade300),
              ),
              child: Text(
                route.description,
                style: Theme.of(context).textTheme.bodyMedium,
              ),
            ),

            const SizedBox(height: 12),

            // Write a Review button - only show if user completed the route
            if (route.isCompleted)
              PrimaryActionButton(
                label: 'Write a Review',
                onPressed: () {
                  showDialog(
                    context: context,
                    builder: (BuildContext context) {
                      return const WriteReviewModal();
                    },
                  );
                },
                backgroundcolour: AppColors.stars,
              ),

            const SizedBox(height: 16),

            Text(
              'Photo Gallery (${route.imageUrl.length})',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),

            const SizedBox(height: 8),

            PhotoGallery(
              imageUrls: route.imageUrl,
            ),

            const SizedBox(height: 16),

            Container(
              height: 30,
              color: AppColors.stars,
              child: const Padding(
                padding: EdgeInsets.only(left: 10),
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    'Reviews ($reviews)',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                ),
              ),
            ),

            const SizedBox(height: 8),

            ReviewTile(review: dummyReviews[0], onTap: () {}),
            ReviewTile(review: dummyReviews[1], onTap: () {}),
            ReviewTile(review: dummyReviews[2], onTap: () {}),

            const SizedBox(height: 20),

            // START ROUTE button at bottom
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: PrimaryActionButton(
                label: 'START ROUTE',
                onPressed: () {
                  // TODO: Navigate to map screen
                  // Navigator.of(context).push(MaterialPageRoute(
                  //   builder: (context) => MapScreen(route: route),
                  // ));
                },
                backgroundcolour: AppColors.stars,
              ),
            ),

            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }
}
