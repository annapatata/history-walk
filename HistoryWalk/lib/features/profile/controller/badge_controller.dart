import 'package:get/get.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/badge.dart';
import '../../profile/controller/profile_controller.dart';

class BadgeController extends GetxController {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  /// Single source of truth για badges = ProfileController
  final ProfileController profileController = Get.find<ProfileController>();

  @override
  void onInit() {
    super.onInit();
    // Δεν κρατάμε local badges list εδώ
    // Όλα διαβάζονται / γράφονται μέσω ProfileController
  }

  /// Καλείται όταν ολοκληρώνεται ένα route
  void onRouteCompleted(String routeId) {
    print("🏁 Route completed: $routeId");

    // 1️⃣ Route-based badge (id-based)
    _unlockBadge('route_$routeId');

    // 2️⃣ Area completion (optional – future)
    _checkAreaCompletion(routeId);

    // 3️⃣ Milestones
    _checkMilestones();
  }

  // =========================
  // 🔓 Badge unlocking logic
  // =========================

  void _unlockBadge(String badgeId) {
    final index =
        profileController.badges.indexWhere((b) => b.id == badgeId);

    if (index == -1) {
      print("⚠️ Badge not found: $badgeId");
      return;
    }

    final badge = profileController.badges[index];

    if (badge.unlocked) {
      print("ℹ️ Badge already unlocked: $badgeId");
      return;
    }

    // Unlock badge
    profileController.badges[index] =
        badge.copyWith(unlocked: true);

    // Save locally
    profileController.saveBadges();

    // Save to Firebase
    _saveBadgeToFirebase(profileController.badges[index]);

    // 4️⃣ Προσθήκη 10 πόντων προόδου
    profileController.addProgress(10);
    
    // Feedback
    Get.snackbar(
      "Badge Unlocked! 🏆",
      badge.title,
      snackPosition: SnackPosition.BOTTOM,
      duration: const Duration(seconds: 3),
    );

    print("✅ Badge unlocked: $badgeId");
  }

  // =========================
  // 🗺️ Area badges (optional)
  // =========================

  void _checkAreaCompletion(String routeId) {
    // Placeholder – μελλοντικά:
    // 1. βρίσκεις areaId του route
    // 2. ελέγχεις αν όλα τα routes του area ολοκληρώθηκαν
    // 3. unlock area badge
  }

  // =========================
  // 🏆 Milestones
  // =========================

    void _checkMilestones() {
    final completedRoutes =
        profileController.userProfile.value?.completedRoutes ?? [];

    // 🥇 First Walk
    if (completedRoutes.length >= 1) {
      _unlockBadge('first_walk');
    }

    // 🔟 10 routes milestone
    if (completedRoutes.length >= 10) {
      _unlockBadge('milestone_10_routes');
    }

    // εδώ μπαίνουν κι άλλα milestones
  }

  // =========================
  // ☁️ Firebase
  // =========================

  Future<void> _saveBadgeToFirebase(Badge badge) async {
    final uid = profileController.userProfile.value?.uid;
    if (uid == null) return;

    try {
      await _db
          .collection('users')
          .doc(uid)
          .collection('badges')
          .doc(badge.id)
          .set(badge.toJson());

      print("☁️ Badge saved to Firebase: ${badge.id}");
    } catch (e) {
      print("❌ Error saving badge to Firebase: $e");
    }
  }
}
