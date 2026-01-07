import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

import '../controller/profile_controller.dart';
import '../widgets/passport.dart';
import '../widgets/progressbar.dart';
import 'package:historywalk/common/layouts/section_screen.dart';
import '../widgets/badges_sheet.dart';
import '../../auth/screens/login/login_screen.dart';
import '../../../data/services/firebasedata.dart';

class ProfileScreen extends StatelessWidget {
  ProfileScreen({super.key});

  final ProfileController controller = Get.put(ProfileController());

  @override
  Widget build(BuildContext context) {
    return SectionScreenLayout(
      title: 'PROFILE',
      showSearch: false,
      body: Obx(
        () => ListView(
  padding: const EdgeInsets.all(16),
  children: [
    // 1. PASSPORT CARD WITH PENCIL OVERLAY
    Stack(
      children: [
        // Your existing card logic
        PassportCard(
          name: controller.userProfile.value.name,
          nationality: controller.userProfile.value.nationality,
          joinedDate: DateFormat('dd/MM/yyyy')
              .format(controller.userProfile.value.firstLoginDate),
          level: controller.levelTitle,
          avatarPath: controller.userProfile.value.avatarPath,
          onAvatarTap: () => _showAvatarOptions(context),
          onBadgesTap: () {
            showDialog(
              context: context,
              barrierDismissible: true,
              builder: (_) => const BadgesSheet(),
            );
          },
        ),
        
        // The Pencil Icon positioned top-right
        Positioned(
          top: 8,
          right: 8,
          child: CircleAvatar(
            backgroundColor: Colors.white.withOpacity(0.8),
            radius: 18,
            child: IconButton(
              icon: const Icon(Icons.edit, size: 18, color: Colors.black),
              onPressed: () => _showEditProfileDialog(context),
            ),
          ),
        ),
      ],
    ),
    
    const SizedBox(height: 12),

    ProfileProgressBar(
      progress: controller.userProfile.value.progress.toDouble(),
      label: 'Exploring Athens',
      icon: const Icon(Icons.account_balance, size: 20),
    ),

    const SizedBox(height: 32), // More spacing before logout

    ElevatedButton(
  onPressed: () async {
    print("Starting seed...");
    await seedDatabase(); // This calls the function I gave you
    print("Seed finished!");
  },
  child: Text("Push Data to Firebase"),
),

    // 2. LOGOUT BUTTON
    const Divider(),
    ListTile(
      onTap: () {
        // Add your logout logic here, e.g.:
        // controller.logout(); 
        Get.defaultDialog(
          title: "Logout",
          middleText: "Are you sure you want to log out?",
          textConfirm: "Yes",
          textCancel: "No",
          confirmTextColor: Colors.white,
          onConfirm: () {
             // This clears the navigation stack so they can't go back
              Get.offAll(() => LoginScreen());
          },
        );
      },
      leading: const Icon(Icons.logout, color: Colors.red),
      title: const Text(
        'Log Out',
        style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold),
      ),
    ),
  ],
),
      ),
    );
  }

  // =========================
  // Avatar options
  // =========================

  void _showAvatarOptions(BuildContext context) {
    showModalBottomSheet(
      context: context,
      builder: (_) {
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Padding(
                padding: EdgeInsets.all(12),
                child: Text(
                  'Choose Avatar',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
              ),
              Wrap(
                spacing: 12,
                children: controller.presetAvatars.map((avatar) {
                  return GestureDetector(
                    onTap: () {
                      controller.selectPresetAvatar(avatar);
                      Navigator.pop(context);
                    },
                    child: CircleAvatar(
                      radius: 30,
                      backgroundImage: AssetImage(avatar),
                    ),
                  );
                }).toList(),
              ),
              const Divider(),
              ListTile(
                leading: const Icon(Icons.photo),
                title: const Text('From Gallery'),
                onTap: () {
                  controller.pickAvatarFromGallery();
                  Navigator.pop(context);
                },
              ),
              ListTile(
                leading: const Icon(Icons.camera_alt),
                title: const Text('From Camera'),
                onTap: () {
                  controller.pickAvatarFromCamera();
                  Navigator.pop(context);
                },
              ),
            ],
          ),
        );
      },
    );
  }

  // =========================
  // Edit profile dialog
  // =========================

  void _showEditProfileDialog(BuildContext context) {
    final nameController = TextEditingController(
      text: controller.userProfile.value.name,
    );
    final nationalityController = TextEditingController(
      text: controller.userProfile.value.nationality,
    );

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Edit profile'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: nameController,
                decoration: const InputDecoration(
                  labelText: 'Name',
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: nationalityController,
                decoration: const InputDecoration(
                  labelText: 'Nationality',
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                controller.updateName(nameController.text);
                controller.updateNationality(
                  nationalityController.text,
                );
                Navigator.of(context).pop();
              },
              child: const Text('Save'),
            ),
          ],
        );
      },
    );
  }
}
