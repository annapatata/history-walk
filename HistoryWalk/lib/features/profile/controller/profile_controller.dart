import 'package:get/get.dart';
import '../models/user_profile.dart';
import 'dart:io';
import 'package:image_picker/image_picker.dart';

class ProfileController extends GetxController {
  final ImagePicker _picker = ImagePicker();

  late Rx<UserProfile> userProfile;

  @override
  void onInit() {
    super.onInit();

    userProfile = UserProfile(
      name: 'Guest',
      nationality: 'Unknown',
      avatarPath: '',
      firstLoginDate: DateTime.now(),
      level: 1,
      progress: 0,
    ).obs;
  }

  Future<void> pickAvatarFromGallery() async {
    final XFile? image =
        await _picker.pickImage(source: ImageSource.gallery);

    if (image != null) {
      userProfile.value =
          userProfile.value.copyWith(avatarPath: image.path);
    }
  }

  Future<void> pickAvatarFromCamera() async {
    final XFile? image =
        await _picker.pickImage(source: ImageSource.camera);

    if (image != null) {
      userProfile.value =
          userProfile.value.copyWith(avatarPath: image.path);
    }
  }


  // =========================
  // User editable fields
  // =========================

  void updateName(String newName) {
    userProfile.value = userProfile.value.copyWith(
      name: newName,
    );
  }

  void updateNationality(String newNationality) {
    userProfile.value = userProfile.value.copyWith(
      nationality: newNationality,
    );
  }

  // =========================
  // STUBS (for later)
  // =========================

  void updateAvatar(String avatarPath) {
    userProfile.value = userProfile.value.copyWith(
      avatarPath: avatarPath,
    );
  }

  void updateProgress(int newProgress) {
    userProfile.value = userProfile.value.copyWith(
      progress: newProgress,
    );
  }
}
