import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import '../../auth/controller/auth_controller.dart';
import '../controller/profile_controller.dart';
import '../widgets/passport.dart';
import '../widgets/walks_calendar.dart';
import '../widgets/progressbar.dart';
import 'package:historywalk/common/layouts/section_screen.dart';
import '../widgets/badges_sheet.dart';
import '../../auth/screens/login/login_screen.dart';
import '../../../data/services/firebasedata.dart';
import 'package:get_storage/get_storage.dart';
import 'accsettings.dart';

class ProfileScreen extends StatelessWidget {
  ProfileScreen({super.key});

  final ProfileController controller = Get.find();
  final AuthController authctrl = Get.find();

  @override
  Widget build(BuildContext context) {
    return SectionScreenLayout(
      title: 'PROFILE',
      showSearch: false,
      body: Obx(() {
        // 1. Παίρνουμε μια τοπική αναφορά (shadow variable)
        final user = controller.userProfile.value;

        // 2. Αν ο χρήστης είναι null, δείξε error text
        if (user == null) {
          return const Center(child: Text("could not load profile"));
        }

        //3.Αν ο Controller εχει σημα Loading
        if (controller.isLoading.value) {
          return const Center(child: CircularProgressIndicator());
        }

        // 3. Αν έχουμε χρήστη, δείξε τα δεδομένα κανονικά χρησιμοποιώντας τη μεταβλητή 'user'
        return ListView(
          padding: const EdgeInsets.all(16),
          children: [
            Stack(
              children: [
                PassportCard(
                  name: user
                      .name, // Χρησιμοποιούμε το 'user' που ξέρουμε ότι δεν είναι null
                  nationality: user.nationality,
                  joinedDate: DateFormat(
                    'dd/MM/yyyy',
                  ).format(user.firstLoginDate),
                  level: controller.levelTitle,
                  avatarPath: user.avatarPath,
                  onAvatarTap: () => _showAvatarOptions(context),
                  onBadgesTap: () {
                    showDialog(
                      context: context,
                      barrierDismissible: true,
                      builder: (_) => const BadgesSheet(),
                    );
                  },
                ),
                Positioned(
                  top: 8,
                  right: 8,
                  child: CircleAvatar(
                    backgroundColor: Colors.white.withOpacity(0.8),
                    radius: 18,
                    child: IconButton(
                      icon: const Icon(
                        Icons.edit,
                        size: 18,
                        color: Colors.black,
                      ),
                      onPressed: () => _showEditProfileDialog(context),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            ProfileProgressBar(
              progress: user.progress.toDouble(),
              label: 'Exploring Athens',
              icon: const Icon(Icons.account_balance, size: 20),
            ),

          const SizedBox(height: 24),
          WalksCalendar(
            userName: user.name,
          ),

            const SizedBox(height: 32),

   /*ElevatedButton(
  onPressed: () async {
    print("Starting seed...");
    await seedDatabase(); // This calls the function I gave you
    print("Seed finished!");
  },
  child: Text("Push Data to Firebase"),
),*/

            // logout,settings
            const Divider(),

            ListTile(
              onTap: () =>
                  _showSettingsMenu(context), // Call the helper function below
              leading: const Icon(Icons.settings, color: Colors.black),
              title: const Text(
                'Settings',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
            ),
            ListTile(
              onTap: () {
                Get.defaultDialog(
                  title: "Logout",
                  middleText: "Are you sure you want to log out?",
                  textConfirm: "Yes",
                  textCancel: "No",
                  confirmTextColor: Colors.white,
                  onConfirm: () {
                    authctrl.logout();
                    Get.offAll(() => LoginScreen());
                  },
                );
              },
              leading: const Icon(Icons.logout, color: Colors.red),
              title: const Text(
                'Log Out',
                style: TextStyle(
                  color: Colors.red,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        );
      }),
    );
  }

  // =========================
  // Settings options
  // =========================

  void _showSettingsMenu(BuildContext context) {
    Get.bottomSheet(
      Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Theme.of(context).scaffoldBackgroundColor,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              "Settings",
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const Divider(),

              // 1. Dark Mode Toggle
            Obx(() => ListTile(
              leading: const Icon(Icons.dark_mode),
              title: const Text("Dark Mode"),
              trailing: Switch(
                value: controller.isDarkObservable.value, // Now using a real Rx variable
                onChanged: (value) => controller.toggleTheme(value),
              ),
            )),

            // 3. Update Email / Password
            ListTile(
              leading: const Icon(Icons.lock_outline),
              title: const Text("Account Security"),
              onTap: () {
              Get.to(() => const AccountSettingsScreen());              
              },
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
              GridView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: controller.presetAvatars.length,
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 3,
                  crossAxisSpacing: 6,
                  mainAxisSpacing: 6,
                ),
                itemBuilder: (context, index) {
                  return LayoutBuilder(
                    builder: (context, constraints) {
                      // Το μέγεθος του κελιού
                      final cellSize = constraints.maxWidth;

                      // Avatar = 60% του κελιού (ρύθμισε το)
                      final avatarRadius = cellSize * 0.3;

                      final avatar = controller.presetAvatars[index];

                      return Center(
                        child: GestureDetector(
                          onTap: () {
                            controller.selectPresetAvatar(avatar);
                            Navigator.pop(context);
                          },
                          child: CircleAvatar(
                            radius: avatarRadius,
                            backgroundImage: AssetImage(avatar),
                            backgroundColor: Colors.transparent,
                          ),
                        ),
                      );
                    },
                  );
                },
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
      text: controller.userProfile.value!.name,
    );
    final nationalityController = TextEditingController(
      text: controller.userProfile.value!.nationality,
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
                decoration: const InputDecoration(labelText: 'Name'),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: nationalityController,
                decoration: const InputDecoration(labelText: 'Nationality'),
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
                controller.updateNationality(nationalityController.text);
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
