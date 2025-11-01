import 'package:flutter/material.dart';
import '../constants.dart';
import 'package:safetify/widgets/incident_card.dart';

class IncidentsHistoryPage extends StatelessWidget {
  const IncidentsHistoryPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bg,
      appBar: AppBar(
        title: const Text('Incident History'),
        elevation: 0,
        backgroundColor: AppColors.bg,
        foregroundColor: AppColors.darkCharcoal,
      ),
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 16, vertical: 10),
          child: Column(children: [
            SizedBox(height: 10,),
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
          ],
          )
        )
      )
    );
  }
}
