import 'package:flutter/material.dart';
import '../features/routes/screens/routes_screen.dart';
import '../features/map/screens/map_screen.dart';
import '../features/profile/screens/profile_screen.dart';




class NavigationMenu extends StatefulWidget {
  const NavigationMenu({super.key});

  @override
  State<NavigationMenu> createState() => _NavigationMenuState();
}
class _NavigationMenuState extends State<NavigationMenu> {
  int selectedIndex =0;

  final List<Widget> screens =  [
    RoutesScreen(),
    MapScreen(),
    ProfileScreen(),
  ];

  @override
  Widget build(BuildContext context){
    return Scaffold(
      body: screens[selectedIndex],

      bottomNavigationBar: NavigationBar(
        selectedIndex: selectedIndex,
        onDestinationSelected: (index) {
          setState(() {
            selectedIndex = index; //this updates the UI
          });
        },
        destinations: const[
          NavigationDestination(icon: Icon(Icons.route), label: "Routes"),
          NavigationDestination(icon: Icon(Icons.map), label: "Map"),
          NavigationDestination(icon: Icon(Icons.person), label: "Profile"),
        ],
        ),
    );
  }
}

