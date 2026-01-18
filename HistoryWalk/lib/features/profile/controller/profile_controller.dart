import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:get_storage/get_storage.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/user_profile.dart';
import '../../routes/models/route_model.dart';
import '../../routes/controller/route_controller.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'dart:io';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/image_model.dart';
import 'package:flutter/material.dart' as m;

class ProfileController extends GetxController {
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  final ImagePicker _picker = ImagePicker();
  final GetStorage _box = GetStorage();
  final FirebaseStorage _storage = FirebaseStorage.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  /// μπορεί να είναι null μέχρι να φορτώσει
  Rxn<UserProfile> userProfile = Rxn<UserProfile>();

  // =========================
  // THEME
  // =========================
  RxBool isDarkObservable = false.obs;

  // =========================
  // PRESET AVATARS
  // =========================
  final List<String> presetAvatars = [
    'assets/avatars/explorer_female.png',
    'assets/avatars/explorer_male.png',
    'assets/avatars/mage_female.png',
    'assets/avatars/mage_male.png',
    'assets/avatars/scholar_female.png',
    'assets/avatars/scholar_male.png',
  ];

  // =========================
  // LOCAL STORAGE KEYS
  // =========================
  String get _userKey => 'user_profile';

  // =========================
  // LIFECYCLE
  // =========================
  @override
  void onInit() {
    super.onInit();

    isDarkObservable.value = _box.read('isDarkMode') ?? false;

    final currentUser = _auth.currentUser;
    if (currentUser != null) {
      fetchUserProfile(currentUser.uid);
    } else {
      print("⚠️ No logged in user");
    }
  }

  // =========================
  // USER PROFILE
  // =========================
  RxBool isLoading = false.obs;

  Future<void> fetchUserProfile(String uid) async {
    try {
      isLoading.value = true;

      final doc = await _db.collection('users').doc(uid).get();
      if (doc.exists) {
        userProfile.value =
            UserProfile.fromJson(doc.data() as Map<String, dynamic>);
        _box.write(_userKey, userProfile.value!.toJson());
      }
    } catch (e) {
      print("❌ Error fetching profile: $e");
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> _saveUser() async {
    if (userProfile.value == null) return;

    // Local
    _box.write(_userKey, userProfile.value!.toJson());

    // Firestore
    try {
      await _db
          .collection('users')
          .doc(userProfile.value!.uid)
          .set(userProfile.value!.toJson(), SetOptions(merge: true));
      print("✅ Profile synced");
    } catch (e) {
      print("❌ Firestore sync error: $e");
    }
  }

  // =========================
  // PROGRESS / LEVEL
  // =========================
  void addProgress(int amount) {
    final profile = userProfile.value;
    if (profile == null) return;

    final updated = (profile.progress + amount).clamp(0, 100);
    userProfile.value = profile.copyWith(progress: updated);
    _saveUser();
  }

  String get levelTitle {
    if (userProfile.value == null) return 'Guest';
    final progress = userProfile.value!.progress;

    if (progress >= 75) return 'Master';
    if (progress >= 50) return 'Historian';
    if (progress >= 25) return 'Explorer';
    return 'Newcomer';
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
    if (image == null) return;

    try {
      final url = await _uploadImage(image.path);
      userProfile.value =
          userProfile.value!.copyWith(avatarPath: url);
      _saveUser();
      Get.snackbar("Success", "Profile picture updated!");
    } catch (e) {
      Get.snackbar("Error", "Upload failed");
    }
  }

  Future<void> pickAvatarFromCamera() async {
    if (userProfile.value == null) return;

    final image = await _picker.pickImage(source: ImageSource.camera);
    if (image == null) return;

    try {
      final url = await _uploadImage(image.path);
      userProfile.value =
          userProfile.value!.copyWith(avatarPath: url);
      _saveUser();
      Get.snackbar("Success", "Profile picture updated!");
    } catch (e) {
      Get.snackbar("Error", "Upload failed");
    }
  }

  Future<String> _uploadImage(String path) async {
    final file = File(path);
    final ref = _storage.ref().child('avatars/${userProfile.value!.uid}');
    await ref.putFile(file);
    return await ref.getDownloadURL();
  }

  // =========================
  // PROFILE EDIT
  // =========================
  void updateName(String name) {
    if (userProfile.value == null) return;
    userProfile.value = userProfile.value!.copyWith(name: name);
    _saveUser();
  }

  void updateNationality(String nationality) {
    if (userProfile.value == null) return;
    userProfile.value =
        userProfile.value!.copyWith(nationality: nationality);
    _saveUser();
  }

  // =========================
  // ROUTES HELPERS
  // =========================
  bool isRouteCompleted(String routeId) {
    return userProfile.value?.completedRoutes.contains(routeId) ?? false;
  }

  List<String> get completedRouteImages {
    final routes = userProfile.value?.completedRoutes ?? [];
    final routeController = Get.find<RouteController>();

    return routes
        .map((id) {
          try {
            return routeController.allRoutes
                .firstWhere((r) => r.id == id)
                .routepic;
          } catch (_) {
            return null;
          }
        })
        .whereType<String>()
        .toList();
  }

  // =========================
  // THEME
  // =========================
  void toggleTheme(bool value) {
    isDarkObservable.value = value;
    Get.changeThemeMode(
        value ? m.ThemeMode.dark : m.ThemeMode.light);
    _box.write('isDarkMode', value);
  }

  // =========================
  // ACCOUNT SECURITY
  // =========================
  Future<void> updateAccountSecurity({
    required String newEmail,
    required String newPassword,
    required String currentPassword,
  }) async {
    try {
      final user = _auth.currentUser;
      if (user == null || user.email == null) return;

      final credential = EmailAuthProvider.credential(
        email: user.email!,
        password: currentPassword,
      );

      await user.reauthenticateWithCredential(credential);

      if (newEmail != user.email) {
        await user.updateEmail(newEmail);
        await _db
            .collection('users')
            .doc(user.uid)
            .update({'email': newEmail});
      }

      if (newPassword.isNotEmpty) {
        await user.updatePassword(newPassword);
      }

      Get.back();
      Get.snackbar("Success", "Account updated");
    } catch (e) {
      Get.snackbar("Error", e.toString());
    }
  }

  // =========================
  // MEMORIES
  // =========================
  var userMemories = <MemoryModel>[].obs;

  Future<void> fetchUserMemories({String? routeId}) async {
    try {
      final uid = userProfile.value?.uid;
      if (uid == null) return;

      Query query = _db
          .collection('users')
          .doc(uid)
          .collection('memories')
          .orderBy('timestamp', descending: true);

      if (routeId != null) {
        query = query.where('routeId', isEqualTo: routeId);
      }

      final snapshot = await query.get();
      userMemories.assignAll(
        snapshot.docs.map(
          (d) => MemoryModel.fromFirestore(
              d.data() as Map<String, dynamic>),
        ),
      );
    } catch (e) {
      print("❌ Error fetching memories: $e");
    }
  }
}
