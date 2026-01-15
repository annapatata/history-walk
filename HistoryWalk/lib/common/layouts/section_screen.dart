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

  double _horizontalPadding(BuildContext context) {
    final width = MediaQuery.of(context).size.width;

    if (width < 600) {
      // Phone
      return 16;
    } else if (width < 1024) {
      // Tablet
      return 32;
    } else {
      // Web / Desktop
      return 50;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold (
    backgroundColor: Theme.of(context).scaffoldBackgroundColor,
    body:SafeArea(
      child: Padding(
        padding: EdgeInsets.symmetric(
          horizontal: _horizontalPadding(context),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const SizedBox(height: 8),

            // Title
            Text(
              title,
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                    fontSize: 28,
                    fontWeight: FontWeight.w800,
                  ),
            ),

            // Search bar
            if (showSearch) ...[
              const SizedBox(height: 20),
              const HWSearchBar(),
            ],

            const SizedBox(height: 16),

            // Screen-specific content
            Expanded(child: body),
          ],
        ),
      ),
    ),
    );
  }
}
