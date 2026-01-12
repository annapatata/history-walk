import 'package:flutter/material.dart';
import 'package:get_storage/get_storage.dart';
import 'package:historywalk/features/profile/controller/profile_controller.dart';
import 'package:historywalk/features/reviews/controller/review_controller.dart';
import 'package:historywalk/utils/constants/app_colors.dart';
import 'package:historywalk/common/widgets/primaryactionbutton.dart';
import 'package:image_picker/image_picker.dart';
import 'starrating.dart';
import 'package:get/get.dart';
import '../models/review_model.dart';

class WriteReviewModal extends StatefulWidget {
  final String routeId;
  final bool isEditing;
  const WriteReviewModal({super.key,required this.routeId, this.isEditing=false});
  

  @override
  State<WriteReviewModal> createState() => _WriteReviewModalState();
}

class _WriteReviewModalState extends State<WriteReviewModal> {
  //we use late because we will initialize these in initState
  late int _userRating = 0;
  late TextEditingController _textController = TextEditingController();

  final ReviewController reviewController = Get.find();
  final ProfileController profileController = Get.find();

  @override
  void initState(){
    super.initState();
    _userRating=0;
    _textController=TextEditingController();

    //autofill
    if(widget.isEditing){
      final userId = profileController.userProfile.value?.uid;
      if(userId!=null){
        final existing = reviewController.getExistingReview(userId,widget.routeId);
        if(existing!=null){
          _userRating = existing.rating.toInt();
          _textController.text = existing.text;
        }
      }
    }
  }
  @override 
  void dispose(){
    _textController.dispose();
    super.dispose();
  }
  void _handleSubmit() async {
    final reviewText = _textController.text.trim();
    final user = profileController.userProfile.value;

    if(_userRating==0) {
      Get.snackbar("Rating Required", "Please select at least one star");
      return;
    }

    if(user==null){
      Get.snackbar("You must be logged in to review","log in");
      return;
    }
    //create the ReviewModel object
    final newReview = ReviewModel(
      id:'',
      userName: user.name,
      userId : user.uid,
      routeId: widget.routeId,
      rating: _userRating.toDouble(),
      text: reviewText,
      createdAt: DateTime.now(),
      images: [],
    );


    await reviewController.saveOrUpdateReview(newReview,widget.isEditing);
    if(mounted) Navigator.pop(context);
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
              child:  Text(
                widget.isEditing ? "Update your review":
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
                  StarRatingInput(
                    initialRating: _userRating,
                    onRatingChanged: (rating) {
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
                Obx(()=> reviewController.isLoading.value
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
    );
  }
}