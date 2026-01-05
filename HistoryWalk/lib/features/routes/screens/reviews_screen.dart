// Routes_screen.dart
import 'package:flutter/material.dart';
import 'package:historywalk/features/reviews/widgets/reviewtile.dart';
import '../widgets/route_box.dart';
import '../models/time_period.dart';
import 'package:historywalk/common/layouts/section_screen.dart';
import '../models/route_model.dart';
import 'routedetails.dart';
import 'package:historywalk/features/reviews/widgets/reviewdetails.dart';
import 'package:historywalk/features/reviews/models/review_model.dart';

// Screen Class
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
        child: SectionScreenLayout(
          title: 'REVIEWS',
          body: ListView(
            padding: EdgeInsets.zero,
            children: [
              // Reviews list
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8.0),
                child: Column(
                  children: [
                    for (var r in dummyReviews) ...[
                      ReviewTile(review: r, onTap: () {
                        showDialog(
                          context: context,
                          builder: (BuildContext context) {
                            return ReviewDetails(review: r);
                          },
                        );
                      },),
                      const SizedBox(height: 8),
                    ],
                  ],
                ),
              ),

              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }
}
