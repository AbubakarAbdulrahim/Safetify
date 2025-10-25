import 'package:flutter/material.dart';
import '../constants.dart';
//import '../widgets/incident_card.dart';

class AnalyticsPage extends StatelessWidget {
  const AnalyticsPage({super.key});
  // Dummy stats for UI demonstration. Replace with API data.
  final int incidents = 5;
  final int alerts = 18;
  final int reports = 23;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Analytics Dashboard'), leading: BackButton()),
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.all(16),
          child: Column(children: [
            Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
              _statTile('Incidents', incidents.toString()),
              _statTile('Alerts', alerts.toString()),
              _statTile('Reports', reports.toString()),
            ]),
            SizedBox(height: 18),
            Align(alignment: Alignment.centerLeft, child: Text('Incidents', style: TextStyle(fontWeight: FontWeight.w700))),
            SizedBox(height: 8),
            // Simple line-like representation using Container (replace with charts lib)
            Container(
              height: 120,
              decoration: BoxDecoration(color: AppColors.card, borderRadius: BorderRadius.circular(12)),
              child: Center(child: Image.asset('images/analytics.png')),
            ),
            // SizedBox(height: 12),
            // Align(alignment: Alignment.centerLeft, child: Text('Recent Reports', style: TextStyle(fontWeight: FontWeight.w700))),
            // SizedBox(height: 10),
            // IncidentCard(title: 'Fire: Sabon Gari', subtitle: '2 hrs ago', imageAsset: 'assets/images/fire.jpg', badge: 'Unverified', badgeColor: AppColors.alertRed),
            // SizedBox(height: 8),
            // IncidentCard(title: 'Flood: Rijiyar Zaki', subtitle: 'Yesterday', imageAsset: 'assets/images/flood.jpg', badge: 'Verified', badgeColor: AppColors.successGreen),
          ]),
        ),
      ),
    );
  }

  Widget _statTile(String label, String value) {
    return Expanded(
      child: Column(children: [
        Text(value, style: TextStyle(fontSize: 22, fontWeight: FontWeight.w800)),
        SizedBox(height: 6),
        Text(label, style: TextStyle(color: Colors.grey[700])),
      ]),
    );
  }
}
