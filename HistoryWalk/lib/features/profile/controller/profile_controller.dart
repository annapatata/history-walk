import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:get_storage/get_storage.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/user_profile.dart';
import '../models/badge.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'dart:io';
import 'package:firebase_auth/firebase_auth.dart';

class ProfileController extends GetxController {

  final FirebaseFirestore _db = FirebaseFirestore.instance;
  final ImagePicker _picker = ImagePicker();
  final GetStorage _box = GetStorage();
  final FirebaseStorage _storage = FirebaseStorage.instance;
  static const String _userKey = 'user_profile';
  static const String _badgesKey = 'user_badges';
  final FirebaseAuth _auth = FirebaseAuth.instance;

  //use rxn so it can be null until data arrives
  Rxn<UserProfile> userProfile = Rxn<UserProfile>();

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
    _initBadges();

  final currentUser = FirebaseAuth.instance.currentUser;
  if(currentUser!=null){
  fetchUserProfile(currentUser.uid);
  }else {
    print("cannot fetch profile, no user logged in");
  }
  }

  Future<String> _uploadImage(String localPath) async {
    File file = File(localPath);
    //create a unique filename using the userID

    String userId = userProfile.value!.uid;
    Reference ref = _storage.ref().child('avatars').child('$userId.jpg');

    UploadTask uploadTask = ref.putFile(file);
    TaskSnapshot snapshot = await uploadTask;

    return await snapshot.ref.getDownloadURL();
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
      await _db.collection('users')
          .doc(userProfile.value!.uid)
          .set(userProfile.value!.toJson(), SetOptions(merge: true));
      print("✅ Profile synced to Firestore");
    } catch (e) {
      print("❌ Firestore sync error: $e");
    }
  }

  RxBool isLoading = false.obs;

  Future<void> fetchUserProfile(String uid) async {
    try{
      isLoading.value = true;
      DocumentSnapshot doc = await _db.collection('users').doc(uid).get();
      if(doc.exists){
        userProfile.value = UserProfile.fromJson(doc.data() as Map<String,dynamic>);
        //also save locally for offline access
        _box.write('user_profile', userProfile.value!.toJson());
      }
    } catch(e){
      print("Error fetching profile: $e");
    } finally {
      isLoading.value = false;
    }
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
    final profile = userProfile.value;
    if (profile == null) return;

    final current = userProfile.value!.progress; // Added !
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
      try{
        String downloadUrl = await _uploadImage(image.path);
        userProfile.value = userProfile.value!.copyWith(avatarPath: downloadUrl);
        
        await _saveUser();
        Get.snackbar("Success","Profile picture updated!");
      } catch (e) {
        Get.snackbar("Error","Failed to upload image: $e");
      }
    }
  }

   Future<void> pickAvatarFromCamera() async {
    if (userProfile.value == null) return;

    final image = await _picker.pickImage(source: ImageSource.camera);
    if (image != null) {
      try{
        String downloadUrl = await _uploadImage(image.path);
        userProfile.value = userProfile.value!.copyWith(avatarPath: downloadUrl);
        
        await _saveUser();
        Get.snackbar("Success","Profile picture updated!");
      } catch (e) {
        Get.snackbar("Error","Failed to upload image: $e");
      }
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

  // Helper method to check the completed routes so that write a review is visible and tick on the routes page
  bool isRouteCompleted(String routeId) {
    return userProfile.value?.completedRoutes.contains(routeId) ?? false;
  }

}