import 'package:flutter/material.dart';
import '../constants.dart';

class BottomNav extends StatelessWidget {
  final int currentIndex;
  final Function(int) onTap;

  const BottomNav({Key? key, required this.currentIndex, required this.onTap}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return BottomNavigationBar(
      backgroundColor: AppColors.card,
      currentIndex: currentIndex,
      onTap: onTap,
      selectedItemColor: AppColors.safetyBlue,
      unselectedItemColor: Colors.grey[500],
      showSelectedLabels: true,
      showUnselectedLabels: true,
      items: [
        BottomNavigationBarItem(icon: Icon(Icons.home_rounded), label: 'Home'),
        BottomNavigationBarItem(icon: Icon(Icons.map_rounded), label: 'Map'),
        BottomNavigationBarItem(icon: Icon(Icons.insights_rounded), label: 'Analytics'),
        BottomNavigationBarItem(icon: Icon(Icons.person_rounded), label: 'Profile'),
      ],
      type: BottomNavigationBarType.fixed,
    );
  }
}
