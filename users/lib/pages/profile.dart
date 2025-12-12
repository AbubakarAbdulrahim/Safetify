import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import '../constants.dart';
import '../widgets/bottom_nav.dart';
import 'package:safetify/services/auth_service.dart';
import '../services/theme_service.dart';
import '../services/firestore_service.dart';
import '../models/users.dart' as model;

class ProfilePage extends StatelessWidget {
  ProfilePage({super.key});
  
  final AuthService authService = AuthService();

  Future<void> logout(BuildContext context) async {
    await authService.logout();
    if (!context.mounted) return;
    Navigator.pushReplacementNamed(context, '/welcome');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Profile'),
        leading: const BackButton(),
        actions: [
          ValueListenableBuilder<ThemeMode>(
            valueListenable: ThemeService().themeMode,
            builder: (context, mode, child) {
              IconData icon;
              if (mode == ThemeMode.light) icon = Icons.light_mode;
              else if (mode == ThemeMode.dark) icon = Icons.dark_mode;
              else icon = Icons.settings_system_daydream;
              
              return IconButton(
                icon: Icon(icon),
                onPressed: () {
                  _showThemeSelector(context);
                },
              );
            },
          ),
        ],
      ),
      body: SafeArea(
        child: StreamBuilder<model.User>(
          stream: FirestoreService().getUserStream(FirebaseAuth.instance.currentUser!.uid),
          builder: (context, snapshot) {
            // Use Firestore data if available, otherwise fallback to Auth data
            String? name = "User";
            String? email = "No Email";
            String? image;

            if (snapshot.hasData) {
              final user = snapshot.data!;
              name = user.name;
              email = user.email;
              image = user.profileImage;
            } else {
              // Fallback to Firebase Auth data while loading
              final authUser = FirebaseAuth.instance.currentUser;
              if (authUser != null) {
                name = authUser.displayName ?? "User";
                email = authUser.email ?? "No Email";
                image = authUser.photoURL;
              }
            }

            if (!snapshot.hasData && FirebaseAuth.instance.currentUser == null) {
              return const Center(child: CircularProgressIndicator());
            }

            return CustomScrollView(
              slivers: [
                SliverFillRemaining(
                  hasScrollBody: false,
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(children: [
                      CircleAvatar(
                        radius: 44,
                        backgroundColor: Colors.grey[200],
                        backgroundImage: image != null && image.isNotEmpty
                            ? NetworkImage(image)
                            : const AssetImage('assets/images/profile.png') as ImageProvider,
                      ),
                      const SizedBox(height: 12),
                      Text(name ?? "User", style: TextStyle(fontSize: 20, fontWeight: FontWeight.w700, color: Theme.of(context).textTheme.bodyLarge?.color)),
                      const SizedBox(height: 6),
                      Text(email ?? "No Email", style: TextStyle(color: Theme.of(context).textTheme.bodyMedium?.color)),
                      const SizedBox(height: 18),
                      _ProfileTile(icon: Icons.settings_rounded, label: 'Account & Settings', onTap: () => Navigator.pushNamed(context, '/settings')),
                      _ProfileTile(icon: Icons.privacy_tip_rounded, label: 'Privacy Policy', onTap: () => Navigator.pushNamed(context, '/privacy')),
                      _ProfileTile(icon: Icons.description_rounded, label: 'Terms & Conditions', onTap: () => Navigator.pushNamed(context, '/terms')),
                      _ProfileTile(icon: Icons.help_rounded, label: 'Help & Support', onTap: () => Navigator.pushNamed(context, '/help')),
                      _ProfileTile(icon: Icons.info_rounded, label: 'About', onTap: () => Navigator.pushNamed(context, '/about')),
                      const Spacer(),
                      const SizedBox(height: 30),
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton.icon(
                          onPressed: () {
                            showDialog(
                              context: context,
                              builder: (_) => AlertDialog(
                                title: const Text('Logout'),
                                content: const Text('Are you sure you want to logout?'),
                                actions: [
                                  TextButton(
                                    onPressed: () => Navigator.pop(context),
                                    child: const Text('Cancel'),
                                  ),
                                  TextButton(
                                    onPressed: () async {
                                      Navigator.pop(context); // Close dialog
                                      await authService.logout();
                                      if (!context.mounted) return;
                                      Navigator.pushNamedAndRemoveUntil(
                                        context, 
                                        '/login', 
                                        (route) => false
                                      );
                                    },
                                    child: const Text('Logout', style: TextStyle(color: Colors.red)),
                                  ),
                                ],
                              ),
                            );
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.red.shade100.withOpacity( 0.3),
                            foregroundColor: Colors.red,
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                              side: BorderSide(color: Colors.red.shade200),
                            ),
                            elevation: 0,
                          ),
                          icon: const Icon(Icons.logout_rounded),
                          label: const Text(
                            "Logout",
                            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                          ),
                        ),
                      ),
                      const SizedBox(height: 10),
                    ]),
                  ),
                ),
              ],
            );
          },
        ),
      ),
      bottomNavigationBar: BottomNav(currentIndex: 3, onTap: (i) {
        if (i == 0) Navigator.pushReplacementNamed(context, '/home');
        if (i == 1) Navigator.pushNamed(context, '/map');
        if (i == 2) Navigator.pushNamed(context, '/ai');
        if (i == 3) Navigator.pushReplacementNamed(context, '/profile');
      }),
    );
  }

  void _showThemeSelector(BuildContext context) {
    showModalBottomSheet(
      context: context,
      builder: (context) {
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: const Icon(Icons.light_mode),
                title: const Text('Light'),
                onTap: () {
                  ThemeService().setTheme(ThemeMode.light);
                  Navigator.pop(context);
                },
              ),
              ListTile(
                leading: const Icon(Icons.dark_mode),
                title: const Text('Dark'),
                onTap: () {
                  ThemeService().setTheme(ThemeMode.dark);
                  Navigator.pop(context);
                },
              ),
              ListTile(
                leading: const Icon(Icons.settings_system_daydream),
                title: const Text('System'),
                onTap: () {
                  ThemeService().setTheme(ThemeMode.system);
                  Navigator.pop(context);
                },
              ),
            ],
          ),
        );
      },
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
      contentPadding: const EdgeInsets.symmetric(vertical: 0),
      leading: Icon(icon, color: isDestructive ? Colors.red : AppColors.safetyBlue),
      title: Text(
        title,
        style: TextStyle(fontWeight: FontWeight.w600, color: isDestructive ? Colors.red : null),
      ),
      subtitle: subtitle != null ? Text(subtitle) : null,
      onTap: onTap,
    );
  }

  Widget _buildStatItem(BuildContext context, String value, String label) {
    return Column(
      children: [
        Text(
          value,
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Theme.of(context).textTheme.bodyLarge?.color,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            color: Theme.of(context).textTheme.bodyMedium?.color,
          ),
        ),
      ],
    );
  }

  Widget _buildVerticalDivider(BuildContext context) {
    return Container(
      height: 30,
      width: 1,
      color: Theme.of(context).dividerColor,
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
      contentPadding: const EdgeInsets.symmetric(vertical: 6),
      leading: Icon(icon, color: AppColors.safetyBlue),
      title: Text(label, style: const TextStyle(fontWeight: FontWeight.w600)),
      trailing: const Icon(Icons.chevron_right_rounded),
      onTap: onTap,
    );
  }
}
