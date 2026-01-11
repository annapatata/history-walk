import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:historywalk/features/auth/controller/auth_controller.dart';
import 'package:historywalk/common/styles/spacing_styles.dart';
import 'package:historywalk/features/auth/controller/login_controller.dart';
import 'package:historywalk/utils/constants/text_strings.dart';
import 'package:historywalk/utils/constants/sizes.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final AuthController authController = Get.find<AuthController>();

  final TextEditingController emailController = TextEditingController();
  final TextEditingController nameController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController confirmPasswordController =
      TextEditingController();
  final LoginController controller = Get.find<LoginController>();

  final _formKey = GlobalKey<FormState>();

  @override
  void dispose() {
    emailController.dispose();
    passwordController.dispose();
    confirmPasswordController.dispose();
    nameController.dispose();
    super.dispose();
  }

  void _register() async {
    if (!_formKey.currentState!.validate()) return;

    if (passwordController.text.trim() !=
        confirmPasswordController.text.trim()) {
      Get.snackbar("Error", "Passwords do not match");
      return;
    }

    await authController.register(
      emailController.text.trim(),
      passwordController.text.trim(),
      nameController.text.trim(),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        child: Padding(
          padding: SpacingStyle.paddingWithAppBarHeight,
          child: Column(
            children: [
              // Title
              Text(
                AppTexts.registerTitle,
                style: Theme.of(context).textTheme.headlineMedium,
              ),

              const SizedBox(height: AppSizes.spaceBtwSections / 2),

              // Form
              Form(
                key: _formKey,
                child: Column(
                  children: [
                    // Name
                    TextFormField(
                      controller: nameController,
                      decoration: const InputDecoration(
                        prefixIcon: Icon(Icons.person_outlined),
                        labelText: "Name",
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty)
                          return "Name is required";
                        return null;
                      },
                    ),
                    const SizedBox(height: AppSizes.spaceBtwItems),
                    // Email
                    TextFormField(
                      controller: emailController,
                      decoration: const InputDecoration(
                        prefixIcon: Icon(Icons.email_outlined),
                        labelText: "Email",
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty)
                          return "Email is required";
                        if (!GetUtils.isEmail(value))
                          return "Enter a valid email";
                        return null;
                      },
                    ),
                    const SizedBox(height: AppSizes.spaceBtwItems),

                    // Password
                    Obx(()=> TextFormField(
                      controller: passwordController,
                      obscureText: !controller.isPasswordVisible.value,
                      decoration: InputDecoration(
                        prefixIcon: Icon(Icons.password_outlined),
                        labelText: "Password",
                        suffixIcon: IconButton(
                          icon: Icon(
                            controller.isPasswordVisible.value
                                ? Icons.visibility
                                : Icons.visibility_off,
                          ),
                          onPressed: controller.toggleVisibility,
                        ),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty)
                          return "Password is required";
                        if (value.length < 6)
                          return "Password must be at least 6 characters";
                        return null;
                      },
                    ),
                    ),
                    const SizedBox(height: AppSizes.spaceBtwItems),

                    // Confirm Password
                    Obx(()=> TextFormField(
                      controller: confirmPasswordController,
                      obscureText: !controller.isPasswordVisible.value,
                      decoration:InputDecoration(
                        prefixIcon: Icon(Icons.password_outlined),
                        labelText: "Confirm Password",
                        suffixIcon: IconButton(
                          icon: Icon(
                            controller.isPasswordVisible.value
                                ? Icons.visibility
                                : Icons.visibility_off,
                          ),
                          onPressed: controller.toggleVisibility,
                        ),
                      ),
                      
                      validator: (value) {
                        if (value == null || value.isEmpty)
                          return "Confirm password is required";
                        return null;
                      },
                    ),
                    ),

                    const SizedBox(height: AppSizes.spaceBtwSections),

                    // Register Button
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: _register,
                        child: const Text("Register"),
                      ),
                    ),

                    const SizedBox(height: AppSizes.spaceBtwSections / 2),

                    // Login link
                    TextButton(
                      onPressed: () {
                        Get.back(); // πίσω στο login screen
                      },
                      child: const Text("Already have an account? Login"),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
