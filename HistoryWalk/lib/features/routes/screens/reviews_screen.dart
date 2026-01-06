// Routes_screen.dart
import 'package:flutter/material.dart';
import 'package:historywalk/features/reviews/widgets/reviewtile.dart';
import 'package:historywalk/common/layouts/section_screen.dart';
import 'routedetails.dart';
import 'package:historywalk/features/reviews/widgets/reviewdetails.dart';


class ReviewsScreen extends StatelessWidget {
  const ReviewsScreen({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: Material(
        color: Theme.of(context).scaffoldBackgroundColor,
        child: Stack( // Wrap the layout in a Stack
          children: [
            SectionScreenLayout(
              title: 'REVIEWS',
              body: ListView(
                padding: EdgeInsets.zero,
                children: [
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 8.0),
                    child: Column(
                      children: [
                        for (var r in dummyReviews) ...[
                          ReviewTile(
                            review: r, 
                            onTap: () {
                              showDialog(
                                context: context,
                                builder: (BuildContext context) {
                                  return ReviewDetails(review: r);
                                },
                              );
                            },
                          ),
                          const SizedBox(height: 8),
                        ],
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),
                ],
              ),
            ),

            // --- THE RETURN BUTTON ---
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
      ),
    );
  }
}