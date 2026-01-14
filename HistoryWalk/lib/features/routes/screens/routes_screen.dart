import 'package:flutter/material.dart';
import 'package:historywalk/features/reviews/controller/review_controller.dart';
import '../widgets/route_box.dart';
import 'routedetails.dart';
import 'package:historywalk/common/layouts/section_screen.dart';
import '../../profile/controller/profile_controller.dart';
import 'package:get/get.dart';
import '../controller/route_controller.dart';

class RoutesScreen extends StatelessWidget {
  const RoutesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final ProfileController profileController = Get.find();
    final ReviewController reviewController = Get.put(ReviewController());
    final RouteController routeController = Get.put(RouteController());

    return Scaffold(
      body: SectionScreenLayout(
        title: 'ROUTES',
        body: Column(
          children: [
            // --- DROPDOWN PILLS ROW ---
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 10),
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 15),
                child: Row(
                  children: [
                    // 1. Time Period Dropdown
                    _buildDropdownPill(
                      label: "Period",
                      currentValue: routeController.selectedPeriod,
                      items: ['All', 'Ancient Greece', 'Roman Empire', 'WW2', 'Byzantine', 'Medieval', 'Modern'],
                      onChanged: (val) => routeController.updateFilter('period', val),
                    ),
                    const SizedBox(width: 8),
                    // 2. Difficulty Dropdown
                    _buildDropdownPill(
                      label: "Difficulty",
                      currentValue: routeController.selectedDifficulty,
                      items: ['All', 'Easy', 'Medium', 'Hard'],
                      onChanged: (val) => routeController.updateFilter('difficulty', val),
                    ),
                    const SizedBox(width: 8),
                    // 3. Duration Dropdown
                    _buildDropdownPill(
                      label: "Duration",
                      currentValue: routeController.selectedDuration,
                      items: ['All', '15+ min', '30+ min', '60+ min'],
                      onChanged: (val) => routeController.updateFilter('duration', val),
                    ),
                  ],
                ),
              ),
            ),

            // --- ROUTE LIST ---
            Expanded(
              child: Obx(() {
                if (routeController.isLoading.value) {
                  return const Center(child: CircularProgressIndicator());
                }

                final routes =
                    routeController.displayRoutes; // Get the sorted list

                return ListView.builder(
                  itemCount: routes.length,
                  itemBuilder: (context, index) {
                    final route = routes[index];
                    final bool finished = profileController.isRouteCompleted(
                      route.id,
                    );

                    // Visual indicator if the route matches the current filter
                    bool isMatch = routeController.checkMatch(route);

                    return Opacity(
                      // Subtly dim routes that don't match the filter
                      opacity: isMatch ? 1.0 : 0.6,
                      child: Stack(
                        children: [
                          RouteBox(
                            route: route,
                            onTap: () {
                              reviewController.fetchReviews(route.id);
                              Get.to(() => RouteDetails(route: route));
                            },
                          ),
                          if (finished)
                            const Positioned(
                              top: 10,
                              right: 10,
                              child: Icon(
                                Icons.check_circle,
                                color: Colors.green,
                                size: 30,
                              ),
                            ),
                        ],
                      ),
                    );
                  },
                );
              }),
            ),
          ],
        ),
      ),
    );
  }

  // --- HELPER WIDGET FOR DROPDOWN PILLS ---
  Widget _buildDropdownPill({
    required String label,
    required RxString currentValue,
    required List<String> items,
    required Function(String) onChanged,
  }) {
    return Obx(() {
      bool isActive = currentValue.value != 'All';
      
      return PopupMenuButton<String>(
        onSelected: onChanged,
        itemBuilder: (context) => items.map((item) => PopupMenuItem(
          value: item,
          child: Text(item),
        )).toList(),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
          decoration: BoxDecoration(
            color: isActive ? const Color(0xFFE9B32A) : Colors.white,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: Colors.grey.shade300),
          ),
          child: Row(
            children: [
              Text(
                isActive ? currentValue.value : label,
                style: TextStyle(
                  color: isActive ? Colors.white : Colors.black,
                  fontWeight: FontWeight.bold,
                  fontSize: 13,
                ),
              ),
              const SizedBox(width: 4),
              Icon(
                Icons.arrow_drop_down,
                color: isActive ? Colors.white : Colors.black54,
              ),
            ],
          ),
        ),
      );
    });
  }
}

