import 'package:get/get.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import '../models/badge.dart';
import '../../profile/controller/profile_controller.dart';
import '../../routes/controller/route_controller.dart';

class BadgeController extends GetxController {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  /// Single source of truth για user state
  final ProfileController profileController = Get.find<ProfileController>();
  final RouteController routeController = Get.find<RouteController>();

  @override
  void onInit() {
    super.onInit();
  }

  // =========================
  //  PUBLIC API
  // =========================

  /// Καλείται όταν ολοκληρώνεται ένα route
  void onRouteCompleted(String routeId) {
    unlockBadge(
      badgeId: 'route_$routeId',
      rewardPoints: pointsForRoute(routeId),
    );

    // Milestones
    _checkMilestones();
  }

  // =========================
  //  GENERIC BADGE UNLOCK
  // =========================

  void unlockBadge({
    required String badgeId,
    required int rewardPoints,
    String snackbarTitle = "Badge Unlocked! 🏆",
  }) {
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

    //  Unlock badge
    profileController.badges[index] =
        badge.copyWith(unlocked: true);

    // Save locally
    profileController.saveBadges();

    // Save to Firebase
    _saveBadgeToFirebase(profileController.badges[index]);

    //  Add progress / XP
    profileController.addProgress(rewardPoints);

    //  UI feedback
    Get.snackbar(
      snackbarTitle,
      badge.title,
      snackPosition: SnackPosition.BOTTOM,
      duration: const Duration(seconds: 3),
    );

    print(
      "✅ Badge unlocked: $badgeId (+$rewardPoints pts)",
    );
  }

  // =========================
  //  REWARD LOGIC
  // =========================

  int pointsForRoute(String routeId) {
    final route = routeController.allRoutes
        .firstWhere((r) => r.id == routeId);

    return pointsForDifficulty(route.difficulty);
  }

  int pointsForDifficulty(String difficulty) {
    switch (difficulty.toLowerCase()) {
      case 'easy':
        return 5;
      case 'medium':
        return 10;
      case 'hard':
        return 20;
      case 'extreme':
        return 30;
      default:
        return 10;
    }
  }

  // =========================
  //  MILESTONES
  // =========================

  void _checkMilestones() {
    final completedRoutes =
        profileController.userProfile.value?.completedRoutes ?? [];

    if (completedRoutes.length >= 1) {
      unlockBadge(
        badgeId: 'first_walk',
        rewardPoints: 10,
        snackbarTitle: "Milestone Achieved! 🎯",
      );
    }

    if (completedRoutes.length >= 5) {
      unlockBadge(
        badgeId: 'fifth_walk',
        rewardPoints: 25,
        snackbarTitle: "Milestone Achieved! 🎯",
      );
    }

    if (completedRoutes.length >= 10) {
      unlockBadge(
        badgeId: 'tenth_walk',
        rewardPoints: 50,
        snackbarTitle: "Milestone Achieved! 🎯",
      );
    }
  }

  // =========================
  //  FIREBASE
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
