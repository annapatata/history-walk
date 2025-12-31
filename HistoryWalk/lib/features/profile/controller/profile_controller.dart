import 'package:get/get.dart';
import '../models/user_profile.dart';

class ProfileController extends GetxController {
  /// Observable user profile
  late Rx<UserProfile> userProfile;

  @override
  void onInit() {
    super.onInit();

    /// Mock initial data
    userProfile = UserProfile(
      name: 'Guest',
      nationality: 'Unknown',
      avatarPath: 'assets/avatars/default.png', // STUB
      firstLoginDate: DateTime.now(),
      level: 1, // STUB
      progress: 0, // STUB
    ).obs;
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
