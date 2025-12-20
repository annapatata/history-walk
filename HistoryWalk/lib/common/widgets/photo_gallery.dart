import 'package:flutter/material.dart';

class PhotoGallery extends StatelessWidget {
  const PhotoGallery({
    required this.imageUrls,
    this.height = 110,
    super.key,
  });

  final List<String> imageUrls;
  final double height;

  @override
  Widget build(BuildContext context) {
    if (imageUrls.isEmpty) {
      return const Text(
        'No photos yet',
        style: TextStyle(color: Colors.grey),
      );
    }

    return SizedBox(
      height: height,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: imageUrls.length,
        separatorBuilder: (_, __) => const SizedBox(width: 8),
        itemBuilder: (context, index) {
          return ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: AspectRatio(
              aspectRatio: 1,
              child: Image.network(
                imageUrls[index],
                fit: BoxFit.cover,
                loadingBuilder: (context, child, loadingProgress) {
                  if (loadingProgress == null) return child;
                  return const Center(child: CircularProgressIndicator());
                },
                errorBuilder: (_, __, ___) =>
                    const Icon(Icons.broken_image),
              ),
            ),
          );
        },
      ),
    );
  }
}
