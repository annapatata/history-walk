import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:get_storage/get_storage.dart';

import '../models/user_profile.dart';
import '../models/badge.dart';

class ProfileController extends GetxController {
  final ImagePicker _picker = ImagePicker();
  final GetStorage _box = GetStorage();

  static const String _userKey = 'user_profile';
  static const String _badgesKey = 'user_badges';

  late Rx<UserProfile> userProfile;

  // 🏅 Badges
  final RxList<Badge> badges = <Badge>[].obs;

  // 🧑 Preset avatars
  final List<String> presetAvatars = [
    'assets/avatars/avatar_1.png',
    'assets/avatars/avatar_2.png',
    'assets/avatars/avatar_3.png',
  ];

  @override
  void onInit() {
    super.onInit();
    _loadOrCreateUser();
    _initBadges();
  }

  // =========================
  // USER PROFILE
  // =========================

  void _loadOrCreateUser() {
    final stored = _box.read(_userKey);

    if (stored != null) {
      userProfile = UserProfile.fromJson(
        Map<String, dynamic>.from(stored),
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
    _box.write(_userKey, userProfile.value.toJson());
  }

  // =========================
  // BADGES (PERSISTED)
  // =========================

  void _initBadges() {
    final stored = _box.read(_badgesKey) ?? {};

    final baseBadges = [
      Badge(
        id: 'first_walk',
        title: 'First Walk',
        description: 'Complete your first route',
        iconPath: 'assets/badges/first_walk.jpg',
        unlocked: false,
      ),
      Badge(
        id: 'athens_explorer',
        title: 'Athens Explorer',
        description: 'Explore Athens',
        iconPath: 'assets/badges/athens_explorer.jpg',
        unlocked: false,
      ),
      Badge(
        id: 'profile_complete',
        title: 'Profile Ready',
        description: 'Complete your profile',
        iconPath: 'assets/badges/profile_complete.jpg',
        unlocked: false,
      ),
    ];

    badges.assignAll(
      baseBadges.map((badge) {
        if (stored.containsKey(badge.id)) {
          return Badge.fromJson(stored[badge.id], badge);
        }
        return badge;
      }).toList(),
    );
  }

  void _saveBadges() {
    final map = {
      for (final b in badges) b.id: b.toJson(),
    };
    _box.write(_badgesKey, map);
  }

  // =========================
  // TEMP DEV BADGE UNLOCK
  // =========================
  // ⚠️ TEMPORARY METHOD
  // Used only for testing badges unlocking via tap
  void unlockBadgeAndAddProgress(String badgeId) {
    final index = badges.indexWhere((b) => b.id == badgeId);
    if (index == -1) return;
    if (badges[index].unlocked) return;

    // Unlock badge
    badges[index] = badges[index].copyWith(unlocked: true);
    _saveBadges();

    // TEMP: add progress when badge unlocks
    addProgress(10); // 🔧 adjust freely
  }

  // =========================
  // PROGRESS SYSTEM
  // =========================

  void addProgress(int amount) {
    final current = userProfile.value.progress;
    final updated = (current + amount).clamp(0, 100);

    userProfile.value =
        userProfile.value.copyWith(progress: updated);
    _saveUser();
  }

  // =========================
  // AVATAR
  // =========================

  void selectPresetAvatar(String path) {
    userProfile.value =
        userProfile.value.copyWith(avatarPath: path);
    _saveUser();
  }

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

  // =========================
  // PROFILE EDIT
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

  // =========================
  // LEVEL
  // =========================

  String get levelTitle {
    final progress = userProfile.value.progress;

    if (progress >= 75) return 'Master';
    if (progress >= 50) return 'Historian';
    if (progress >= 25) return 'Explorer';
    return 'Newcomer';
  }
}
