import 'package:flutter/material.dart';
import '../constants.dart';
import '../widgets/bottom_nav.dart';

class ProfilePage extends StatelessWidget {
  const ProfilePage({super.key});
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Profile'),
        leading: BackButton()),
        body: SafeArea(
        child: Padding(
          padding: EdgeInsets.all(16),
          child: Column(children: [
            CircleAvatar(radius: 44, backgroundImage: AssetImage('assets/images/profile.jpg')),
            SizedBox(height: 12),
            Text('Nadiya Abubakar', style: TextStyle(fontSize: 20, fontWeight: FontWeight.w700)),
            SizedBox(height: 6),
            Text('nadeeya01@gmail.com', style: TextStyle(color: Colors.grey[700])),
            SizedBox(height: 18),
            _ProfileTile(icon: Icons.settings_rounded, label: 'Account Settings', onTap: () => Navigator.pushNamed(context, '/settings')),
            _ProfileTile(icon: Icons.lock_rounded, label: 'Privacy', onTap: () {}),
            _ProfileTile(icon: Icons.notifications_rounded, label: 'Notifications', onTap: () {}),
            _ProfileTile(icon: Icons.help_rounded, label: 'Help & Support', onTap: () {}),
            Spacer(),
            SizedBox(height: 30),
            _buildActionButton(
              icon: Icons.logout,
              title: "Logout",
              subtitle: "Sign out from your account",
              onTap: () {
                Navigator.popAndPushNamed(context, '/login');
              },
              isDestructive: true,
            ),
            SizedBox(height: 20),
          ]),
        ),
      ),
      bottomNavigationBar: BottomNav(currentIndex: 3, onTap: (i) {
        if (i == 0) Navigator.pushReplacementNamed(context, '/');
        if (i == 1) Navigator.pushNamed(context, '/map');
        if (i == 2) Navigator.pushNamed(context, '/analytics');
        if (i == 3) Navigator.pushReplacementNamed(context, '/profile');
      }),
    );
  }

  Widget _buildActionButton({
    required IconData icon,
    required String title,
    String? subtitle,
    VoidCallback? onTap,
    bool isDestructive = false,
  }) {
    return ListTile(
      contentPadding: EdgeInsets.symmetric(vertical: 0),
      leading: Icon(icon, color: isDestructive ? Colors.red : AppColors.safetyBlue),
      title: Text(
        title,
        style: TextStyle(fontWeight: FontWeight.w600, color: isDestructive ? Colors.red : null),
      ),
      subtitle: subtitle != null ? Text(subtitle) : null,
      onTap: onTap,
    );
  }
}

class _ProfileTile extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback? onTap;
  const _ProfileTile({required this.icon, required this.label, this.onTap});

  @override
  Widget build(BuildContext context) {
    return ListTile(
      contentPadding: EdgeInsets.symmetric(vertical: 6),
      leading: Icon(icon, color: AppColors.safetyBlue),
      title: Text(label, style: TextStyle(fontWeight: FontWeight.w600)),
      trailing: Icon(Icons.chevron_right_rounded),
      onTap: onTap,
    );
  }
}
