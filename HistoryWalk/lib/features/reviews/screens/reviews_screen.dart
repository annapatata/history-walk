// Reviews_screen.dart
import 'package:flutter/material.dart';
import 'package:historywalk/features/routes/widgets/route_box.dart';
import '../../routes/models/time_period.dart';
import '../widgets/reviewtile.dart';
import '../models/review_model.dart';
import '../../../common/widgets/primaryactionbutton.dart';


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
  const ReviewsScreen({super.key});

  static const int reviews = 256;

  @override
  Widget build(BuildContext context) {
    return Scaffold( // <--- Added Scaffold for proper structure
      backgroundColor: const Color(0xFFF6E7D2), // Your background color
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 0), // Handled padding inside children usually, but 0 here to let headers touch edges
        child: Column(
          children: [
            // Screen title
            const Padding(
              padding: EdgeInsets.only(top: 40, bottom: 8),
              child: Center(child: Text('REVIEWS')),
            ),

            // Search bar
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 50, vertical: 10),
              child: Container(
                height: 30,
                color: const Color.fromARGB(241, 238, 186, 97),
                child: const Align(
                  alignment: Alignment.centerLeft,
                  child: Row(
                    children: [
                      SizedBox(width: 5),
                      Icon(Icons.search, color: Colors.brown),
                      SizedBox(width: 5),
                      Text('Search for...',
                          style: TextStyle(
                              color: Colors.black, fontWeight: FontWeight.bold)),
                    ],
                  ),
                ),
              ),
            ),
            
            // Route Box
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 50),
              child: RouteBox(
                title: "Echoes of Rome",
                image: "icons/image.png",
                timePeriod: TimePeriod(startYear: -10, endYear: 130),
                duration: const Duration(minutes: 45),
                difficulty: "Cakewalk",
                stops: const ["Roman Agora", "Hadrian's Library", "Temple of Zeus"],
                stars: 4,
                reviewCount: reviews,
              ),
            ),

            // Write a Review Button
          PrimaryActionButton(
            label: 'Write a Review',
            onPressed:()=> print("Clicked Review 2"), 
            backgroundcolour: Color(0xFFECAE35)
            ),

            // Gallery Header
            const Padding(
              padding: EdgeInsets.only(left: 50, bottom: 5),
              child: Align(
                alignment: Alignment.centerLeft,
                child: Text('Photo Gallery (11)',
                    style: TextStyle(
                        color: Colors.black, fontWeight: FontWeight.bold)),
              ),
            ),

            // Horizontal Images Scroll
            // FIXED: Removed width: 2000 and Removed Expanded from inside Container
            Container(
              height: 110,
              width: double.infinity, // <--- Allows container to fill screen width
              color: Colors.white,
              child: ListView(
                padding: const EdgeInsets.symmetric(horizontal: 50), // Match your page padding
                scrollDirection: Axis.horizontal,
                children: const [
                  Icon(Icons.image, size: 100),
                  Icon(Icons.image, size: 100),
                  Icon(Icons.image, size: 100),
                  Icon(Icons.image, size: 100),
                  Icon(Icons.image, size: 100),
                ],
              ),
            ),

            const SizedBox(height: 10),

            // Reviews Header
            Container(
              height: 30,
              margin: const EdgeInsets.symmetric(horizontal: 50),
              color: const Color.fromARGB(240, 238, 166, 41),
              child: const Align(
                alignment: Alignment.centerLeft,
                child: Padding(
                  padding: EdgeInsets.only(left: 10),
                  child: Text('Reviews ($reviews)',
                      style: TextStyle(
                          color: Colors.black, fontWeight: FontWeight.bold)),
                ),
              ),
            ),

            // Reviews List
            Expanded( // <--- This Expanded is correct (inside Column)
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 45), // Adjusted to align with header
                child: ListView(
                  padding: EdgeInsets.zero, // Remove top padding from list
                  children: [
                    // FIXED: Added onTap parameter to all ReviewTiles
                    ReviewTile(
                      review: dummyReviews[0],
                      onTap: () => print("Clicked Review 1"), 
                    ),
                    ReviewTile(
                      review: dummyReviews[1],
                      onTap: () => print("Clicked Review 2"),
                    ),
                    ReviewTile(
                      review: dummyReviews[2],
                      onTap: () => print("Clicked Review 3"),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
