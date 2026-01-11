import 'package:flutter/material.dart';
import 'package:historywalk/utils/theme/extensions/reviewtile_theme.dart';
import '../models/review_model.dart';
import 'reviewdetails.dart';

class ReviewTile extends StatelessWidget {
  final ReviewModel review; 
  final VoidCallback onTap;

  const ReviewTile({
    Key? key, 
    required this.review, 
    required this.onTap
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final tileTheme = theme.extension<ReviewTileTheme>()!;

    return GestureDetector(
      onTap: () {
        showDialog(
          context: context,
          builder: (BuildContext context) {
            return ReviewDetails(review: review);
          },
        );
      },
      child: Container(
        // 1. Add padding so the text doesn't sit right on the line
        padding: const EdgeInsets.symmetric(vertical: 12.0, horizontal: 16.0),
        
        // 2. Use decoration to create the "shadowy line"
        decoration: BoxDecoration(
          // This creates the bottom line
          border: Border(
            bottom: BorderSide(
              color: Colors.brown.withOpacity(0.2), // A soft, shadowy brown line
              width: 1.5,
            ),
          ),
          // Optional: Adds a subtle glow underneath for extra "shadow" feel
          boxShadow: [
            BoxShadow(
              color: Colors.brown.withOpacity(0.05),
              blurRadius: 5,
              offset: const Offset(0, 4), // Pushes the shadow down
            ),
          ],
        ),
        
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Avatar Circle
            CircleAvatar(
              backgroundColor: Colors.brown, 
              radius: 24,
              child: const Icon(Icons.person, color: Colors.white),
            ),
            const SizedBox(width: 16),
            
            // Review Content
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Star Rating Row
                  Row(
                    children: List.generate(5, (index) {
                      return Icon(
                        index < review.rating ? Icons.star : Icons.star_border,
                        color: tileTheme.starColor,
                        size: 20,
                      );
                    }),
                  ),
                  const SizedBox(height: 4),
                  // Review Text
                  Text(
                    review.text,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(color: tileTheme.textColor),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}