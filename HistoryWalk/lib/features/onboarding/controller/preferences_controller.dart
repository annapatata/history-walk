import 'package:get/get.dart';

class PreferencesController extends GetxController {
  // Lists to store selected IDs or Names
  var selectedPeriods = <String>[].obs;
  var selectedDuration = <String>[].obs;

  void togglePeriod(String period) {
    if (selectedPeriods.contains(period)) {
      selectedPeriods.remove(period);
    } else {
      selectedPeriods.add(period);
    }
  }

  void toggleDuration(String topic) {
    if (selectedDuration.contains(topic)) {
      selectedDuration.remove(topic);
    } else {
      selectedDuration.add(topic);
    }
  }
}