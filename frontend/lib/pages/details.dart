// // import 'package:flutter/material.dart';
// // import 'package:share_plus/share_plus.dart'; // <--- Add this for implicit sharing
// // import '../constants.dart';

// // class DetailsPage extends StatefulWidget {
// //   const DetailsPage({super.key});

// //   @override
// //   State<DetailsPage> createState() => _DetailsPageState();
// // }

// // class _DetailsPageState extends State<DetailsPage> {
// //   late Map<String, dynamic> incident;
// //   bool isResolved = false;

// //   @override
// //   void didChangeDependencies() {
// //     super.didChangeDependencies();
// //     // Get passed data or default
// //     incident = ModalRoute.of(context)!.settings.arguments as Map<String, dynamic>? ?? {
// //       'title': 'Fire outbreak near Sabon Gari',
// //       'status': 'Unverified',
// //       'image': 'assets/images/fire.jpg',
// //       'description':
// //           'A fire broke out near Sabon Gari market. Firefighters are on their way to the scene. Avoid the area to ensure safety.',
// //       'location': '11.0025, 11.0025',
// //       'time': '2025-10-18 09:35 AM'
// //     };
// //     isResolved = incident['status'] == 'Verified';
// //   }

// //   // Mark incident as done (resolved)
// //   void markAsResolved() {
// //     setState(() {
// //       isResolved = true;
// //       incident['status'] = 'Verified';
// //     });

// //     ScaffoldMessenger.of(context).showSnackBar(
// //       const SnackBar(
// //         content: Text('Incident marked as resolved successfully'),
// //         backgroundColor: AppColors.successGreen,
// //       ),
// //     );
// //   }

// //   // Share incident details via any installed app (implicit intent)
// //   void shareIncident() {
// //     final String message = '''
// // 🚨 ${incident['title']}
// // 📍 Location: ${incident['location']}
// // 🕒 Time: ${incident['time']}
// // 📋 Description: ${incident['description']}
// // Stay safe and report updates on Safetify!
// // ''';

// //     Share.share(message, subject: 'Incident Alert: ${incident['title']}');
// //   }

// //   @override
// //   Widget build(BuildContext context) {
// //     return Scaffold(
// //       backgroundColor: AppColors.bg,
// //       appBar: AppBar(
// //         title: const Text('Incident Details'),
// //         elevation: 0,
// //         backgroundColor: AppColors.bg,
// //         foregroundColor: AppColors.darkCharcoal,
// //       ),
// //       body: SafeArea(
// //         child: SingleChildScrollView(
// //           padding: const EdgeInsets.all(20),
// //           child: Column(
// //             crossAxisAlignment: CrossAxisAlignment.start,
// //             children: [
// //               ClipRRect(
// //                 borderRadius: BorderRadius.circular(16),
// //                 child: Image.asset(
// //                   incident['image']!,
// //                   height: 220,
// //                   width: double.infinity,
// //                   fit: BoxFit.cover,
// //                 ),
// //               ),
// //               const SizedBox(height: 16),

// //               // Title + status
// //               Row(
// //                 mainAxisAlignment: MainAxisAlignment.spaceBetween,
// //                 children: [
// //                   Expanded(
// //                     child: Text(
// //                       incident['title']!,
// //                       style: const TextStyle(
// //                         fontSize: 18,
// //                         fontWeight: FontWeight.bold,
// //                         color: AppColors.darkCharcoal,
// //                       ),
// //                     ),
// //                   ),
// //                   Container(
// //                     padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
// //                     decoration: BoxDecoration(
// //                       color: isResolved
// //                           ? AppColors.successGreen.withOpacity(0.2)
// //                           : AppColors.alertRed.withOpacity(0.2),
// //                       borderRadius: BorderRadius.circular(8),
// //                     ),
// //                     child: Text(
// //                       isResolved ? 'Verified' : 'Unverified',
// //                       style: TextStyle(
// //                         color: isResolved
// //                             ? AppColors.successGreen
// //                             : AppColors.alertRed,
// //                         fontWeight: FontWeight.bold,
// //                         fontSize: 12,
// //                       ),
// //                     ),
// //                   ),
// //                 ],
// //               ),
// //               const SizedBox(height: 10),

// //               // Time & Location
// //               Row(
// //                 children: [
// //                   const Icon(Icons.access_time, size: 18, color: Colors.grey),
// //                   const SizedBox(width: 6),
// //                   Text(incident['time']!, style: const TextStyle(color: Colors.grey, fontSize: 13)),
// //                 ],
// //               ),
// //               const SizedBox(height: 8),
// //               Row(
// //                 children: [
// //                   const Icon(Icons.location_on_outlined, size: 18, color: Colors.grey),
// //                   const SizedBox(width: 6),
// //                   Text(incident['location']!, style: const TextStyle(color: Colors.grey, fontSize: 13)),
// //                 ],
// //               ),
// //               const SizedBox(height: 20),

// //               // Description
// //               const Text(
// //                 'Description',
// //                 style: TextStyle(
// //                   fontWeight: FontWeight.bold,
// //                   fontSize: 16,
// //                   color: AppColors.darkCharcoal,
// //                 ),
// //               ),
// //               const SizedBox(height: 8),
// //               Text(
// //                 incident['description']!,
// //                 style: const TextStyle(fontSize: 14, height: 1.5, color: Colors.black87),
// //               ),
// //               const SizedBox(height: 30),

// //               // Buttons
// //               Row(
// //                 mainAxisAlignment: MainAxisAlignment.spaceEvenly,
// //                 children: [
// //                   Expanded(
// //                     child: ElevatedButton.icon(
// //                       style: ElevatedButton.styleFrom(
// //                         backgroundColor: isResolved ? Colors.grey : AppColors.safetyBlue,
// //                         shape: RoundedRectangleBorder(
// //                           borderRadius: BorderRadius.circular(12),
// //                         ),
// //                         padding: const EdgeInsets.symmetric(vertical: 18),
// //                       ),
// //                       onPressed: isResolved ? null : markAsResolved,
// //                       icon: const Icon(Icons.check_circle_outline, color: Colors.white),
// //                       label: Text(
// //                         isResolved ? 'Resolved' : 'Mark as Resolved',
// //                         style: const TextStyle(color: Colors.white),
// //                       ),
// //                     ),
// //                   ),
// //                   const SizedBox(width: 12),
// //                   Expanded(
// //                     child: OutlinedButton.icon(
// //                       style: OutlinedButton.styleFrom(
// //                         side: const BorderSide(color: AppColors.safetyBlue),
// //                         shape: RoundedRectangleBorder(
// //                           borderRadius: BorderRadius.circular(12),
// //                         ),
// //                         padding: const EdgeInsets.symmetric(vertical: 18),
// //                       ),
// //                       onPressed: shareIncident,
// //                       icon: const Icon(Icons.share_outlined, color: AppColors.safetyBlue),
// //                       label: const Text(
// //                         'Share',
// //                         style: TextStyle(color: AppColors.safetyBlue),
// //                       ),
// //                     ),
// //                   ),
// //                 ],
// //               ),
// //             ],
// //           ),
// //         ),
// //       ),
// //     );
// //   }
// // }

// import 'package:flutter/material.dart';
// import 'package:safetify/models/incidents.dart';
// import 'package:share_plus/share_plus.dart';
// import '../constants.dart';

// class DetailsPage extends StatelessWidget {
//   const DetailsPage({super.key});
  


//   @override
//   Widget build(BuildContext context) {
//     final Incident incident = ModalRoute.of(context)!.settings.arguments as Incident;


//     // Share incident details via any installed app (implicit intent)
//     void shareIncident() {
//       final String message = '''
//       ${incident.category} at ${incident.locationName}
//       Location: ${incident.locationName}
//       Time: ${incident.createdAt}
//       Description: ${incident.description}
//       Stay safe and report updates on Safetify!
//       ''';

//     Share.share(message, subject: 'Incident Alert: ${incident.category} at ${incident.locationName}');
//   }

//     return Scaffold(
//       appBar: AppBar(title: Text('incident Details'), leading: BackButton()),
//       body: SingleChildScrollView(
//         padding: EdgeInsets.all(16),
//         child: Column(
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             if (incident.photoUrl.isNotEmpty)
//               ClipRRect(
//                 borderRadius: BorderRadius.circular(12),
//                 child: Image.network(incident.photoUrl),
//               ),
//             Text(
//               '${incident.category} at ${incident.locationName}',
//               style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
//             ),
//             SizedBox(height: 16),
//             Text(incident.description, style: TextStyle(fontSize: 16)),
//             SizedBox(height: 8),
//             Text("Reported: ${incident.createdAt}",
//                 style: TextStyle(color: Colors.grey)),
//             SizedBox(height: 8),
//             Text("Location: ${incident.locationName}",
//                 style: TextStyle(color: Colors.grey)),
//             SizedBox(height: 8),
//             Text(
//               incident.verified ? "Verified" : "Unverified",
//               style: TextStyle(
//                 color: incident.verified ? AppColors.successGreen : AppColors.alertRed,
//                 fontWeight: FontWeight.bold,
//               ),
//             ),
//             SizedBox(height: 24),
//             ElevatedButton.icon(
//               onPressed: shareIncident,
//               icon: Icon(Icons.share),
//               label: Text('Share Incident'),
//               style: ElevatedButton.styleFrom(
//                 backgroundColor: AppColors.safetyBlue,
//                 padding: EdgeInsets.symmetric(vertical: 16),
//                 shape: RoundedRectangleBorder(
//                   borderRadius: BorderRadius.circular(12),
//                 ),
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }

import 'package:flutter/material.dart';
import 'package:safetify/models/incidents.dart';
import 'package:share_plus/share_plus.dart';
import 'package:timeago/timeago.dart' as timeago;
import '../constants.dart';

class DetailsPage extends StatelessWidget {
  const DetailsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final Incident incident = ModalRoute.of(context)!.settings.arguments as Incident;

    void shareIncident() {
      final String message = '''
Photo: ${incident.photoUrl}
${incident.category} at ${incident.locationName}
Time: ${timeago.format(incident.createdAt)},
Description: ${incident.description}

Stay safe and report updates on Safetify!
''';

      Share.share(message,
          subject: 'Incident Alert: ${incident.category} · ${incident.locationName}');
    }


    return Scaffold(
      backgroundColor: AppColors.bg,
      appBar: AppBar(
        title: const Text('Incident Details'),
        elevation: 0,
        backgroundColor: AppColors.bg,
        foregroundColor: AppColors.darkCharcoal,
      ),

      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [

              /// INCIDENT IMAGE
              ClipRRect(
                borderRadius: BorderRadius.circular(16),
                child: incident.photoUrl.isNotEmpty
                    ? Image.network(
                        incident.photoUrl,
                        height: 220,
                        width: double.infinity,
                        fit: BoxFit.cover,
                      )
                    : Image.asset(
                        'assets/images/placeholder.jpg',
                        height: 220,
                        width: double.infinity,
                        fit: BoxFit.cover,
                      ),
              ),

              const SizedBox(height: 16),

              /// TITLE + STATUS BADGE
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Text(
                      '${incident.category} at ${incident.locationName}',
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: AppColors.darkCharcoal,
                      ),
                    ),
                  ),

                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 10, vertical: 6),
                    decoration: BoxDecoration(
                      color: incident.verified
                          ? AppColors.successGreen.withOpacity(0.2)
                          : AppColors.alertRed.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      incident.verified ? 'Verified' : 'Unverified',
                      style: TextStyle(
                        color: incident.verified
                            ? AppColors.successGreen
                            : AppColors.alertRed,
                        fontWeight: FontWeight.bold,
                        fontSize: 12,
                      ),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 10),

              /// TIME
              Row(
                children: [
                  const Icon(Icons.access_time,
                      size: 18, color: Colors.grey),
                  const SizedBox(width: 6),
                  Text(
                    timeago.format(incident.createdAt),
                    style: const TextStyle(color: Colors.grey, fontSize: 13),
                  ),
                ],
              ),


              const SizedBox(height: 8),

              /// LOCATION
              Row(
                children: [
                  const Icon(Icons.location_on_outlined,
                      size: 18, color: Colors.grey),
                  const SizedBox(width: 6),
                  Text(
                    incident.locationName,
                    style: const TextStyle(color: Colors.grey, fontSize: 13),
                  ),
                ],
              ),
              
              // //reported by
              // FutureBuilder<model.User>(
              //         // Make sure your Incident model has a 'userId' field
              //         future: FirestoreService().getUser(incident.userId), 
              //         builder: (context, userSnapshot) {
                        
              //           // Determine the name to show
              //           String reporterName = "..."; // Default while loading
                        
              //           if (userSnapshot.hasData) {
              //             reporterName = userSnapshot.data!.name ?? "Unknown";
              //           }
              //           Row(
              //   children: [
              //     const Icon(Icons.person_outline,
              //         size: 18, color: Colors.grey),
              //     const SizedBox(width: 6),
              //     Text('Reported by: $reporterName',
              //       style: const TextStyle(color: Colors.grey, fontSize: 13),
              //     ),
              //   ],
              // );
              //           return const SizedBox(height: 8);
              //         }
              // ),

              const SizedBox(height: 20),

              /// DESCRIPTION HEADER
              const Text(
                'Description',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                  color: AppColors.darkCharcoal,
                ),
              ),

              const SizedBox(height: 8),

              /// DESCRIPTION CONTENT
              Text(
                incident.description,
                style: const TextStyle(
                  fontSize: 14,
                  height: 1.5,
                  color: Colors.black87,
                ),
              ),

              
              const SizedBox(height: 30),

              /// map BUTTON
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                    side: const BorderSide(color: AppColors.safetyBlue),
                    padding: const EdgeInsets.symmetric(vertical: 18),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  onPressed: () {
                    Navigator.pushNamed(context, '/map');
                  },
                  icon: const Icon(Icons.location_on_sharp,
                      color: Colors.white),
                  label: const Text(
                    "View On Map",
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 15,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 12),
              // SHARE BUTTON
              SizedBox(
                width: double.infinity,
                child: OutlinedButton.icon(
                  style: OutlinedButton.styleFrom(
                    side: const BorderSide(color: AppColors.safetyBlue),
                    padding: const EdgeInsets.symmetric(vertical: 18),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  onPressed: shareIncident,
                  icon: const Icon(Icons.share_outlined,
                      color: AppColors.safetyBlue),
                  label: const Text(
                    "Share",
                    style: TextStyle(
                      color: AppColors.safetyBlue,
                      fontSize: 15,
                    ),
                  ),
                ),
              ),
              SizedBox(height: 12),
            ],
          ),
        ),
      ),
    );
  }
}
