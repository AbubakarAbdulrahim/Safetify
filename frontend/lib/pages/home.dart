import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../constants.dart';
import '../widgets/bottom_nav.dart';
import '../widgets/incident_card.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _index = 0;

  void _onNavTap(int index) {
    if (index == 0) return; //home by default
    if (index == 1) Navigator.pushNamed(context, '/map');
    if (index == 2) Navigator.pushNamed(context, '/analytics');
    if (index == 3) Navigator.pushNamed(context, '/profile');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Row(children: [
          Icon(Icons.shield_rounded, color: AppColors.darkCharcoal),
          SizedBox(width: 5),
          Text('Safetify', style: GoogleFonts.poppins(fontWeight: FontWeight.w600)),
        ]),
        elevation: 0,
        automaticallyImplyLeading: false,
        actions: [
          IconButton(onPressed: () { Navigator.pushNamed(context, '/details');},
        icon: Stack(children: [
            Icon(Icons.notifications_rounded, color: AppColors.darkCharcoal),
            Positioned(right: 0, child: CircleAvatar(radius: 4, backgroundColor: AppColors.alertRed))
          ])
        )],
      ),
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 16, vertical: 10),
          child: Column(children: [
            SizedBox(height: 10,),
            Align(
              alignment: Alignment.centerLeft,
              child: Text('Hello, Nadiya', style: GoogleFonts.poppins(fontSize: 18, fontWeight: FontWeight.w600)),
            ),
            SizedBox(height: 20),
            // Grid of 4 quick cards
            GridView.count(
              crossAxisCount: 2,
              shrinkWrap: true,
              crossAxisSpacing: 12,
              mainAxisSpacing: 12,
              physics: NeverScrollableScrollPhysics(),
              childAspectRatio: 1.8,
              children: [
                _QuickCard(icon: Icons.note_add_rounded, label: 'Report\nIncident', onTap: () => Navigator.pushNamed(context, '/report')),
                _QuickCard(icon: Icons.place_rounded, label: 'View\nIncidents', onTap: () => Navigator.pushNamed(context, '/map')),
                _QuickCard(icon: Icons.call_rounded, label: 'Emergency\nContacts', onTap: () => Navigator.pushNamed(context, '/emergency_contacts')),
                _QuickCard(icon: Icons.campaign_rounded, label: 'Community\nUpdates', onTap: () => Navigator.pushNamed(context, '/community_updates')),
              ],
            ),
            SizedBox(height: 16),
            Align(alignment: Alignment.centerLeft, child: Text('Recent Reports', style: TextStyle(fontWeight: FontWeight.w700))),
            SizedBox(height: 10),
            // Example incident card
            IncidentCard(
              title: 'Fire outbreak near Sabon Gari',
              subtitle: '2 mins ago • 0.7 km',
              imageAsset: 'assets/images/fire.jpg',
              badge: 'Unverified',
              badgeColor: AppColors.alertRed,
              onTap: () => Navigator.pushNamed(context, '/details'),
            ),
            SizedBox(height: 10),
            IncidentCard(
              title: 'Phone Snatching near Zaria Road',
              subtitle: '30 mins ago • 1.55 km',
              imageAsset: 'assets/images/thugs.jpg',
              badge: 'Verified',
              badgeColor: AppColors.successGreen,
              onTap: () => Navigator.pushNamed(context, '/details'),
            ),
            SizedBox(height: 10),
            IncidentCard(
              title: 'Traffic Congestion at Kwari Market',
              subtitle: '1 hr ago • 0.47 km',
              imageAsset: 'assets/images/traffic.jpg',
              badge: 'Verified',
              badgeColor: AppColors.successGreen,
              onTap: () => Navigator.pushNamed(context, '/details'),
            ),
            SizedBox(height: 10,),
            Spacer(),
            // bottom nav is separate; keep space
          ]),
        ),
      ),
      bottomNavigationBar: BottomNav(currentIndex: _index, onTap: _onNavTap),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
    );
  }
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
