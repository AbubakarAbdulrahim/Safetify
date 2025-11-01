import 'package:flutter/material.dart';
import '../constants.dart';

class IncidentCard extends StatelessWidget {
  final String title;
  final String subtitle;
  final String imageAsset;
  final String badge;
  final Color badgeColor;
  final VoidCallback? onTap;

  const IncidentCard({
    super.key,
    required this.title,
    required this.subtitle,
    this.imageAsset = 'assets/images/fire.jpg',
    this.badge = 'Unverified',
    this.badgeColor = AppColors.amber,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(14),
      child: Container(
        decoration: BoxDecoration(color: AppColors.card, borderRadius: BorderRadius.circular(14), boxShadow: [
          BoxShadow(color: Colors.black12, blurRadius: 8, offset: Offset(0, 3)),
        ]),
        padding: EdgeInsets.all(12),
        child: Row(
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(10),
              child: Image.asset(imageAsset, width: 72, height: 72, fit: BoxFit.cover),
            ),
            SizedBox(width: 12),
            Expanded(
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Row(children: [
                  Expanded(child: Text(title, style: TextStyle(fontWeight: FontWeight.w700))),
                  Container(
                    padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(color: badgeColor.withOpacity(0.12), borderRadius: BorderRadius.circular(8)),
                    child: Text(badge, style: TextStyle(color: badgeColor, fontSize: 12, fontWeight: FontWeight.w600)),
                  )
                ]),
                SizedBox(height: 6),
                Text(subtitle, style: TextStyle(color: Colors.grey[700], fontSize: 13)),
              ]),
            )
          ],
        ),
      ),
    );
  }
}
