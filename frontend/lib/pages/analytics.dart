import 'package:flutter/material.dart';
import '../constants.dart';
import '../widgets/incident_card.dart';

class AnalyticsPage extends StatelessWidget {
  const AnalyticsPage({super.key});
  // Dummy stats for UI demonstration. Replace with API data.
  final int incidents = 5;
  final int alerts = 18;
  final int reports = 20;

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
            // Simple bar chart representation using Row and Containers
            Container(
              height: 200,
              padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
              color: AppColors.card,
              borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _barChartBar('Incidents', incidents, Colors.orange),
                _barChartBar('Alerts', alerts, Colors.red),
                _barChartBar('Reports', reports, Colors.blue),
              ],
              ),
            ),
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

  Widget _barChartBar(String label, int value, Color color) {
    // determine the maximum value among the stats to scale bars proportionally
    final int maxVal = [incidents, alerts, reports].reduce((a, b) => a > b ? a : b);
    final double heightFactor = maxVal > 0 ? value / maxVal : 0.0;
    final double barHeight = heightFactor * 80 + 8; // base minimum height

    return Column(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        Container(
          width: 20,
          height: barHeight,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(6),
          ),
        ),
        SizedBox(height: 6),
        SizedBox(
          width: 48,
          child: Text(
            label,
            style: TextStyle(fontSize: 12),
            textAlign: TextAlign.center,
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }
}
