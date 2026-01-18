import 'package:flutter/material.dart';
import '../controller/preferences_controller.dart';
import 'package:get/get.dart';
import '../../routes/controller/route_controller.dart';
import '../../../navigation_menu.dart';

class PreferencesScreen extends StatelessWidget {
  const PreferencesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(PreferencesController());

    return Scaffold(
      backgroundColor: const Color(0xFFFDF5E6),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 30),
          child: Column(
            children: [
              // Expanded για να πάρει όλο το διαθέσιμο ύψος
              Expanded(
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 40),
                      const Center(
                        child: Text(
                          "I'm interested in...",
                          style: TextStyle(
                            fontSize: 26,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF8B4513),
                          ),
                        ),
                      ),
                      const SizedBox(height: 30),

                      _sectionHeader("Time Periods"),
                      Obx(
                        () => Column(
                          children: [
                            _buildPreferenceRow(
                              label: "Ancient Greece",
                              isSelected: controller.selectedPeriods.contains("ancient"),
                              onTap: () => controller.togglePeriod("ancient"),
                            ),
                            _buildPreferenceRow(
                              label: "Roman Empire",
                              isSelected: controller.selectedPeriods.contains("roman"),
                              onTap: () => controller.togglePeriod("roman"),
                            ),
                            _buildPreferenceRow(
                              label: "Medieval Times",
                              isSelected: controller.selectedPeriods.contains("medieval"),
                              onTap: () => controller.togglePeriod("medieval"),
                            ),
                            _buildPreferenceRow(
                              label: "Modern History",
                              isSelected: controller.selectedPeriods.contains("modern"),
                              onTap: () => controller.togglePeriod("modern"),
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(height: 20),
                      _sectionHeader("Duration"),
                      Obx(
                        () => Column(
                          children: [
                            _buildPreferenceRow(
                              label: "I like long walks",
                              isSelected: controller.selectedDuration.contains("60+ min"),
                              onTap: () => controller.toggleDuration("60+ min"),
                            ),
                            _buildPreferenceRow(
                              label: "I have some free time",
                              isSelected: controller.selectedDuration.contains("30+ min"),
                              onTap: () => controller.toggleDuration("30+ min"),
                            ),
                            _buildPreferenceRow(
                              label: "I'm busy but keen to learn",
                              isSelected: controller.selectedDuration.contains("15+ min"),
                              onTap: () => controller.toggleDuration("15+ min"),
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(height: 40),
                    ],
                  ),
                ),
              ),

              // Κουμπί πάντα visible
              Center(
                child: ElevatedButton(
                  onPressed: () {
                    final routeController = Get.put(RouteController());
                    routeController.preffilters(
                      periods: controller.selectedPeriods,
                      durations: controller.selectedDuration.toList(),
                    );
                    Get.offAll(() => const NavigationMenu());
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.white,
                    foregroundColor: Colors.black,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 60,
                      vertical: 15,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30),
                    ),
                    elevation: 5,
                  ),
                  child: const Text(
                    "ALL SET!",
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 18,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 40),
            ],
          ),
        ),
      ),
    );
  }

  Widget _sectionHeader(String title) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 25, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.9),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        title,
        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
      ),
    );
  }

  Widget _buildPreferenceRow({
    required String label,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 12.0),
        child: Row(
          children: [
            Icon(
              isSelected
                  ? Icons.favorite_rounded
                  : Icons.favorite_outline_rounded,
              color: const Color(0xFFF39237),
              size: 32,
            ),
            const SizedBox(width: 20),
            Text(
              label,
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w600,
                color: Colors.black,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
