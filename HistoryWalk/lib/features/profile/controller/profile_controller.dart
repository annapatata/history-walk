import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:get_storage/get_storage.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/user_profile.dart';
import '../models/badge.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'dart:io';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart' as m;

class ProfileController extends GetxController {
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  final ImagePicker _picker = ImagePicker();
  final GetStorage _box = GetStorage();
  final FirebaseStorage _storage = FirebaseStorage.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // use Rxn so it can be null until data arrives
  Rxn<UserProfile> userProfile = Rxn<UserProfile>();

  // 🏅 Badges
  final RxList<Badge> badges = <Badge>[].obs;

  // 🧑 Preset avatars
  final List<String> presetAvatars = [
    'assets/avatars/explorer_female.png',
    'assets/avatars/explorer_male.png',
    'assets/avatars/mage_female.png',
    'assets/avatars/mage_male.png',
    'assets/avatars/scholar_female.png',
    'assets/avatars/scholar_male.png',
  ];

  // =========================
  // Keys for local storage per user
  // =========================
  String get _userKey => 'user_profile';
  String get _badgesKey => 'user_badges_${userProfile.value?.uid ?? ""}';

  @override
  void onInit() {
    super.onInit();
    // Read the value from storage and update the observable
  isDarkObservable.value = _box.read('isDarkMode') ?? false;
    // Αν υπάρχει ήδη logged-in user, κάνουμε fetch
    final currentUser = FirebaseAuth.instance.currentUser;
    if (currentUser != null) {
      fetchUserProfile(currentUser.uid);
    } else {
      print("cannot fetch profile, no user logged in");
      _initBadges(); // αρχικοποίηση κλειδωμένων badges
    }
  }

  // =========================
  // USER PROFILE
  // =========================
  Future<void> _saveUser() async {
    if (userProfile.value == null) return;

    // 1. Save locally
    _box.write(_userKey, userProfile.value!.toJson());

    // 2. Save to Firestore
    try {
      await _db
          .collection('users')
          .doc(userProfile.value!.uid)
          .set(userProfile.value!.toJson(), SetOptions(merge: true));
      print("✅ Profile synced to Firestore");
    } catch (e) {
      print("❌ Firestore sync error: $e");
    }
  }

  RxBool isLoading = false.obs;

  Future<void> fetchUserProfile(String uid) async {
    try {
      isLoading.value = true;
      DocumentSnapshot doc = await _db.collection('users').doc(uid).get();
      if (doc.exists) {
        userProfile.value = UserProfile.fromJson(doc.data() as Map<String, dynamic>);
        // save locally
        _box.write(_userKey, userProfile.value!.toJson());
      }
    } catch (e) {
      print("Error fetching profile: $e");
    } finally {
      isLoading.value = false;
      _initBadges(); // initialize badges after userProfile is loaded
    }
  }

  // =========================
  // BADGES (PERSISTED, per user)
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
        id: 'route_ancient_athens',
        title: 'Athens Explorer',
        description: 'Explore Athens',
        iconPath: 'assets/badges/athens_explorer.jpg',
        unlocked: false,
      ),
      Badge(
        id: 'route_byzantine_trail',
        title: 'Byzantine Echoes',
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

    // Αν δεν υπάρχει local storage για τον χρήστη, ξεκλειδωμένα όλα false
    if (stored.isEmpty) {
      badges.assignAll(baseBadges.map((b) => b.copyWith(unlocked: false)).toList());
      _saveBadges();
    }
  }

  void _saveBadges() {
    final map = {for (final b in badges) b.id: b.toJson()};
    _box.write(_badgesKey, map);
  }

  void saveBadges() {
    _saveBadges();
  }

  // =========================
  // PROGRESS SYSTEM
  // =========================
  void addProgress(int amount) {
    final profile = userProfile.value;
    if (profile == null) return;

    final current = profile.progress;
    final updated = (current + amount).clamp(0, 100);
    userProfile.value = profile.copyWith(progress: updated);
    _saveUser();
  }

  // =========================
  // AVATAR
  // =========================
  void selectPresetAvatar(String path) {
    if (userProfile.value == null) return;
    userProfile.value = userProfile.value!.copyWith(avatarPath: path);
    _saveUser();
  }

  Future<void> pickAvatarFromGallery() async {
    if (userProfile.value == null) return;
    final image = await _picker.pickImage(source: ImageSource.gallery);
    if (image != null) {
      try {
        String downloadUrl = await _uploadImage(image.path);
        userProfile.value = userProfile.value!.copyWith(avatarPath: downloadUrl);
        await _saveUser();
        Get.snackbar("Success", "Profile picture updated!");
      } catch (e) {
        Get.snackbar("Error", "Failed to upload image: $e");
      }
    }
  }

  Future<void> pickAvatarFromCamera() async {
    if (userProfile.value == null) return;
    final image = await _picker.pickImage(source: ImageSource.camera);
    if (image != null) {
      try {
        String downloadUrl = await _uploadImage(image.path);
        userProfile.value = userProfile.value!.copyWith(avatarPath: downloadUrl);
        await _saveUser();
        Get.snackbar("Success", "Profile picture updated!");
      } catch (e) {
        Get.snackbar("Error", "Failed to upload image: $e");
      }
    }
  }

  Future<String> _uploadImage(String filePath) async {
    File file = File(filePath);
    String fileName = 'avatars/${userProfile.value!.uid}';
    try {
      final storageRef = FirebaseStorage.instance.ref();
      final avatarRef = storageRef.child(fileName);
      UploadTask uploadTask = avatarRef.putFile(file);
      TaskSnapshot snapshot = await uploadTask;
      String downloadUrl = await snapshot.ref.getDownloadURL();
      return downloadUrl;
    } catch (e) {
      print("Storage Error: $e");
      rethrow;
    }
  }

  // =========================
  // PROFILE EDIT
  // =========================
  void updateName(String newName) {
    if (userProfile.value == null) return;
    userProfile.value = userProfile.value!.copyWith(name: newName);
    _saveUser();
  }

  void updateNationality(String newNationality) {
    if (userProfile.value == null) return;
    userProfile.value = userProfile.value!.copyWith(nationality: newNationality);
    _saveUser();
  }

  // =========================
  // LEVEL
  // =========================
  String get levelTitle {
    if (userProfile.value == null) return 'Guest';
    final progress = userProfile.value!.progress;

    if (progress >= 75) return 'Master';
    if (progress >= 50) return 'Historian';
    if (progress >= 25) return 'Explorer';
    return 'Newcomer';
  }

  // =========================
  // ROUTE COMPLETION HELPER
  // =========================
  bool isRouteCompleted(String routeId) {
    return userProfile.value?.completedRoutes.contains(routeId) ?? false;
  }

// =========================
  // TOGGLE THEME HELPER
  // =========================
RxBool isDarkObservable =  false.obs;

void toggleTheme(bool value) {
  isDarkObservable.value = value;
  Get.changeThemeMode(value ? m.ThemeMode.dark : m.ThemeMode.light);
  _box.write('isDarkMode', value);
}

// =========================
  // ACCOUNT SETTINGS HELPER
  // =========================

Future<void> updateAccountSecurity({
  required String newEmail,
  required String newPassword,
  required String currentPassword,
}) async {
  try {
    User? user = _auth.currentUser;
    if (user == null || user.email == null) return;

    // 1. Re-authenticate
    AuthCredential credential = EmailAuthProvider.credential(
      email: user.email!,
      password: currentPassword,
    );
    await user.reauthenticateWithCredential(credential);

    // 2. Update Email if changed
    if (newEmail != user.email) {
      await user.updateEmail(newEmail);
      // Update Firestore as well
      await _db.collection('users').doc(user.uid).update({'email': newEmail});
    }

    // 3. Update Password if provided
    if (newPassword.isNotEmpty) {
      await user.updatePassword(newPassword);
    }

    Get.back(); // Close dialog
    Get.snackbar("Success", "Account updated successfully", snackPosition: SnackPosition.BOTTOM);
  } catch (e) {
    Get.snackbar("Error", e.toString());
  }
}

}
