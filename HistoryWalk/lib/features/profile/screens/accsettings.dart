import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controller/profile_controller.dart';

class AccountSettingsScreen extends StatelessWidget {
  const AccountSettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<ProfileController>();
    final emailController = TextEditingController(text: controller.userProfile.value?.email);
    final passwordController = TextEditingController();

    return Scaffold(
      appBar: AppBar(
        title: const Text("Account Security"),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text("Update Email", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
            const SizedBox(height: 10),
            TextField(
              controller: emailController,
              decoration: const InputDecoration(
                prefixIcon: Icon(Icons.email_outlined),
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 30),
            
            const Text("Change Password", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
            const SizedBox(height: 10),
            TextField(
              controller: passwordController,
              obscureText: true,
              decoration: const InputDecoration(
                hintText: "Enter new password",
                prefixIcon: Icon(Icons.lock_reset),
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 40),
            
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                onPressed: () {
                  _showReauthDialog(context, emailController.text, passwordController.text);
                },
                child: const Text("SAVE CHANGES"),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Firebase requires re-authentication to change sensitive data
  void _showReauthDialog(BuildContext context, String newEmail, String newPass) {
    final reauthController = TextEditingController();
    Get.defaultDialog(
      title: "Verify Identity",
      content: Column(
        children: [
          const Text("Please enter your CURRENT password to confirm changes."),
          TextField(controller: reauthController, obscureText: true),
        ],
      ),
      textConfirm: "Confirm",
      onConfirm: () {
        // We will call the controller method here
        Get.find<ProfileController>().updateAccountSecurity(
          newEmail: newEmail,
          newPassword: newPass,
          currentPassword: reauthController.text,
        );
      }
    );
  }
}