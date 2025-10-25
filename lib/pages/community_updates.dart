import 'package:flutter/material.dart';
import '../constants.dart';

class CommunityUpdatesPage extends StatelessWidget {
  const CommunityUpdatesPage({super.key});

  @override
  Widget build(BuildContext context) {
    final List<Map<String, dynamic>> updates = [
      {
        'title': 'Safety Awareness Workshop',
        'time': 'Oct 18, 2025 2:00 PM',
        'description':
            'Join our community awareness session on fire prevention and emergency response at Kano City Hall.',
        'icon': Icons.group_rounded,
      },
      {
        'title': 'Water Contamination Alert',
        'time': 'Oct 16, 2025 11:20 AM',
        'description':
            'Avoid drinking from public taps near Kofar Ruwa until further notice. Health officials are testing the supply.',
        'icon': Icons.water_drop_rounded,
      },
      {
        'title': 'Road Maintenance Notice',
        'time': 'Oct 15, 2025 8:45 AM',
        'description':
            'Roadworks ongoing along Airport Road. Expect diversions and traffic delays until October 25.',
        'icon': Icons.construction_rounded,
      },
    ];

    return Scaffold(
      backgroundColor: AppColors.bg,
      appBar: AppBar(
        title: const Text('Community Updates'),
        backgroundColor: AppColors.bg,
        foregroundColor: AppColors.darkCharcoal,
        elevation: 0,
      ),
      body: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: updates.length,
        itemBuilder: (context, index) {
          final u = updates[index];
          return Container(
            margin: const EdgeInsets.only(bottom: 16),
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 5,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: AppColors.safetyBlue.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(u['icon'], color: AppColors.safetyBlue, size: 26),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        u['title'],
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                          color: AppColors.darkCharcoal,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        u['description'],
                        style: const TextStyle(color: Colors.black87, fontSize: 14, height: 1.4),
                      ),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          const Icon(Icons.access_time, size: 14, color: Colors.grey),
                          const SizedBox(width: 4),
                          Text(u['time'], style: const TextStyle(color: Colors.grey, fontSize: 12)),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
