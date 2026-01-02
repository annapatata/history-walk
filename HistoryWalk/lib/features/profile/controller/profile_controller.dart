import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:image_picker/image_picker.dart';

import '../models/user_profile.dart';

class ProfileController extends GetxController {
  final ImagePicker _picker = ImagePicker();
  final GetStorage _storage = GetStorage();

  static const String _userKey = 'user_profile';

  late Rx<UserProfile> userProfile;

  final List<String> presetAvatars = [
    'assets/avatars/avatar_1.png',
    'assets/avatars/avatar_2.png',
    'assets/avatars/avatar_3.png',
    'assets/avatars/avatar_4.png',
  ];

  @override
  void onInit() {
    super.onInit();
    _loadOrCreateUser();
  }

  void _loadOrCreateUser() {
    final data = _storage.read(_userKey);

    if (data != null) {
      userProfile = UserProfile.fromJson(
        Map<String, dynamic>.from(data),
      ).obs;
    } else {
      userProfile = UserProfile(
        name: 'Guest',
        nationality: 'Unknown',
        avatarPath: '',
        firstLoginDate: DateTime.now(),
        level: 1,
        progress: 0,
      ).obs;
      _saveUser();
    }
  }

  void _saveUser() {
    _storage.write(_userKey, userProfile.value.toJson());
  }

  // =========================
  // LEVEL LOGIC
  // =========================

  String get levelTitle {
    final progress = userProfile.value.progress;

    if (progress >= 75) return 'Master';
    if (progress >= 50) return 'Historian';
    if (progress >= 25) return 'Explorer';
    return 'Newcomer';
  }

  // =========================
  // Avatar
  // =========================

  Future<void> pickAvatarFromGallery() async {
    final image =
        await _picker.pickImage(source: ImageSource.gallery);

    if (image != null) {
      userProfile.value =
          userProfile.value.copyWith(avatarPath: image.path);
      _saveUser();
    }
  }

  Future<void> pickAvatarFromCamera() async {
    final image =
        await _picker.pickImage(source: ImageSource.camera);

    if (image != null) {
      userProfile.value =
          userProfile.value.copyWith(avatarPath: image.path);
      _saveUser();
    }
  }

  void selectPresetAvatar(String assetPath) {
    userProfile.value =
        userProfile.value.copyWith(avatarPath: assetPath);
    _saveUser();
  }

  // =========================
  // User fields
  // =========================

  void updateName(String newName) {
    userProfile.value =
        userProfile.value.copyWith(name: newName);
    _saveUser();
  }

  void updateNationality(String newNationality) {
    userProfile.value =
        userProfile.value.copyWith(nationality: newNationality);
    _saveUser();
  }

  void updateProgress(int newProgress) {
    userProfile.value =
        userProfile.value.copyWith(progress: newProgress);
    _saveUser();
  }
  // =========================
// PROGRESS SYSTEM
// =========================

void addProgress(int amount) {
  final current = userProfile.value.progress;
  final newProgress = (current + amount).clamp(0, 100);

  userProfile.value =
      userProfile.value.copyWith(progress: newProgress);

  _saveUser();
}

}
