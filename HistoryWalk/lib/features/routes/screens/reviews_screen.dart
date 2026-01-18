// Routes_screen.dart
import 'package:flutter/material.dart';
import 'package:historywalk/features/reviews/widgets/reviewtile.dart';
import 'package:historywalk/common/layouts/section_screen.dart';
import 'routedetails.dart';
import 'package:historywalk/features/reviews/widgets/reviewdetails.dart';
import '../../reviews/controller/review_controller.dart';
import 'package:get/get.dart';

class ReviewsScreen extends StatelessWidget {
  const ReviewsScreen({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    final ReviewController controller = Get.find();

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: Stack( // Wrap the layout in a Stack
          children: [
            SectionScreenLayout(
              title: 'REVIEWS',
              showSearch: false,
              body: Obx(()=>
               ListView.builder(
                itemCount: controller.reviews.length,
                itemBuilder: (context,index) {
                  final r = controller.reviews[index];
                  return ReviewTile(
                    review: r,
                    onTap: () => showDialog(
                      context: context,
                      builder: (BuildContext context) {
                        return ReviewDetails(review:r);
                      },
                    )
                  );
                },
               )),
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
    );
  }
}