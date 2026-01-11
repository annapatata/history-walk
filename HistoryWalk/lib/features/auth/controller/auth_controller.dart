import 'package:get/get.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:historywalk/features/profile/models/user_profile.dart';
import 'package:historywalk/features/routes/screens/routes_screen.dart';
import '../screens/login/login_screen.dart';

class AuthController extends GetxController {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  /// Ο τρέχων χρήστης (null αν δεν είναι logged in)
  Rxn<User> firebaseUser = Rxn<User>();

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
        name:name,
        email:email,
        nationality: 'Unknown',
        avatarPath: 'assets/icons/no_pfp.png',
        firstLoginDate: DateTime.now(),
        level: 1,
        progress: 0,
      );

      
    print("Attempting to save user to Firestore: ${credential.user!.uid}");

      await _db.collection('users').doc(credential.user!.uid).set(newUser.toJson());
      Get.snackbar('Success','Account created successfully');
    } on FirebaseAuthException catch (e) {
      Get.snackbar(
        'Register error',
        e.message ?? 'Something went wrong',
      );
    } finally {
      isLoading.value=false;
    }
  }

  /// Login με email & password
  Future<bool> login(String email, String password) async {
    try {
      await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      return true;
    } on FirebaseAuthException catch (e) {
      Get.snackbar(
        'Login error',
        e.message ?? 'Something went wrong',
      );
      return false;
    } catch (e){
      return false;
    }
  }

  /// Logout
  Future<void> logout() async {
    await _auth.signOut();
  }
}