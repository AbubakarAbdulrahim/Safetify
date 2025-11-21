// import 'package:flutter/material.dart';
// import 'package:safetify/models/incidents.dart';
// import 'package:safetify/services/firestore_service.dart';
// import 'package:timeago/timeago.dart' as timeago;
// import '../constants.dart';
// import 'package:safetify/widgets/incident_card.dart';

// class IncidentsHistoryPage extends StatelessWidget {
//   const IncidentsHistoryPage({super.key});

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       backgroundColor: AppColors.bg,
//       appBar: AppBar(
//         title: const Text('Incident History'),
//         elevation: 0,
//         backgroundColor: AppColors.bg,
//         foregroundColor: AppColors.darkCharcoal,
//       ),
//       body: SafeArea(
//         child: Padding(
//           padding: EdgeInsets.symmetric(horizontal: 16, vertical: 10),
//           child: Column(children: [
//             SizedBox(height: 10),

//             StreamBuilder<List<Incident>>(
//             stream: FirestoreService().getAllIncidents(limit: 100),
//             builder: (context, snapshot) {
//               if (snapshot.connectionState == ConnectionState.waiting) {
//                 return const Center(child: CircularProgressIndicator());
//               }

//               if (!snapshot.hasData || snapshot.data!.isEmpty) {
//                 return const Text("No recent incidents reported.");
//               }

//               final incidents = snapshot.data!;

//               return ListView.builder(
//                 shrinkWrap: true,
//                 physics: const NeverScrollableScrollPhysics(),
//                 itemCount: incidents.length,
//                 itemBuilder: (context, index) {
//                   final inc = incidents[index];

//                   return Padding(
//                     padding: const EdgeInsets.only(bottom: 10),
//                     child: IncidentCard(
//                       title: '${inc.category} at ${inc.locationName}',
//                       subtitle: '${timeago.format(inc.createdAt)}',

//                       // ✅ Use the URL directly — no StorageService call!
//                       networkImage: inc.photoUrl.isNotEmpty ? inc.photoUrl : null,

//                       badge: inc.verified ? "Verified" : "Unverified",
//                       badgeColor: inc.verified
//                           ? AppColors.successGreen
//                           : AppColors.alertRed,

//                       onTap: () => Navigator.pushNamed(
//                         context,
//                         '/details',
//                         arguments: inc,
//                       ),
//                     ),
//                   );
//                 },
//               );
//             },
//           ),
//             SizedBox(height: 10,),
//           ],
//           )
//         )
//       )
//     );
//   }
// }

import 'package:flutter/material.dart';
import 'package:safetify/models/incidents.dart';
import 'package:safetify/models/users.dart' as model;
import 'package:safetify/services/firestore_service.dart';
import 'package:timeago/timeago.dart' as timeago;
import '../constants.dart';
import 'package:safetify/widgets/incident_card.dart';
// Import Auth

class IncidentsHistoryPage extends StatelessWidget {
  const IncidentsHistoryPage({super.key});

  @override
  Widget build(BuildContext context) {
    // Get current user ID to show ONLY their history

    return Scaffold(
      backgroundColor: AppColors.bg,
      appBar: AppBar(
        title: const Text('Reports History'),
        elevation: 0,
        backgroundColor: AppColors.bg,
        foregroundColor: AppColors.darkCharcoal,
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
          child: Column(
            children: [
              const SizedBox(height: 10),

              // 1. Use Expanded so the list takes up the remaining screen space
              Expanded(
                child: StreamBuilder<List<Incident>>(
                  // 2. CHANGE THIS: Use a specific query for user history (see below)
                  // If you don't have getUserIncidents yet, use getAllIncidents for now.
                  stream: FirestoreService().getAllIncidents(limit: 25), 
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const Center(child: CircularProgressIndicator());
                    }

                    if (!snapshot.hasData || snapshot.data!.isEmpty) {
                      return const Center(child: Text("No reported any incidents yet."));
                    }

                    final incidents = snapshot.data!;

                    return ListView.builder(
                      // 3. REMOVED shrinkWrap: true (Not needed inside Expanded)
                      // 4. REMOVED physics: NeverScrollable... (Let it scroll!)
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
          )],
        ),
      ),
    )
  );
  }
}
  