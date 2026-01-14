import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'preferences.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final PageController _pageController = PageController();
  int _currentPage = 0;

  void _nextPage() {
    if (_currentPage < 2) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 400),
        curve: Curves.easeInOut,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFDF5E6), // Matching your warm background
      body: Stack(
        children: [
          PageView(
            controller: _pageController,
            onPageChanged: (index) => setState(() => _currentPage = index),
            children: [
              _buildMiloWave(),
              _buildHistoryPath(),
              const PreferencesScreen(), // Your imported preferences.dart
            ],
          ),
          // Progress Dots
          if (_currentPage < 2)
            Positioned(
              bottom: 50,
              left: 0,
              right: 0,
              child: Center(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: List.generate(3, (index) => _buildDot(index)),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildDot(int index) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      margin: const EdgeInsets.only(right: 8),
      height: 8,
      width: _currentPage == index ? 24 : 8,
      decoration: BoxDecoration(
        color: _currentPage == index ? const Color(0xFFE9B32A) : Colors.grey[300],
        borderRadius: BorderRadius.circular(4),
      ),
    );
  }

  // --- Screen 1: Milo Wave ---
  Widget _buildMiloWave() {
    return Padding(
      padding: const EdgeInsets.all(40.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Image.asset('assets/images/milowave.png', height: 300),
          const SizedBox(height: 30),
          const Text(
            "Hi! I'm Milo",
            style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: Color(0xFF8B4513)),
          ),
          const SizedBox(height: 15),
          const Text(
            "I'll be your personal guide as we uncover the secrets of the city together!",
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 18, color: Colors.black87),
          ),
          const Spacer(),
          
        ],
      ),
    );
  }

  // --- Screen 2: History Path ---
  Widget _buildHistoryPath() {
    return Padding(
      padding: const EdgeInsets.all(40.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.map_outlined, size: 150, color: Color(0xFFE9B32A)), // Placeholder for path image
          const SizedBox(height: 30),
          const Text(
            "Walk Through Time",
            style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 15),
          const Text(
            "Choose a route, follow the map, and listen to the stories that shaped our world.",
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 18),
          ),
          const Spacer(),
        ],
      ),
    );
  }
}