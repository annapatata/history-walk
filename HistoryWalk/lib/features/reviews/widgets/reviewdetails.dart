import 'package:flutter/material.dart';
import 'package:historywalk/utils/theme/extensions/reviewtile_theme.dart';
import '../models/review_model.dart';

class ReviewDetails extends StatelessWidget {
  final ReviewModel review; // Assuming you have a model class

  const ReviewDetails({
    Key? key,
    required this.review
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final tileTheme = theme.extension<ReviewTileTheme>()!;

    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      child: ListView(
        padding: const EdgeInsets.all(16.0),
        children: [
          // Avatar Circle
          CircleAvatar(
            backgroundColor: Colors.brown, 
            radius: 40,
            child: const Icon(Icons.person, color: Colors.white, size: 40),
          ),
          const SizedBox(height: 16),
          
          // Review Content
          Text(
            review.userName,
          ),
          const SizedBox(height: 8),
          Text(
            review.text,
          ),
          const SizedBox(height: 16),
          // Photo Gallery if images exist
          if (review.images != null && review.images!.isNotEmpty) ...[
            SizedBox(
              height: 600,
              child: ListView.separated(
                scrollDirection: Axis.vertical,
                itemCount: review.images!.length,
                separatorBuilder: (context, index) => const SizedBox(width: 8),
                itemBuilder: (context, index) {
                  return ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: Image.network(
                      review.images![index],
                    ),
                  );
                },
              ),
            ),
            const SizedBox(height: 16),
          ],
        ],
      ),
    );
  }
}