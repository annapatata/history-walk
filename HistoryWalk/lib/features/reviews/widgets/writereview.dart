import 'package:flutter/material.dart';
import 'package:historywalk/utils/constants/app_colors.dart';
import 'package:historywalk/common/widgets/primaryactionbutton.dart';
import 'starrating.dart';

class WriteReviewModal extends StatefulWidget {
  const WriteReviewModal({super.key});

  @override
  State<WriteReviewModal> createState() => _WriteReviewModalState();
}

class _WriteReviewModalState extends State<WriteReviewModal> {
  int _userRating = 0;
  final TextEditingController _textController = TextEditingController();

  void _handleSubmit() {
    final reviewText = _textController.text;
    // You can now send _userRating and reviewText to your backend/database
    print("Rating: $_userRating, Review: $reviewText");
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      backgroundColor: const Color(0xFFFFF9EE),
      child: SingleChildScrollView( // Prevents overflow when keyboard appears
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Header
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 16),
              decoration: const BoxDecoration(
                color: Color(0xFFF9C784),
                borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
              ),
              child: const Text(
                "How was your walk?",
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
            ),
            
            Padding(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                children: [
                  // Interactive Stars
                  StarRatingInput(onRatingChanged: (rating) {
                    _userRating = rating;
                  }),
                  
                  const SizedBox(height: 20),

                  // Text Area
                  TextFormField(
                    controller: _textController,
                    maxLines: 6,
                    decoration: InputDecoration(
                      hintText: "What did you learn? Did you find the information too generic?",
                      hintStyle: const TextStyle(fontSize: 12, color: Colors.black54),
                      filled: true,
                      fillColor: const Color(0xFFF3C089).withOpacity(0.6),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide: BorderSide.none,
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),

                  PrimaryActionButton(
                    label: 'SUBMIT',
                    onPressed: _handleSubmit,
                    backgroundcolour: const Color(0xFF4E2308),
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