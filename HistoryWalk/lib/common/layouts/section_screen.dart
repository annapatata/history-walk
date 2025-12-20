import 'package:flutter/material.dart';
import '../widgets/searchbar.dart';

class SectionScreenLayout extends StatelessWidget {
  const SectionScreenLayout({
    super.key,
    required this.title,
    required this.body,
    this.showSearch = true,
  });

  final String title;
  final Widget body;
  final bool showSearch;

  static const double horizontalPadding = 50;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: horizontalPadding),
      child: Column(
        children: [
          const SizedBox(height: 8),

          // Title
          Center(
            child: Text(
              title,
              style: Theme.of(context).textTheme.headlineMedium!.copyWith(
                    fontSize: 28,
                    fontWeight: FontWeight.w800,
                  ),
            ),
          ),

          // Search bar
          if (showSearch)
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 20),
              child: HWSearchBar(),
            ),

          // Screen-specific content
          Expanded(child: body),
        ],
      ),
    );
  }
}
