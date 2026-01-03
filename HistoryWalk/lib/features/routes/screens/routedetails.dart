import 'package:flutter/material.dart';
import 'package:historywalk/common/layouts/section_screen.dart';
import '../../routes/models/route_model.dart';
import '../../reviews/widgets/reviewtile.dart';
import '../../reviews/models/review_model.dart';
import '../../../common/widgets/primaryactionbutton.dart';
import '../../../common/widgets/photo_gallery.dart';
import 'package:historywalk/utils/constants/app_colors.dart';
import '../../reviews/widgets/writereview.dart';

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
  Review(
    id: '4',
    userName: 'Julius Caa.',
    rating: 3.0,
    text: 'I came.',
  ),
  Review(
    id: '5',
    userName: 'Julius Coo.',
    rating: 3.0,
    text: 'I came, I saw.',
  ),
];

class RouteDetails extends StatelessWidget {
  const RouteDetails({
    required this.route,
    super.key
  });

  static const int reviews = 255;

  final RouteModel route;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SectionScreenLayout(
        title: route.name,
        showSearch: false,
        body: ListView(
          padding: EdgeInsets.zero,
          children: [
            // Route description with character on left and speech bubble on right
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 20),
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
                          bottomLeft: Radius.circular(4), // Sharp corner for bubble tail effect
                        ),
                        border: Border.all(color: AppColors.searchBarLight, width: 2),
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
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                              color: Colors.white,
                              height: 1.4,
                            ),
                      ),
                    ),
                  ),
                ],
              ),
            ),


            const SizedBox(height: 20),

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
                backgroundcolour: AppColors.searchBarDark,
              ),
            ),

            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }
}