// // import 'package:flutter/material.dart';
// // import '../constants.dart';

// // class IncidentCard extends StatelessWidget {
// //   final String title;
// //   final String subtitle;
// //   final String imageAsset;
// //   final String badge;
// //   final Color badgeColor;
// //   final VoidCallback? onTap;

// //   const IncidentCard({
// //     super.key,
// //     required this.title,
// //     required this.subtitle,
// //     this.imageAsset = 'assets/images/fire.jpg',
// //     this.badge = 'Unverified',
// //     this.badgeColor = AppColors.amber,
// //     this.onTap, required String photoUrl,
// //   });

// //   @override
// //   Widget build(BuildContext context) {
// //     return InkWell(
// //       onTap: onTap,
// //       borderRadius: BorderRadius.circular(14),
// //       child: Container(
// //         decoration: BoxDecoration(color: AppColors.card, borderRadius: BorderRadius.circular(14), boxShadow: [
// //           BoxShadow(color: Colors.black12, blurRadius: 8, offset: Offset(0, 3)),
// //         ]),
// //         padding: EdgeInsets.all(12),
// //         child: Row(
// //           children: [
// //             ClipRRect(
// //               borderRadius: BorderRadius.circular(10),
// //               child: Image.asset(imageAsset, width: 72, height: 72, fit: BoxFit.cover),
// //             ),
// //             SizedBox(width: 12),
// //             Expanded(
// //               child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
// //                 Row(children: [
// //                   Expanded(child: Text(title, style: TextStyle(fontWeight: FontWeight.w700))),
// //                   Container(
// //                     padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
// //                     decoration: BoxDecoration(color: badgeColor.withOpacity(0.12), borderRadius: BorderRadius.circular(8)),
// //                     child: Text(badge, style: TextStyle(color: badgeColor, fontSize: 12, fontWeight: FontWeight.w600)),
// //                   )
// //                 ]),
// //                 SizedBox(height: 6),
// //                 Text(subtitle, style: TextStyle(color: Colors.grey[700], fontSize: 13)),
// //               ]),
// //             )
// //           ],
// //         ),
// //       ),
// //     );
// //   }
// // }

// import 'package:flutter/material.dart';

// class IncidentCard extends StatelessWidget {
//   final String title;
//   final String subtitle;
//   final String? networkImage; // null = no network image
//   final String badge;
//   final Color badgeColor;
//   final VoidCallback onTap;

//   const IncidentCard({
//     super.key,
//     required this.title,
//     required this.subtitle,
//     required this.badge,
//     required this.badgeColor,
//     required this.onTap,
//     this.networkImage,
//   });

//   @override
//   Widget build(BuildContext context) {
//     return GestureDetector(
//       onTap: onTap,
//       child: Card(
//         elevation: 2,
//         shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
//         child: Column(
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             // -----------------------
//             // INCIDENT IMAGE SECTION
//             // -----------------------
//             ClipRRect(
//               borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
//               child: networkImage != null && networkImage!.isNotEmpty
//                   ? Image.network(
//                       networkImage!,
//                       height: 180,
//                       width: double.infinity,
//                       fit: BoxFit.cover,
//                       errorBuilder: (_, __, ___) => Image.asset(
//                         'assets/images/fire.jpg',
//                         height: 180,
//                         width: double.infinity,
//                         fit: BoxFit.cover,
//                       ),
//                     )
//                   : Image.asset(
//                       'assets/images/fire.jpg',
//                       height: 180,
//                       width: double.infinity,
//                       fit: BoxFit.cover,
//                     ),
//             ),

//             // -----------------------
//             // INCIDENT DETAILS
//             // -----------------------
//             Padding(
//               padding: const EdgeInsets.all(12),
//               child: Column(
//                 crossAxisAlignment: CrossAxisAlignment.start,
//                 children: [
//                   // TITLE
//                   Text(
//                     title,
//                     style: const TextStyle(
//                       fontSize: 16,
//                       fontWeight: FontWeight.bold,
//                     ),
//                   ),

//                   const SizedBox(height: 4),

//                   // SUBTITLE
//                   Text(
//                     subtitle,
//                     style: TextStyle(
//                       fontSize: 13,
//                       color: Colors.grey.shade700,
//                     ),
//                   ),

//                   const SizedBox(height: 10),

//                   // BADGE
//                   Container(
//                     padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
//                     decoration: BoxDecoration(
//                       color: badgeColor.withOpacity(0.12),
//                       borderRadius: BorderRadius.circular(20),
//                     ),
//                     child: Text(
//                       badge,
//                       style: TextStyle(
//                         color: badgeColor,
//                         fontWeight: FontWeight.w600,
//                         fontSize: 12,
//                       ),
//                     ),
//                   ),
//                 ],
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }

import 'package:flutter/material.dart';
import '../constants.dart';

class IncidentCard extends StatelessWidget {
  final String title;
  final String subtitle;
  final String? networkImage; // network URL or null
  final String badge;
  final Color badgeColor;
  final VoidCallback onTap;

  const IncidentCard({
    super.key,
    required this.title,
    required this.subtitle,
    required this.badge,
    required this.badgeColor,
    required this.onTap,
    this.networkImage,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(14),
      child: Container(
        decoration: BoxDecoration(
          color: AppColors.card,
          borderRadius: BorderRadius.circular(14),
          boxShadow: [
            BoxShadow(
              color: Colors.black12,
              blurRadius: 8,
              offset: Offset(0, 3),
            ),
          ],
        ),
        padding: EdgeInsets.all(12),
        child: Row(
          children: [
            // =======================
            // INCIDENT IMAGE
            // =======================
            ClipRRect(
              borderRadius: BorderRadius.circular(10),
              child: networkImage != null && networkImage!.isNotEmpty
                  ? Image.network(
                      networkImage!,
                      width: 72,
                      height: 72,
                      fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) => Image.asset(
                        'assets/images/placeholder.jpg',
                        width: 72,
                        height: 72,
                        fit: BoxFit.cover,
                      ),
                    )
                  : Image.asset(
                      'assets/images/placeholder.jpg',
                      width: 72,
                      height: 72,
                      fit: BoxFit.cover,
                    ),
            ),

            SizedBox(width: 12),

            // =======================
            // TEXT DETAILS
            // =======================
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      // Title
                      Expanded(
                        child: Text(
                          title,
                          style: const TextStyle(
                            fontWeight: FontWeight.w700,
                            fontSize: 14,
                          ),
                        ),
                      ),

                      // Badge
                      Container(
                        padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: badgeColor.withOpacity(0.12),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          badge,
                          style: TextStyle(
                            color: badgeColor,
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                  ),

                  SizedBox(height: 6),

                  Text(
                    subtitle,
                    style: TextStyle(
                      color: Colors.grey[700],
                      fontSize: 13,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
