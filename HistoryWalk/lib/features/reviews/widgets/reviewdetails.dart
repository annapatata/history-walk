import 'package:flutter/material.dart';
import 'package:historywalk/utils/theme/extensions/reviewtile_theme.dart';
import '../models/review_model.dart';
import '../../profile/controller/profile_controller.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../controller/review_controller.dart';
import '../../../utils/helpers/fullscreenimage.dart';
import 'writereview.dart';

class ReviewDetails extends StatelessWidget {
  final ReviewModel review;
  final ProfileController profileController = Get.find();
  final ReviewController reviewController = Get.find();

  ReviewDetails({super.key, required this.review});

  @override
  Widget build(BuildContext context) {
    final String formattedDate = DateFormat(
      'yyyy-MM-dd – kk:mm',
    ).format(review.createdAt);

    // CURRENT LOGGED IN USER
    final myProfile = profileController.userProfile.value;
    final bool isOwner = myProfile?.uid == review.userId;

    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      // Constraints make the dialog look better on wide screens
      child: Container(
        constraints: const BoxConstraints(maxWidth: 400),
        padding: const EdgeInsets.all(20.0),
        child: Column(
          // Use Column + MainAxisSize.min for a centered, wrapping box
          mainAxisSize: MainAxisSize.min,
          children: [
            // --- DYNAMIC AVATAR FETCH ---
            FutureBuilder<DocumentSnapshot>(
              future: FirebaseFirestore.instance
                  .collection('users')
                  .doc(review.userId)
                  .get(),
              builder: (context, snapshot) {
                String? fetchedAvatar;
                if (snapshot.hasData && snapshot.data!.exists) {
                  final data = snapshot.data!.data() as Map<String, dynamic>;
                  fetchedAvatar = data['avatarPath'];
                }

                return CircleAvatar(
                  radius: 40,
                  backgroundColor: Colors.brown.shade100,
                  // FIX: Use fetchedAvatar here, NOT myProfile
                  backgroundImage:
                      (fetchedAvatar != null &&
                          fetchedAvatar.startsWith('http'))
                      ? NetworkImage(fetchedAvatar)
                      : AssetImage(fetchedAvatar ?? 'assets/icons/no_pfp.png')
                            as ImageProvider,
                );
              },
            ),

            const SizedBox(height: 16),
            Text(
              "@${review.userName}",
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
            ),
            Text(
              formattedDate,
              style: const TextStyle(color: Colors.grey, fontSize: 12),
            ),
            const SizedBox(height: 16),

            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(5, (index) {
                return Icon(
                  index < review.rating ? Icons.star : Icons.star_border,
                  color: const Color(0xFFE5B132),
                  size: 20,
                );
              }),
            ),
            Text(review.text, textAlign: TextAlign.center),
            const SizedBox(height: 20),

            // --- HORIZONTAL PHOTO GALLERY ---
            if (review.images != null && review.images!.isNotEmpty) ...[
              const Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  "Photos",
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
              ),
              const SizedBox(height: 8),
              SizedBox(
                height: 120, // Smaller, fixed height for horizontal scroll
                child: ListView.separated(
                  scrollDirection: Axis.horizontal,
                  itemCount: review.images!.length,
                  separatorBuilder: (context, index) =>
                      const SizedBox(width: 10),
                  itemBuilder: (context, index) {
                    final imageUrl = review.images![index];
                    return GestureDetector(
                      onTap: () =>
                          Get.to(() => FullScreenImage(imageUrl: imageUrl)),
                      child: Hero(
                        tag: imageUrl,
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(12),
                          child: Image.network(
                            imageUrl,
                            width: 120,
                            height: 120,
                            fit: BoxFit.cover,
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),
              const SizedBox(height: 20),
            ],

            // --- OWNER ACTIONS ---
            if (isOwner) ...[
              const Divider(),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  TextButton.icon(
                    onPressed: () {
                      Get.back(); // Close this dialog
                      showDialog(
                        context: context,
                        builder: (context) => WriteReviewModal(
                          routeId: review.routeId,
                          isEditing: true,
                        ),
                      );
                    },
                    icon: const Icon(Icons.edit, size: 18),
                    label: const Text("Edit"),
                  ),
                  TextButton.icon(
                    onPressed: () => _confirmDelete(context, myProfile!.uid),
                    icon: const Icon(
                      Icons.delete_outline,
                      color: Colors.red,
                      size: 18,
                    ),
                    label: const Text(
                      "Delete",
                      style: TextStyle(color: Colors.red),
                    ),
                  ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }

  void _confirmDelete(BuildContext context, String uid) {
    Get.defaultDialog(
      title: "Delete Review?",
      middleText: "This action cannot be undone.",
      textConfirm: "Delete",
      confirmTextColor: Colors.white,
      buttonColor: const Color.fromRGBO(244, 67, 54, 1),
      onConfirm: () {
        Get.back();
        reviewController.deleteReview(review.id, review.routeId, uid);
      },
      textCancel: "Cancel",
    );
  }
}
