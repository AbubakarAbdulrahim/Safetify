import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:safetify/models/incidents.dart';
import 'package:safetify/models/users.dart' as model;
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

class _QuickCard extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback? onTap;
  const _QuickCard({required this.icon, required this.label, this.onTap});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        decoration: BoxDecoration(color: AppColors.card, borderRadius: BorderRadius.circular(12), boxShadow: [
          BoxShadow(color: Colors.black12, blurRadius: 8, offset: Offset(0, 4)),
        ]),
        padding: EdgeInsets.all(12),
        child: Row(children: [
          Container(padding: EdgeInsets.all(8), decoration: BoxDecoration(color: AppColors.subtle, borderRadius: BorderRadius.circular(10)), child: Icon(icon, color: AppColors.safetyBlue)),
          SizedBox(width: 12),
          Expanded(child: Text(label, style: TextStyle(fontWeight: FontWeight.w700))),
        ]),
      ),
    );
  }
}

class _HomePageState extends State<HomePage> {
  final int _index = 0;

  void _onNavTap(int index) {
    if (index == 0) return; // Home by default
    if (index == 1) Navigator.pushNamed(context, '/map');
    if (index == 2) Navigator.pushNamed(context, '/ai');
    if (index == 3) Navigator.pushNamed(context, '/profile');
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar( backgroundColor: AppColors.safetyBlue,
        title: Row(children: [
          // Icon(Icons.security_outlined, color: Colors.white),
          SizedBox(width: 5),
          Text('Safetify', style: GoogleFonts.poppins(fontWeight: FontWeight.w600, fontSize: 25, color: Colors.white),)
        ]),
        elevation: 0,
        automaticallyImplyLeading: false,
        actions: [
            IconButton(onPressed: () { Navigator.pushNamed(context, '/notifications');},
          icon: Stack(children: [
            Icon(Icons.notifications_rounded, color: Colors.white),
            StreamBuilder<bool>(
              stream: Stream<bool>.value(true),
              builder: (context, snapshot) {
                final hasNotifications = snapshot.data ?? false;
                return hasNotifications
                    ? Positioned(right: 0, child: CircleAvatar(radius: 4, backgroundColor: AppColors.alertRed))
                    : SizedBox.shrink();
              },
            )
          ])
          )],
      ),
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 16, vertical: 10),
          child: Column(children: [
            SizedBox(height: 15),
            FutureBuilder<model.User>(
              future: FirestoreService().getUser(FirebaseAuth.instance.currentUser!.uid),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Text('Loading...');
                }
                
                if (snapshot.hasError) {
                  return const Text('Error loading profile');
                }

                final user = snapshot.data;
                final name = user?.name ?? 'User';

                return Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    'Hi, $name 👋', 
                    style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
                  ),
                );
              },
            ),
            SizedBox(height: 20),

            // My 4 Grid cards
            GridView.count(
              crossAxisCount: 2,
              shrinkWrap: true,
              crossAxisSpacing: 12,
              mainAxisSpacing: 12,
              physics: NeverScrollableScrollPhysics(),
              childAspectRatio: 1.8,
              children: [
                _QuickCard(icon: Icons.assignment_add, label: 'Report\nIncident', onTap: () => Navigator.pushNamed(context, '/report')),
                _QuickCard(icon: Icons.leaderboard_rounded, label: 'Analytics\nDashboard', onTap: () => Navigator.pushNamed(context, '/analytics')),
                _QuickCard(icon: Icons.add_call, label: 'Emergency\nContacts', onTap: () => Navigator.pushNamed(context, '/emergency_contacts')),
                _QuickCard(icon: Icons.campaign_rounded, label: 'Community\nUpdates', onTap: () => Navigator.pushNamed(context, '/community_updates')),
              ],
            ),
            SizedBox(height: 25),
            Align(alignment: Alignment.centerLeft, child: Text('Recent Reports', style: TextStyle(fontWeight: FontWeight.w700))),
            SizedBox(height: 10),

            SizedBox(height: 10),

            // Incident List

            StreamBuilder<List<Incident>>(
              stream: FirestoreService().getAllIncidents(limit: 3),
              builder: (context, snapshot) {
                // 1. Handle Loading State
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }

                // 2. Handle Empty State
                if (!snapshot.hasData || snapshot.data!.isEmpty) {
                  return const Padding(
                    padding: EdgeInsets.all(16.0),
                    child: Text("No recent incidents reported."),
                  );
                }

                final incidents = snapshot.data!;

                return ListView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: incidents.length,
                  itemBuilder: (context, index) {
                    final inc = incidents[index];

                    return FutureBuilder<model.User>(
                      future: FirestoreService().getUser(inc.userId), 
                      builder: (context, userSnapshot) {
                        
                        // Determine the name to show
                        String reporterName = "...";
                        
                        if (userSnapshot.hasData) {
                          reporterName = userSnapshot.data!.name ?? "Unknown";
                        }

                        return Padding(
                          padding: const EdgeInsets.only(bottom: 10),
                          child: IncidentCard(
                            title: '${inc.category} at ${inc.locationName}',
                            subtitle: '${timeago.format(inc.createdAt)} • Reported by $reporterName',
                            networkImage: inc.photoUrl.isNotEmpty ? inc.photoUrl : null,

                            badge: inc.verified ? "Verified" : "Unverified",
                            badgeColor: inc.verified
                                ? AppColors.successGreen
                                : AppColors.alertRed,

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
            ),
            SizedBox(height: 10,),
            InkWell(
              onTap: () {
                Navigator.pushNamed(context, '/history');
              },
              child: Text('View More', textAlign: TextAlign.right, style: TextStyle(fontSize: 14),),
            ),
          ]),
        ),
      ),
      bottomNavigationBar: BottomNav(currentIndex: _index, onTap: _onNavTap),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
    );
  }
}

