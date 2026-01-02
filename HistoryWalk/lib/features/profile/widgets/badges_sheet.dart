import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../controller/profile_controller.dart';

class BadgesSheet extends StatelessWidget {
  const BadgesSheet({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<ProfileController>();

    return Dialog(
      insetPadding: const EdgeInsets.all(16),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(24),
      ),
      child: SizedBox(
        height: MediaQuery.of(context).size.height * 0.8,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              // =========================
              // Header
              // =========================
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Badges',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: () => Navigator.pop(context),
                  ),
                ],
              ),
              const SizedBox(height: 16),

              // =========================
              // Badges Grid
              // =========================
              Expanded(
                child: Obx(
                  () => GridView.builder(
                    itemCount: controller.badges.length,
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 3,
                      mainAxisSpacing: 20,
                      crossAxisSpacing: 20,
                      childAspectRatio: 0.9,
                    ),
                    itemBuilder: (_, index) {
                      final badge = controller.badges[index];

                      return GestureDetector(
                        onTap: () {
                          // ⚠️ TEMP DEV ONLY
                          // Tap badge to unlock + add progress
                          controller.unlockBadgeAndAddProgress(badge.id);
                        },
                        child: Column(
                          children: [
                            AnimatedScale(
                              scale: badge.unlocked ? 1.0 : 0.95,
                              duration:
                                  const Duration(milliseconds: 300),
                              curve: Curves.easeOut,
                              child: Stack(
                                alignment: Alignment.center,
                                children: [
                                  // Badge image
                                  ClipRRect(
                                    borderRadius:
                                        BorderRadius.circular(16),
                                    child: Image.asset(
                                      badge.iconPath,
                                      width: 72,
                                      height: 72,
                                      fit: BoxFit.cover,
                                    ),
                                  ),

                                  // Locked overlay
                                  if (!badge.unlocked)
                                    Positioned.fill(
                                      child: ClipRRect(
                                        borderRadius:
                                            BorderRadius.circular(16),
                                        child: BackdropFilter(
                                          filter: ImageFilter.blur(
                                            sigmaX: 4,
                                            sigmaY: 4,
                                          ),
                                          child: Container(
                                            color: Colors.black
                                                .withOpacity(0.25),
                                          ),
                                        ),
                                      ),
                                    ),

                                  // Lock icon
                                  if (!badge.unlocked)
                                    const Icon(
                                      Icons.lock,
                                      size: 28,
                                      color: Colors.white,
                                    ),
                                ],
                              ),
                            ),
                            const SizedBox(height: 8),

                            // Badge title
                            Text(
                              badge.title,
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                                color: badge.unlocked
                                    ? Colors.black
                                    : Colors.grey,
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
