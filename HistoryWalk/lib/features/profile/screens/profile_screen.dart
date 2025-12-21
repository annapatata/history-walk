// Profile_screen.dart
import 'package:flutter/material.dart';
import '../widgets/passport.dart';
import 'package:historywalk/common/layouts/section_screen.dart';
import '../widgets/progressbar.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return SectionScreenLayout(
      title:'PROFILE',
      showSearch:false,
      body: ListView(
              children:[ 
                PassportCard(),
                const SizedBox(height:12),
                ProfileProgressBar(
                  progress:59,
                  label: "Exploring Athens",
                  icon: Icon(Icons.account_balance, size:20),
                )
              ],
            )
    );
  }
}
