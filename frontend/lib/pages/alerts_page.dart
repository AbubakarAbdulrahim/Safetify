import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../widgets/alert_card.dart';
import '../constants.dart';

class AlertsPage extends StatelessWidget {
  const AlertsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final alertsRef = FirebaseFirestore.instance.collection('alerts').orderBy('sentAt', descending: true);

    return Scaffold(
      backgroundColor: AppColors.bg,
      appBar: AppBar(
        title: const Text('Safety Alerts'),
        backgroundColor: AppColors.bg,
        elevation: 0,
        foregroundColor: AppColors.darkCharcoal,
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: alertsRef.snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return const Center(
              child: Text('No active alerts at the moment'),
            );
          }

          final alerts = snapshot.data!.docs;

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: alerts.length,
            itemBuilder: (context, index) {
              final alert = alerts[index].data() as Map<String, dynamic>;
              return AlertCard(alert: alert);
            },
          );
        },
      ),
    );
  }
}
