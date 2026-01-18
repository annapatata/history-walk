import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import '../models/badge.dart';
import '../data/badge_definitions.dart';
import '../controller/profile_controller.dart';
import '../../routes/controller/route_controller.dart';

class BadgeController extends GetxController {
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  final GetStorage _box = GetStorage();

  final ProfileController profileController = Get.find();
  final RouteController routeController = Get.find();

  final RxList<Badge> badges = <Badge>[].obs;

  String get _badgesKey =>
      'user_badges_${profileController.userProfile.value?.uid ?? ""}';

  @override
  void onInit() {
    super.onInit();

    // Περιμένουμε να φορτωθεί user
    ever(profileController.userProfile, (user) {
      if (user != null) {
        initBadges();
      }
    });
  }

  // =========================
  // INIT + SYNC
  // =========================

  Future<void> initBadges() async {
    _loadLocalBadges();
    await syncBadgesFromFirebase();
  }

  void _loadLocalBadges() {
    final stored = _box.read(_badgesKey) ?? {};

    badges.assignAll(
      baseBadgeDefinitions.map((badge) {
        if (stored.containsKey(badge.id)) {
          return Badge.fromJson(stored[badge.id], badge);
        }
        return badge;
      }).toList(),
    );

    if (stored.isEmpty) {
      _saveBadges();
    }

    print("🏅 Badges initialized (${badges.length})");
  }

  void _saveBadges() {
    final map = {for (final b in badges) b.id: b.toJson()};
    _box.write(_badgesKey, map);
  }

  // =========================
  // UNLOCK LOGIC
  // =========================

  void unlockBadge({
    required String badgeId,
    required int rewardPoints,
    String snackbarTitle = "Badge Unlocked! 🏆",
  }) {
    final index = badges.indexWhere((b) => b.id == badgeId);
    if (index == -1) return;

    final badge = badges[index];
    if (badge.unlocked) return;

    final updated = badge.copyWith(unlocked: true);
    badges[index] = updated;

    _saveBadges();
    _saveBadgeToFirebase(updated);
    profileController.addProgress(rewardPoints);

    Get.snackbar(
      snackbarTitle,
      badge.title,
      snackPosition: SnackPosition.BOTTOM,
      duration: const Duration(seconds: 3),
    );
  }

  // =========================
  // ROUTES & MILESTONES
  // =========================

  void onRouteCompleted(String routeId) {
    unlockBadge(
      badgeId: 'route_$routeId',
      rewardPoints: pointsForRoute(routeId),
    );

    _checkMilestones();
  }

  void _checkMilestones() {
    final completed =
        profileController.userProfile.value?.completedRoutes.length ?? 0;

    if (completed >= 1) {
      unlockBadge(badgeId: 'first_walk', rewardPoints: 10);
    }
    if (completed >= 5) {
      unlockBadge(badgeId: 'fifth_walk', rewardPoints: 25);
    }
  }

  int pointsForRoute(String routeId) {
    final route =
        routeController.allRoutes.firstWhere((r) => r.id == routeId);
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
  // FIREBASE
  // =========================

  Future<void> syncBadgesFromFirebase() async {
    final uid = profileController.userProfile.value?.uid;
    if (uid == null) return;

    final snapshot = await _db
        .collection('users')
        .doc(uid)
        .collection('badges')
        .get();

    bool changed = false;

    for (final doc in snapshot.docs) {
      final index = badges.indexWhere((b) => b.id == doc.id);
      if (index == -1) continue;

      if (doc['unlocked'] == true && !badges[index].unlocked) {
        badges[index] = badges[index].copyWith(unlocked: true);
        changed = true;
      }
    }

    if (changed) {
      _saveBadges();
      print("🔄 Badges synced from Firebase");
    }
  }

  Future<void> _saveBadgeToFirebase(Badge badge) async {
    final uid = profileController.userProfile.value?.uid;
    if (uid == null) return;

    await _db
        .collection('users')
        .doc(uid)
        .collection('badges')
        .doc(badge.id)
        .set(badge.toJson(), SetOptions(merge: true));
  }
}
