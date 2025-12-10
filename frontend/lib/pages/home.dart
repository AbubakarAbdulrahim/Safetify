import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:safetify/models/incidents.dart';
import 'package:safetify/models/users.dart' as model;
import 'package:safetify/services/url_launcher_service.dart';
import 'package:timeago/timeago.dart' as timeago;
import '../constants.dart';
import '../widgets/bottom_nav.dart';
import '../widgets/incident_card.dart';
import '../services/firestore_service.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  _HomePageState createState() => _HomePageState();
}

class _ModernQuickCard extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback? onTap;
  final List<Color> gradientColors;

  const _ModernQuickCard({
    required this.icon,
    required this.label,
    this.onTap,
    required this.gradientColors,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: gradientColors,
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: gradientColors.last.withOpacity(0.3),
              blurRadius: 8,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.2),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(icon, color: Colors.white, size: 24),
            ),
            Text(
              label,
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                color: Colors.white,
                fontSize: 14,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _HomePageState extends State<HomePage> {

  Set<String> _readNotificationIds = {};

  @override
  void initState() {
    super.initState();
    _loadReadStatus();
  }

  Future<void> _loadReadStatus() async {
    final prefs = await SharedPreferences.getInstance();
    final readIds = prefs.getStringList('read_notifications') ?? [];
    if (mounted) {
      setState(() {
        _readNotificationIds = readIds.toSet();
      });
    }
  }

  void _onNavTap(int index) {
    if (index == 0) return; // Home by default
    if (index == 1) Navigator.pushNamed(context, '/map');
    if (index == 2) Navigator.pushNamed(context, '/ai');
    if (index == 3) Navigator.pushNamed(context, '/profile');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        elevation: 0,
        automaticallyImplyLeading: false,
        title: Row(
          children: [
            Text(
              'Safetify',
              style: GoogleFonts.poppins(
                fontWeight: FontWeight.bold,
                fontSize: 24,
                color: AppColors.safetyBlue,
              ),
            ),
          ],
        ),
        actions: [
          StreamBuilder<List<Incident>>(
            stream: FirestoreService().getAllIncidents(limit: 50),
            builder: (context, snapshot) {
              final incidents = snapshot.data ?? [];
              final hasUnread = incidents.any((i) => !_readNotificationIds.contains(i.id));
              
              return IconButton(
                onPressed: () async {
                  await Navigator.pushNamed(context, '/notifications');
                  _loadReadStatus(); // Refresh when returning
                },
                icon: Stack(
                  clipBehavior: Clip.none,
                  children: [
                    Icon(
                      Icons.notifications_rounded,
                      color: Theme.of(context).iconTheme.color,
                    ),
                    if (hasUnread)
                      Positioned(
                        right: 0,
                        top: 0,
                        child: Container(
                          width: 10,
                          height: 10,
                          decoration: BoxDecoration(
                            color: AppColors.alertRed,
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: Theme.of(context).scaffoldBackgroundColor,
                              width: 2,
                            ),
                          ),
                        ),
                      ),
                  ],
                ),
              );
            },
          ),
        ],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Greeting
              _buildHeader(),
              const SizedBox(height: 20),

              // SOS Button
              _buildSOSButton(),
              const SizedBox(height: 24),

              // Community Updates Carousel
              _buildUpdatesCarousel(),
              const SizedBox(height: 24),

              // Grid Cards
              const Text(
                "Quick Actions",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 12),
              GridView.count(
                crossAxisCount: 2,
                shrinkWrap: true,
                crossAxisSpacing: 12,
                mainAxisSpacing: 12,
                physics: const NeverScrollableScrollPhysics(),
                childAspectRatio: 1.5,
                children: [
                  _ModernQuickCard(
                    icon: Icons.assignment_add,
                    label: 'Report Incident',
                    onTap: () => Navigator.pushNamed(context, '/report'),
                    gradientColors: [AppColors.safetyBlue, Colors.blue.shade600],
                  ),
                  _ModernQuickCard(
                    icon: Icons.leaderboard_rounded,
                    label: 'Analytics',
                    onTap: () => Navigator.pushNamed(context, '/analytics'),
                    gradientColors: [Colors.blue.shade600, AppColors.safetyBlue],
                  ),
                  _ModernQuickCard(
                    icon: Icons.add_call,
                    label: 'Emergency',
                    onTap: () => Navigator.pushNamed(context, '/emergency_contacts'),
                    gradientColors: [Colors.blue.shade600, AppColors.safetyBlue],
                  ),
                  _ModernQuickCard(
                    icon: Icons.campaign_rounded,
                    label: 'Community',
                    onTap: () => Navigator.pushNamed(context, '/community_updates'),
                    gradientColors: [AppColors.safetyBlue, Colors.blue.shade600],
                  ),
                ],
              ),
              const SizedBox(height: 24),

              // 5. Recent Reports
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Recent Reports',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  InkWell(
                    onTap: () => Navigator.pushNamed(context, '/history'),
                    child: Text(
                      'View All',
                      style: TextStyle(
                        fontSize: 14,
                        color: AppColors.safetyBlue,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              _buildRecentIncidents(),
            ],
          ),
        ),
      ),
      bottomNavigationBar: BottomNav(currentIndex: 0, onTap: _onNavTap),
    );
  }

  Widget _buildHeader() {
    return FutureBuilder<model.User>(
      future: FirestoreService().getUser(FirebaseAuth.instance.currentUser!.uid),
      builder: (context, snapshot) {
        final name = snapshot.data?.name ?? '...';
        return Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Flexible(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Hello, $name 👋',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Theme.of(context).textTheme.bodyLarge?.color,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildSOSButton() {
    return GestureDetector(
      onTap: () {
        // Call emergency 
        UrlLauncherService.makePhoneCall("112"); 
      },
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [Color(0xFFFF512F), Color(0xFFDD2476)],
          ),
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFFDD2476).withOpacity(0.4),
              blurRadius: 12,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.2),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.sos_rounded, color: Colors.white, size: 32),
            ),
            const SizedBox(width: 16),
            Flexible(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: const [
                  Text(
                    "SOS EMERGENCY",
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w900,
                      fontSize: 18,
                      letterSpacing: 1.2,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                  Text(
                    "Tap to call for help immediately",
                    style: TextStyle(
                      color: Colors.white70,
                      fontSize: 12,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildUpdatesCarousel() {
    return SizedBox(
      height: 100,
      child: StreamBuilder<List<Map<String, dynamic>>>(
        stream: FirestoreService().getCommunityUpdates(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          
          if (!snapshot.hasData || snapshot.data!.isEmpty) {

            // Show a default welcome card if no updates
            return Container(
              margin: const EdgeInsets.only(right: 16),
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Theme.of(context).cardColor,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: Theme.of(context).dividerColor),
              ),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: AppColors.safetyBlue.withOpacity(0.1),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(Icons.info_outline, color: AppColors.safetyBlue),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          'Welcome to Safetify',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Theme.of(context).textTheme.bodyLarge?.color,
                          ),
                        ),
                        Text(
                          'Stay safe and informed.',
                          style: TextStyle(
                            fontSize: 12,
                            color: Theme.of(context).textTheme.bodyMedium?.color,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            );
          }

          final updates = snapshot.data!;
          return PageView.builder(
            itemCount: updates.length,
            controller: PageController(viewportFraction: 0.9),
            itemBuilder: (context, index) {
              final u = updates[index];
              final category = u['category'] ?? 'Info';
              final color = _getCategoryColor(category);
              final icon = _getCategoryIcon(category);

              return Container(
                margin: const EdgeInsets.only(right: 10),
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Theme.of(context).cardColor,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: Theme.of(context).dividerColor),
                ),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: color.withOpacity(0.1),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(icon, color: color),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            u['title'] ?? 'Update',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: Theme.of(context).textTheme.bodyLarge?.color,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          Text(
                            u['description'] ?? '',
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              fontSize: 12,
                              color: Theme.of(context).textTheme.bodyMedium?.color,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              );
            },
          );
        },
      ),
    );
  }

  Color _getCategoryColor(String category) {
    switch (category.toLowerCase()) {
      case 'safety': return AppColors.safetyBlue;
      case 'event': return AppColors.successGreen;
      case 'alert': return AppColors.alertRed;
      case 'maintenance': return Colors.orange;
      default: return Colors.blue;
    }
  }

  IconData _getCategoryIcon(String category) {
    switch (category.toLowerCase()) {
      case 'safety': return Icons.shield;
      case 'event': return Icons.event;
      case 'alert': return Icons.warning_amber_rounded;
      case 'maintenance': return Icons.construction;
      default: return Icons.info;
    }
  }

  Widget _buildRecentIncidents() {
    return StreamBuilder<List<Incident>>(
      stream: FirestoreService().getAllIncidents(limit: 100),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return const Padding(
            padding: EdgeInsets.all(16.0),
            child: Text("No recent incidents reported."),
          );
        }

        final incidents = snapshot.data!;
        incidents.sort((a, b) => b.createdAt.compareTo(a.createdAt));
        
        // Top 3 incidents
        final recentIncidents = incidents.take(3).toList();

        return ListView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: recentIncidents.length,
          itemBuilder: (context, index) {
            final inc = recentIncidents[index];
            return FutureBuilder<model.User>(
              future: FirestoreService().getUser(inc.userId),
              builder: (context, userSnapshot) {
                String reporterName = userSnapshot.data?.name ?? "Unknown";
                return Padding(
                  padding: const EdgeInsets.only(bottom: 10),
                  child: IncidentCard(
                    title: '${inc.category} at ${inc.locationName}',
                    subtitle: '${timeago.format(inc.createdAt)} • Reported by ${reporterName}',
                    networkImage: inc.photoUrl.isNotEmpty ? inc.photoUrl : null,
                    badge: inc.resolved ? "Resolved" : (inc.verified ? "Verified" : "Unverified"),
                    badgeColor: inc.resolved ? AppColors.safetyBlue : (inc.verified ? AppColors.successGreen : AppColors.alertRed),
                    onTap: () => Navigator.pushNamed(
                      context,
                      '/details',
                      arguments: inc,
                    ),
                  ),
                );
              },
            );
          },
        );
      },
    );
  }
}
