import 'package:flutter/material.dart';
import '../constants.dart';

class AlertCard extends StatelessWidget {
  final Map<String, dynamic> alert;
  const AlertCard({super.key, required this.alert});

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 1,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      margin: const EdgeInsets.only(bottom: 16),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              alert['title'] ?? 'Safety Alert',
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 16,
                color: AppColors.darkCharcoal,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              alert['message'] ?? '',
              style: const TextStyle(fontSize: 14, color: Colors.black87, height: 1.4),
            ),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  (alert['sentAt'] != null)
                      ? DateTime.fromMillisecondsSinceEpoch(alert['sentAt'].millisecondsSinceEpoch)
                          .toLocal()
                          .toString()
                          .split('.')[0]
                      : 'Time unknown',
                  style: const TextStyle(color: Colors.grey, fontSize: 12),
                ),
                TextButton(
                  onPressed: () {
                    Navigator.pushNamed(context, '/details', arguments: {
                      'title': alert['title'],
                      'description': alert['message'],
                      'incidentId': alert['incidentId'],
                      'status': 'Active'
                    });
                  },
                  child: const Text(
                    'View Details',
                    style: TextStyle(color: AppColors.safetyBlue, fontWeight: FontWeight.w600),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
