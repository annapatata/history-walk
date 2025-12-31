// profile_screen.dart
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

import '../controller/profile_controller.dart';
import '../widgets/passport.dart';
import '../widgets/progressbar.dart';
import 'package:historywalk/common/layouts/section_screen.dart';

class ProfileScreen extends StatelessWidget {
  ProfileScreen({super.key});

  final ProfileController controller = Get.put(ProfileController());

  @override
  Widget build(BuildContext context) {
    return SectionScreenLayout(
      title: 'PROFILE',
      showSearch: false,
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Obx(
            () => GestureDetector(
              onTap: () {
                _showEditProfileDialog(context);
              },
              child: PassportCard(
                name: controller.userProfile.value.name,
                nationality: controller.userProfile.value.nationality,
                joinedDate: DateFormat('dd/MM/yyyy')
                    .format(controller.userProfile.value.firstLoginDate),
                level: 'Explorer',
              ),
            ),
          ),
          const SizedBox(height: 12),
          ProfileProgressBar(
            progress: 59, // STUB
            label: 'Exploring Athens',
            icon: const Icon(Icons.account_balance, size: 20),
          ),
        ],
      ),
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
