import 'package:get/get.dart';
import 'package:firebase_auth/firebase_auth.dart';

class AuthController extends GetxController {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  /// Ο τρέχων χρήστης (null αν δεν είναι logged in)
  Rxn<User> firebaseUser = Rxn<User>();

  @override
  void onInit() {
    super.onInit();
    // Ακούει αν αλλάξει το login state (login / logout)
    firebaseUser.bindStream(_auth.authStateChanges());
  }

  /// Register με email & password
  Future<void> register(String email, String password) async {
    try {
      await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
    } on FirebaseAuthException catch (e) {
      Get.snackbar(
        'Register error',
        e.message ?? 'Something went wrong',
      );
    }
  }

  /// Login με email & password
  Future<void> login(String email, String password) async {
    try {
      await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
    } on FirebaseAuthException catch (e) {
      Get.snackbar(
        'Login error',
        e.message ?? 'Something went wrong',
      );
    }
  }

  /// Logout
  Future<void> logout() async {
    await _auth.signOut();
  }
}