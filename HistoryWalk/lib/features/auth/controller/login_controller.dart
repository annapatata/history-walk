import 'package:get/get.dart';

class LoginController extends GetxController {
  var isPasswordVisible = false.obs;

  void toggleVisibility() {
    isPasswordVisible.value = !isPasswordVisible.value;
  }
}