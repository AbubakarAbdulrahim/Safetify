// // import 'package:flutter/material.dart';
// // import 'package:cloud_firestore/cloud_firestore.dart';
// // import '../widgets/alert_card.dart';
// // import '../constants.dart';

// // class NotificationPage extends StatelessWidget {
// //   const NotificationPage({super.key});
  

// //   @override
// //   Widget build(BuildContext context) {
// //     final alertsRef = FirebaseFirestore.instance.collection('alerts').orderBy('sentAt', descending: true);

// //     return Scaffold(
// //       backgroundColor: AppColors.bg,
// //       appBar: AppBar(
// //         title: const Text('Safety Alerts'),
// //         backgroundColor: AppColors.bg,
// //         elevation: 0,
// //         foregroundColor: AppColors.darkCharcoal,
// //       ),
// //       body: StreamBuilder<QuerySnapshot>(
// //         stream: alertsRef.snapshots(),
// //         builder: (context, snapshot) {
// //           if (snapshot.connectionState == ConnectionState.waiting) {
// //             return const Center(child: CircularProgressIndicator());
// //           }
// //           if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
// //             return const Center(
// //               child: Text('No active alerts at the moment'),
// //             );
// //           }

// //           final alerts = snapshot.data!.docs;

// //           return ListView.builder(
// //             padding: const EdgeInsets.all(16),
// //             itemCount: alerts.length,
// //             itemBuilder: (context, index) {
// //               final alert = alerts[index].data() as Map<String, dynamic>;
// //               return AlertCard(alert: alert);
// //             },
// //           );
// //         },
// //       ),
// //     );
// //   }
// // }

// import 'package:flutter/material.dart';
// import 'package:safetify/models/incidents.dart';
// import '../services/firestore_service.dart';
// import '../constants.dart';

// class NotificationPage extends StatelessWidget {
//   final FirestoreService _firestore = FirestoreService();

//   NotificationPage({super.key});

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: const Text("Safety Alerts"),
//         backgroundColor: AppColors.bg,
//       ),
//       body: StreamBuilder<List<Incident>>(
//         stream: _firestore.getAllIncidents(limit: 50),
//         builder: (context, snapshot) {
//           if (!snapshot.hasData) {
//             return const Center(child: CircularProgressIndicator());
//           }

//           final incidents = snapshot.data!;

//           if (incidents.isEmpty) {
//             return const Center(child: Text("'No active alerts at the moment'"));
//           }

//           return ListView.builder(
//             itemCount: incidents.length,
//             itemBuilder: (context, i) {
//               final incident = incidents[i];

//               final category = incident.category;
//               final location = incident.locationName;
//               final timestamp = incident.createdAt;
//               final verified = incident.verified;

//               return Card(
//                 margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
//                 child: ListTile(
//                   leading: Icon(
//                     Icons.warning,
//                     color: verified ? Colors.green : Colors.red,
//                     size: 32,
//                   ),
//                   title: Text(
//                     "$category at $location",
//                     style: const TextStyle(fontSize: 16,fontWeight: FontWeight.bold),
//                   ),
//                   subtitle: Text(
//                     "${timestamp.day}/${timestamp.month}/${timestamp.year}  ${timestamp.hour}:${timestamp.minute}",
//                   ),
//                   trailing: verified
//                       ? const Text("Verified", style: TextStyle(color: Colors.green,fontWeight: FontWeight.bold))
//                       : const Text("Unverified", style: TextStyle(color: Colors.red,fontWeight: FontWeight.bold)),
//                 ),
//               );
//             },
//           );
//         },
//       ),
//     );
//   }
// }

import 'package:flutter/material.dart';
import 'package:safetify/models/incidents.dart';
import 'package:timeago/timeago.dart' as timeago; // Ensure this is imported
import '../services/firestore_service.dart';
import '../constants.dart';

class NotificationPage extends StatelessWidget {
  final FirestoreService _firestore = FirestoreService();

  NotificationPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bg,
      appBar: AppBar(
        title: const Text("Notifications"),
        backgroundColor: AppColors.bg,
        elevation: 0,
        foregroundColor: AppColors.darkCharcoal,
      ),
      body: StreamBuilder<List<Incident>>(
        // optimization: You might want to limit this to recent items only
        stream: _firestore.getAllIncidents(limit: 10), 
        builder: (context, snapshot) {
          
          // 1. Loading State
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          // 2. Empty State
          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.notifications_off_outlined, size: 60, color: Colors.grey[400]),
                  const SizedBox(height: 10),
                  Text(
                    "No active alerts",
                    style: TextStyle(color: Colors.grey[600], fontSize: 16),
                  ),
                ],
              ),
            );
          }

          final incidents = snapshot.data!;

          return ListView.builder(
            padding: const EdgeInsets.all(12),
            itemCount: incidents.length,
            itemBuilder: (context, i) {
              final incident = incidents[i];

              return Card(
                elevation: 2,
                margin: const EdgeInsets.only(bottom: 12),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                child: ListTile(
                  contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  
                  // Icon based on verification status
                  leading: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: incident.verified 
                          ? AppColors.successGreen.withOpacity(0.1) 
                          : AppColors.alertRed.withOpacity(0.1),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      incident.verified ? Icons.verified_user : Icons.warning_amber_rounded,
                      color: incident.verified ? AppColors.successGreen : AppColors.alertRed,
                      size: 24,
                    ),
                  ),

                  title: Text(
                    "${incident.category} at ${incident.locationName}",
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),

                  // Professional Time Format
                  subtitle: Padding(
                    padding: const EdgeInsets.only(top: 4),
                    child: Text(
                      timeago.format(incident.createdAt),
                      style: TextStyle(fontSize: 13, color: Colors.grey[600]),
                    ),
                  ),

                  trailing: const Icon(Icons.arrow_forward_ios, size: 14, color: Colors.grey),

                  // Navigate to Details Page
                  onTap: () {
                    Navigator.pushNamed(
                      context, 
                      '/details',
                      arguments: incident, // Pass the incident object
                    );
                  },
                ),
              );
            },
          );
        },
      ),
    );
  }
}