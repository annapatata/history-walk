import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:historywalk/features/auth/controller/auth_controller.dart';
import 'package:historywalk/common/styles/spacing_styles.dart';
import 'package:historywalk/features/routes/screens/routes_screen.dart';
import 'package:historywalk/utils/constants/text_strings.dart';
import 'package:historywalk/utils/constants/sizes.dart';
import 'package:historywalk/features/auth/screens/register/register_screen.dart';
import '../../controller/login_controller.dart';
import '../../../../navigation_menu.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:get_storage/get_storage.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final AuthController authController = Get.find<AuthController>();
  final LoginController controller = Get.find<LoginController>();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();

  final _formKey = GlobalKey<FormState>();

  @override
  void dispose() {
    emailController.dispose();
    passwordController.dispose();
    super.dispose();
  }

  @override
  void initState(){
    super.initState();
    //auto-full the email if it was saved
    final box = GetStorage();
    if( box.read('REMEMBER_ME_BOOL')==true){
      emailController.text = box.read('REMEMBER_ME_EMAIL') ?? "";
      authController.rememberMe.value = true;
    }
  }
  void _login() async {
    if (!_formKey.currentState!.validate()) return;

    bool success = await authController.login(
      emailController.text.trim(),
      passwordController.text.trim(),
    );

    if (success) {
      Get.offAll(() => const NavigationMenu());
    }
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
                AppTexts.loginTitle,
                style: Theme.of(context).textTheme.headlineMedium,
              ),

              const SizedBox(height: AppSizes.spaceBtwSections / 2),

              // Form
              Form(
                key: _formKey,
                child: Column(
                  children: [
                    // Email
                    TextFormField(
                      controller: emailController,
                      decoration: const InputDecoration(
                        prefixIcon: Icon(Icons.email_outlined),
                        labelText: "Email",
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return "Email is required";
                        }
                        if (!GetUtils.isEmail(value)) {
                          return "Enter a valid email";
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: AppSizes.spaceBtwItems),

                    // Password
                    Obx(
                      () => TextFormField(
                        controller: passwordController,
                        obscureText: !controller.isPasswordVisible.value,
                        decoration: InputDecoration(
                          prefixIcon: Icon(Icons.password_outlined),
                          labelText: "Password",
                          suffixIcon: IconButton(
                            icon: Icon(
                              controller.isPasswordVisible.value
                                  ? Icons.visibility_outlined
                                  : Icons.visibility_off_outlined,
                            ),
                            onPressed: controller.toggleVisibility,
                          ),
                        ),

                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return "Password is required";
                          }
                          if (value.length < 6) {
                            return "Password must be at least 6 characters";
                          }
                          return null;
                        },
                      ),
                    ),

                    const SizedBox(height: AppSizes.spaceBtwItems / 2),

                    // Remember Me & Forget Password
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            Obx(()=>
                            Checkbox(
                              value: authController.rememberMe.value,
                              onChanged: (value) => authController.toggleRememberMe(value))),
                            const Text("Remember Me"),
                          ],
                        ),
                        TextButton(
                          onPressed: () => authController.sendPasswordResetEmail(emailController.text.trim()),
                          child: const Text("Forget Password?"),
                        ),
                      ],
                    ),
                    const SizedBox(height: AppSizes.spaceBtwSections),

                    // Login Button
                    SizedBox(
                      width: double.infinity,
                      child: Obx(
                        () => ElevatedButton(
                          onPressed: authController.isLoading.value
                              ? null
                              : _login,
                          child: authController.isLoading.value
                              ? const SizedBox(
                                  height: 20,
                                  width: 20,
                                  child: CircularProgressIndicator(
                                    color: Colors.white,
                                    strokeWidth: 2,
                                  ),
                                )
                              : const Text("Let's Go!"),
                        ),
                      ),
                    ),

                    const SizedBox(height: AppSizes.spaceBtwSections / 2),

                    // Register link
                    TextButton(
                      onPressed: () {
                        Get.to(() => const RegisterScreen());
                      },
                      child: const Text("Don't have an account? Register"),
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
