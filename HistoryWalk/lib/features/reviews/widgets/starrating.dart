import "package:flutter/material.dart";

class StarRatingInput extends StatefulWidget {
  final Function(int) onRatingChanged;
  const StarRatingInput({super.key, required this.onRatingChanged});

  @override
  State<StarRatingInput> createState() => _StarRatingInputState();
}

class _StarRatingInputState extends State<StarRatingInput> {
  int _currentRating = 0;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(5, (index) {
        return IconButton(
          padding: EdgeInsets.zero,
          icon: Icon(
            index < _currentRating ? Icons.star : Icons.star_border,
            size: 40,
            color: const Color(0xFFE5B132),
          ),
          onPressed: () {
            setState(() {
              _currentRating = index + 1;
            });
            widget.onRatingChanged(_currentRating);
          },
        );
      }),
    );
  }
}