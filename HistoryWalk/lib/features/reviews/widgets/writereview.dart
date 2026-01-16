import 'package:flutter/material.dart';
import 'package:historywalk/features/profile/controller/profile_controller.dart';
import 'package:historywalk/features/reviews/controller/review_controller.dart';
import 'package:historywalk/common/widgets/primaryactionbutton.dart';
import 'starrating.dart';
import 'package:get/get.dart';
import '../models/review_model.dart';
import 'dart:io';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';

class WriteReviewModal extends StatefulWidget {
  final String routeId;
  final bool isEditing;
  const WriteReviewModal({
    super.key,
    required this.routeId,
    this.isEditing = false,
  });

  @override
  State<WriteReviewModal> createState() => _WriteReviewModalState();
}

class _WriteReviewModalState extends State<WriteReviewModal> {
  //we use late because we will initialize these in initState
  late int _userRating = 0;
  late TextEditingController _textController = TextEditingController();

  final ReviewController reviewController = Get.find();
  final ProfileController profileController = Get.find();

  final ImagePicker _picker = ImagePicker();
  List<File> _selectedImages = []; //store local files before upload
  List<String> _existingImageUrls=[];

  @override
  void initState() {
    super.initState();
    _userRating = 0;
    _textController = TextEditingController();

    //autofill
    if (widget.isEditing) {
      final userId = profileController.userProfile.value?.uid;
      if (userId != null) {
        final existing = reviewController.getExistingReview(
          userId,
          widget.routeId,
        );
        if (existing != null) {
          _userRating = existing.rating.toInt();
          _textController.text = existing.text;
          _existingImageUrls = existing.images!.cast<String>();
        }
      }
    }
  }

  @override
  void dispose() {
    _textController.dispose();
    super.dispose();
  }

  Future<void> _pickImage(ImageSource source) async {
    final XFile? pickedFile = await _picker.pickImage(
      source: source,
      imageQuality: 70,
    );
    if (pickedFile != null) {
      setState(() {
        _selectedImages.add(File(pickedFile.path));
      });
    }
  }

  Future<List<String>> _uploadImages() async {
    List<String> imageUrls = [];
    for (var image in _selectedImages) {
      String fileName =
          'reviews/${DateTime.now().millisecondsSinceEpoch}_${_selectedImages.indexOf(image)}.jpg';
      TaskSnapshot snapshot = await FirebaseStorage.instance
          .ref()
          .child(fileName)
          .putFile(image);
      String downloadUrl = await snapshot.ref.getDownloadURL();
      imageUrls.add(downloadUrl);
    }
    return imageUrls;
  }

  void _handleSubmit() async {
  final user = profileController.userProfile.value;
  if (_userRating == 0 || user == null) return; // Add your snackbars here

  try {
    reviewController.isLoading.value = true; // Start loading early

    // 1. Upload images to Firebase Storage first
    List<String> newUploadedUrls = await _uploadImages();

    List<String> finalImageUrls = [..._existingImageUrls,...newUploadedUrls];
    // 2. Create the model with the new image URLs
    final newReview = ReviewModel(
      id: '',
      userName: user.name,
      userId: user.uid,
      routeId: widget.routeId,
      rating: _userRating.toDouble(),
      text: _textController.text.trim(),
      createdAt: DateTime.now(),
      images: finalImageUrls, 
    );

    await reviewController.saveOrUpdateReview(newReview, widget.isEditing);
    
    if (profileController.userProfile.value != null) {
      var updatedList = List<String>.from(
        profileController.userProfile.value!.reviewedRoutes,
      );
      if (!updatedList.contains(widget.routeId)) {
        updatedList.add(widget.routeId);

        // Use copyWith to trigger GetX update
        profileController.userProfile.value = profileController
            .userProfile
            .value!
            .copyWith(reviewedRoutes: updatedList);
      }
    }
    if (mounted) Navigator.pop(context);
  } catch (e) {
    Get.snackbar("Error", "Failed to upload images: $e");
  } finally {
    reviewController.isLoading.value = false;
  }
}

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      backgroundColor: const Color(0xFFFFF9EE),
      insetPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
      child: AnimatedContainer(
        duration: const Duration(
          milliseconds: 300,
        ), // Prevents overflow when keyboard appears
        child: SingleChildScrollView(
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
                child: Text(
                  widget.isEditing
                      ? "Update your review"
                      : "How was your walk?",
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
              ),

              Padding(
                padding: const EdgeInsets.all(20.0),
                child: Column(
                  children: [
                    // Interactive Stars
                    StarRatingInput(
                      initialRating: _userRating,
                      onRatingChanged: (rating) {
                        _userRating = rating;
                      },
                    ),

                    const SizedBox(height: 20),

                    // Text Area
                    TextFormField(
                      controller: _textController,
                      maxLines: 6,
                      decoration: InputDecoration(
                        hintText:
                            "What did you learn? Did you find the information too generic?",
                        hintStyle: const TextStyle(
                          fontSize: 12,
                          color: Colors.black54,
                        ),
                        filled: true,
                        fillColor: const Color(0xFFF3C089).withOpacity(0.6),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                          borderSide: BorderSide.none,
                        ),
                      ),
                    ),
                    const SizedBox(height: 10),
                    Row(
                      children: [
                        IconButton(
                          icon: const Icon(Icons.camera_alt),
                          onPressed: () => _pickImage(ImageSource.camera),
                        ),
                        IconButton(
                          icon: const Icon(Icons.photo_library),
                          onPressed: () => _pickImage(ImageSource.gallery),
                        ),
                        const Text(
                          "Add Photos",
                          style: TextStyle(fontSize: 12),
                        ),
                      ],
                    ),
                    if (_existingImageUrls.isNotEmpty || _selectedImages.isNotEmpty)
  SizedBox(
    height: 90,
    child: ListView(
      scrollDirection: Axis.horizontal,
      children: [
        // 1. Show Existing Network Images
        ..._existingImageUrls.map((url) => _buildImagePreview(url, isNetwork: true)),
        
        // 2. Show New Local Files
        ..._selectedImages.map((file) => _buildImagePreview(file, isNetwork: false)),
      ],
    ),
  ),
                    const SizedBox(height: 20),

                    Obx(
                      () => reviewController.isLoading.value
                          ? const CircularProgressIndicator()
                          : PrimaryActionButton(
                              label: 'SUBMIT',
                              onPressed: _handleSubmit,
                              backgroundcolour: const Color(0xFF4E2308),
                            ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }


Widget _buildImagePreview(dynamic source, {required bool isNetwork}) {
  return Padding(
    padding: const EdgeInsets.only(right: 8.0),
    child: Stack(
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(8),
          child: isNetwork 
            ? Image.network(source as String, width: 80, height: 80, fit: BoxFit.cover)
            : Image.file(source as File, width: 80, height: 80, fit: BoxFit.cover),
        ),
        Positioned(
          right: 0,
          top: 0,
          child: GestureDetector(
            onTap: () {
              setState(() {
                isNetwork 
                  ? _existingImageUrls.remove(source) 
                  : _selectedImages.remove(source);
              });
            },
            child: const CircleAvatar(
              radius: 10, 
              backgroundColor: Colors.red, 
              child: Icon(Icons.close, size: 12, color: Colors.white)
            ),
          ),
        ),
      ],
    ),
  );
}
}