import 'package:get/get.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:historywalk/features/profile/models/user_profile.dart';
import 'package:get_storage/get_storage.dart';

class AuthController extends GetxController {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  final GetStorage _box = GetStorage();
  RxBool rememberMe = false.obs;

  /// Ο τρέχων χρήστης (null αν δεν είναι logged in)
  Rxn<User> firebaseUser = Rxn<User>();
  Rxn<User> userProfile = Rxn<User>();

  @override
  void onInit() {
    super.onInit();
    // Ακούει αν αλλάξει το login state (login / logout)
    firebaseUser.bindStream(_auth.authStateChanges());
  }

  
  RxBool isLoading = false.obs;

  /// Register με email & password & name
  Future<void> register(String email, String password, String name) async {
    isLoading.value = true;

    try {
      UserCredential credential = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      UserProfile newUser = UserProfile(
        uid: credential.user!.uid,
        name: name,
        email: email,
        nationality: 'Unknown',
        avatarPath: 'assets/icons/no_pfp.png',
        firstLoginDate: DateTime.now(),
        level: 1,
        progress: 0,
      );

      print("Attempting to save user to Firestore: ${credential.user!.uid}");

      await _db
          .collection('users')
          .doc(credential.user!.uid)
          .set(newUser.toJson());
      Get.snackbar('Success', 'Account created successfully');
    } on FirebaseAuthException catch (e) {
      Get.snackbar('Register error', e.message ?? 'Something went wrong');
    } finally {
      isLoading.value = false;
    }
  }

  /// Login με email & password
  Future<bool> login(String email, String password) async {
    try {
      isLoading.value = true;
      await _auth.signInWithEmailAndPassword(email: email, password: password);
      // Save email if Remember Me is checked
      if (rememberMe.value) {
        _box.write('REMEMBER_ME_EMAIL', email);
        _box.write('REMEMBER_ME_BOOL', true);
      } else {
        _box.remove('REMEMBER_ME_EMAIL');
        _box.write('REMEMBER_ME_BOOL', false);
      }
      return true;
    } on FirebaseAuthException catch (e) {
      Get.snackbar('Login error', e.message ?? 'Something went wrong');
      return false;
    } finally {
      isLoading.value = false;
    }
  }

  /// Logout
  Future<void> logout() async {
    await _auth.signOut();
  }

  //password reset
  Future<void> sendPasswordResetEmail(String email) async {
    try {
      if (email.isEmpty) {
        Get.snackbar("Error", "Please enter your email first");
        return;
      }
      await _auth.sendPasswordResetEmail(email: email);
      Get.snackbar("Success", "Password reset link sent to $email");
    } catch (e) {
      Get.snackbar("Error", e.toString());
    }
  }

  void toggleRememberMe(bool? value) {
    rememberMe.value = value ?? false;
  }
}
