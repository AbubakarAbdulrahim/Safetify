import 'package:flutter/material.dart';
import '../constants.dart';
import 'package:url_launcher/url_launcher.dart';


class EmergencyContactsPage extends StatelessWidget {
  const EmergencyContactsPage({super.key});

  final List<Map<String, dynamic>> contacts = const [
    {
      'name': 'Police Emergency',
      'phone': '112',
      'icon': Icons.local_police_rounded,
      'color': AppColors.darkCharcoal
    },
    {
      'name': 'Fire Service',
      'phone': '119',
      'icon': Icons.local_fire_department_rounded,
      'color': AppColors.alertRed
    },
    {
      'name': 'Ambulance Service',
      'phone': '122',
      'icon': Icons.local_hospital_rounded,
      'color': AppColors.successGreen
    },
    {
      'name': 'Road Safety (FRSC)',
      'phone': '122',
      'icon': Icons.traffic_rounded,
      'color': Colors.orange
    },
    {
      'name': 'NEMA (Disaster Response)',
      'phone': '08003330600',
      'icon': Icons.warning_amber_rounded,
      'color': AppColors.safetyBlue
    },
    {
      'name': 'REMASAB',
      'phone': '08003330600',
      'icon': Icons.delete_rounded,
      'color': Color.fromARGB(255, 223, 167, 0)
    },
  ];

  Future<void> _makeCall(String number) async {
    final Uri uri = Uri(scheme: 'tel', path: number);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bg,
      appBar: AppBar(
        title: const Text('Emergency Contacts'),
        backgroundColor: AppColors.bg,
        foregroundColor: AppColors.darkCharcoal,
        elevation: 0,
      ),
      body: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: contacts.length,
        itemBuilder: (context, index) {
          final c = contacts[index];
          return Card(
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
            margin: const EdgeInsets.only(bottom: 14),
            child: ListTile(
              leading: CircleAvatar(
                radius: 24,
                backgroundColor: c['color'].withOpacity(0.2),
                child: Icon(c['icon'], color: c['color']),
              ),
              title: Text(
                c['name'],
                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
              ),
              subtitle: Text('Call: ${c['phone']}'),
              trailing: IconButton(
                icon: const Icon(Icons.call_rounded, color: AppColors.safetyBlue),
                onPressed: () => _makeCall(c['phone']),
              ),
            ),
          );
        },
      ),
    );
  }
}
