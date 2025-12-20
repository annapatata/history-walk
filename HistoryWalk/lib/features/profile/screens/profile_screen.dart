// Profile_screen.dart
import 'package:flutter/material.dart';
import '../widgets/passport.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return(
      
      Padding(
        padding: const EdgeInsets.all(16),
        child: PassportCard(),
      )
    );
  }
}
