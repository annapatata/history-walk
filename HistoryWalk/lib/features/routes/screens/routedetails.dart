import 'package:flutter/material.dart';
import 'package:historywalk/common/layouts/section_screen.dart';
import '../../routes/models/route_model.dart';
import '../../reviews/widgets/reviewtile.dart';
import '../../reviews/models/review_model.dart';
import '../../../common/widgets/primaryactionbutton.dart';
import 'package:historywalk/utils/constants/app_colors.dart';
import '../../reviews/widgets/writereview.dart';
import 'reviews_screen.dart';

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
    images: ['https://hatrabbits.com/wp-content/uploads/2017/01/random.jpg']
  ),
  Review(
    id: '5',
    userName: 'Julius Coo.',
    rating: 3.0,
    text: 'I came, I saw.',
    images: ['https://hatrabbits.com/wp-content/uploads/2017/01/random.jpg', 'https://www.shutterstock.com/shutterstock/photos/2286554497/display_1500/stock-photo-random-pictures-cute-and-funny-2286554497.jpg', 'https://hatrabbits.com/wp-content/uploads/2017/01/random.jpg', 'https://www.shutterstock.com/shutterstock/photos/2286554497/display_1500/stock-photo-random-pictures-cute-and-funny-2286554497.jpg']
  ),
];

class RouteDetails extends StatelessWidget {
  RouteDetails({
    required this.route,
    super.key
  });

  static int reviews = dummyReviews.length;

  final RouteModel route;

  final allImages = dummyReviews
    .where((review) => review.images != null && review.images!.isNotEmpty)
    .expand((review) => review.images!)
    .toList();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      bottomNavigationBar: Container(
      padding: const EdgeInsets.all(16.0),
      color: Colors.transparent, // Or your background color
      child: PrimaryActionButton(
        label: 'START ROUTE',
        onPressed: () {
          // TODO: Navigate to map screen
        },
        backgroundcolour: AppColors.searchBarDark,
      ),
    ),

      body: Stack (
        children: [
          SectionScreenLayout(
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
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),

                const SizedBox(height: 8),

                if (allImages.isNotEmpty) ...[
                  SizedBox(
                    height: 110,
                    child: ListView.separated(
                      scrollDirection: Axis.horizontal,
                      itemCount: allImages.length,
                      separatorBuilder: (context, index) => const SizedBox(width: 8),
                      itemBuilder: (context, index) {
                        return ClipRRect(
                          borderRadius: BorderRadius.circular(8),
                          child: Image.network(
                            allImages[index],
                            fit: BoxFit.cover,
                            width: 110,
                          ),
                        );
                      },
                    ),
                  ),
                  const SizedBox(height: 16),
                ],

                const SizedBox(height: 16),

                Container(
                  height: 30,
                  color: AppColors.stars,
                  child: Padding(
                    padding: const EdgeInsets.only(left: 10),
                    child: Align(
                      alignment: Alignment.centerLeft,
                      child: Text(
                        'Reviews ($reviews)',
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 8),

                ReviewTile(review: dummyReviews[0], onTap: () {}),
                ReviewTile(review: dummyReviews[1], onTap: () {}),
                ReviewTile(review: dummyReviews[2], onTap: () {}),

                if(dummyReviews.length > 3)
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
      )
      );
  }
}