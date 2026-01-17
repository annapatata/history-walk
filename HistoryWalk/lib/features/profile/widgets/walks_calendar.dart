import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controller/profile_controller.dart';

class WalksCalendar extends StatelessWidget {
  const WalksCalendar({
    super.key,
    required this.userName,
  });

  final String userName;

  @override
  Widget build(BuildContext context) {
  // Ensure this controller actually has the 'userMemories' list defined
  final controller = Get.find<ProfileController>();

  // Optional: Trigger fetch when this screen builds. 
  // (Ideally, put this in the Controller's onInit method instead)
  WidgetsBinding.instance.addPostFrameCallback((_) {
     controller.fetchUserMemories();
  });

  return Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Text(
        "$userName's walks through the past",
        style: Theme.of(context).textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
            ),
      ),
      const SizedBox(height: 12),
      SizedBox(
        height: 110,
        child: Obx(() {
          // FIX 1: Listen to the list variable, do not call the function here
          final images = controller.userMemories;

          if (images.isEmpty) {
            return const Center(
              child: Text(
                'No completed walks yet',
                style: TextStyle(color: Colors.grey),
              ),
            );
          }

          // Create a new reversed list to avoid modifying the original observable
          final orderedImages = images.reversed.toList();

          return ListView.separated(
            scrollDirection: Axis.horizontal,
            physics: const BouncingScrollPhysics(),
            itemCount: orderedImages.length,
            separatorBuilder: (_, __) => const SizedBox(width: 12),
            itemBuilder: (context, index) {
              final memory = orderedImages[index]; 
              
              // FIX 2: Pass the 'imageUrl' from the model
              // Ensure _RouteCard uses NetworkImage or Image.network
              return _RouteCard(imagePath: memory.imageUrl);
              },
            );
          }),
        ),
      ],
    );
  }
}

class _RouteCard extends StatelessWidget {
  const _RouteCard({
    required this.imagePath,
  });

  final String imagePath;

  @override
  Widget build(BuildContext context) {
    return AspectRatio(
      aspectRatio: 1, // τετράγωνο card
      child: ClipRRect(
        borderRadius: BorderRadius.circular(14),
        child: Image.asset(
          imagePath,
          fit: BoxFit.cover,
        ),
      ),
    );
  }
}
