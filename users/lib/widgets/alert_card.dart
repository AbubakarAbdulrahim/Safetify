import 'package:flutter/material.dart';
import 'package:timeago/timeago.dart' as timeago;
import 'package:share_plus/share_plus.dart';
import '../constants.dart';
import '../services/url_launcher_service.dart';
import '../services/location_service.dart';

class AlertCard extends StatefulWidget {
  final Map<String, dynamic> alert;
  const AlertCard({super.key, required this.alert});

  @override
  State<AlertCard> createState() => _AlertCardState();
}

class _AlertCardState extends State<AlertCard> with SingleTickerProviderStateMixin {
  bool _isExpanded = false;
  late AnimationController _pulseController;
  late Animation<double> _pulseAnimation;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );
    _pulseAnimation = Tween<double>(begin: 1.0, end: 1.05).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );

    // Pulse animation for critical alerts
    if (_getSeverity() == 'CRITICAL') {
      _pulseController.repeat(reverse: true);
    }
  }

  @override
  void dispose() {
    _pulseController.dispose();
    super.dispose();
  }

  String _getSeverity() {
    final category = (widget.alert['category'] ?? widget.alert['title'] ?? '').toString().toLowerCase();
    if (category.contains('fire') || 
        category.contains('emergency') || 
        category.contains('explosion') ||
        category.contains('ambulance') ||
        category.contains('medical')) {
      return 'CRITICAL';
    } else if (category.contains('accident') || 
               category.contains('assault') || 
               category.contains('robbery')) {
      return 'HIGH';
    } else if (category.contains('theft') || category.contains('suspicious')) {
      return 'MEDIUM';
    }
    return 'LOW';
  }

  Color _getSeverityColor() {
    switch (_getSeverity()) {
      case 'CRITICAL':
        return AppColors.alertRed;
      case 'HIGH':
        return Colors.deepOrange;
      case 'MEDIUM':
        return Colors.orange;
      default:
        // Check for blockage explicitly as it falls into default/LOW but needs specific color
        if (_getSeverity() == 'LOW' && 
            (widget.alert['category'] ?? widget.alert['title'] ?? '').toString().toLowerCase().contains('blockage')) {
          return Colors.green;
        }
        return AppColors.successGreen;
    }
  }

  IconData _getCategoryIcon() {
    final category = (widget.alert['category'] ?? widget.alert['title'] ?? '').toString().toLowerCase();
    if (category.contains('insecurity')) return Icons.health_and_safety;
    if (category.contains('fire')) return Icons.local_fire_department_rounded;
    if (category.contains('traffic')) return Icons.directions_car_rounded;
    if (category.contains('waste')) return Icons.delete_rounded;
    if (category.contains('flood')) return Icons.water_rounded;
    if (category.contains('blockage')) return Icons.warning;
    if (category.contains('accident')) return Icons.car_crash;
    if (category.contains('ambulance') || category.contains('medical')) return Icons.medical_services_rounded;
    if (category.contains('other')) return Icons.report_problem_rounded;
    
    // Fallback for older categories or loose matches
    if (category.contains('theft') || category.contains('robbery')) return Icons.health_and_safety;
    if (category.contains('assault')) return Icons.health_and_safety;
    if (category.contains('emergency')) return Icons.health_and_safety;
    if (category.contains('suspicious')) return Icons.visibility;
    
    return Icons.report_problem_rounded;
  }

  String _getTimeAgo() {
    try {
      if (widget.alert['sentAt'] != null) {
        final timestamp = DateTime.fromMillisecondsSinceEpoch(
          widget.alert['sentAt'].millisecondsSinceEpoch,
        );
        return timeago.format(timestamp);
      }
    } catch (e) {
      // Fallback
    }
    return 'Recently';
  }

  Future<String> _getDistance() async {
    final alertLat = widget.alert['lat'] as double?;
    final alertLng = widget.alert['lon'] as double?;

    if (alertLat == null || alertLng == null) return 'Unknown';

    final position = await LocationService().getCurrentLocation();
    if (position == null) return 'Unknown';

    final distance = LocationService().calculateDistance(
      position.latitude,
      position.longitude,
      alertLat,
      alertLng,
    );

    return '${distance.toStringAsFixed(1)}km away';
  }

  @override
  Widget build(BuildContext context) {
    final severity = _getSeverity();
    final severityColor = _getSeverityColor();
    final category = widget.alert['category'] ?? widget.alert['title'] ?? 'Alert';
    final message = widget.alert['message'] ?? widget.alert['description'] ?? 'No details available';
    final location = widget.alert['location'] ?? widget.alert['locationName'] ?? 'Unknown location';
    final reportCount = widget.alert['reportCount'] ?? 1;

    return ScaleTransition(
      scale: severity == 'CRITICAL' ? _pulseAnimation : const AlwaysStoppedAnimation(1.0),
      child: Card(
        elevation: 3,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: BorderSide(
            color: severityColor.withOpacity(0.3),
            width: 2,
          ),
        ),
        margin: const EdgeInsets.only(bottom: 16),
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                Theme.of(context).cardColor,
                severityColor.withOpacity(0.05),
              ],
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header Section
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  border: Border(
                    left: BorderSide(
                      color: severityColor,
                      width: 4,
                    ),
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Title Row
                    Row(
                      children: [
                        // Icon
                        Container(
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            color: severityColor.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Icon(
                            _getCategoryIcon(),
                            color: severityColor,
                            size: 24,
                          ),
                        ),
                        const SizedBox(width: 12),
                        
                        // Title and Severity
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                category,
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 17,
                                  color: Theme.of(context).textTheme.bodyLarge?.color,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Row(
                                children: [
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                                    decoration: BoxDecoration(
                                      color: severityColor.withOpacity(0.2),
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    child: Text(
                                      severity,
                                      style: TextStyle(
                                        fontSize: 10,
                                        color: severityColor,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  Icon(
                                    Icons.people_outline,
                                    size: 14,
                                    color: Theme.of(context).textTheme.bodyMedium?.color,
                                  ),
                                  const SizedBox(width: 4),
                                  Text(
                                    '$reportCount ${reportCount == 1 ? 'report' : 'reports'}',
                                    style: TextStyle(
                                      fontSize: 11,
                                      color: Theme.of(context).textTheme.bodyMedium?.color,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),

                        // Expand/Collapse Button
                        IconButton(
                          icon: Icon(
                            _isExpanded ? Icons.expand_less : Icons.expand_more,
                            color: Theme.of(context).iconTheme.color,
                          ),
                          onPressed: () {
                            setState(() {
                              _isExpanded = !_isExpanded;
                            });
                          },
                        ),
                      ],
                    ),

                    const SizedBox(height: 12),

                    // Message
                    Text(
                      message,
                      style: TextStyle(
                        fontSize: 14,
                        color: Theme.of(context).textTheme.bodyMedium?.color,
                        height: 1.4,
                      ),
                      maxLines: _isExpanded ? null : 2,
                      overflow: _isExpanded ? null : TextOverflow.ellipsis,
                    ),

                    const SizedBox(height: 12),

                    // Location and Time
                    Row(
                      children: [
                        Icon(
                          Icons.location_on,
                          size: 16,
                          color: severityColor,
                        ),
                        const SizedBox(width: 4),
                        Expanded(
                          child: Text(
                            location,
                            style: TextStyle(
                              fontSize: 13,
                              color: Theme.of(context).textTheme.bodyMedium?.color,
                              fontWeight: FontWeight.w500,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: Theme.of(context).cardColor,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: Theme.of(context).dividerColor,
                            ),
                          ),
                          child: FutureBuilder<String>(
                            future: _getDistance(),
                            builder: (context, snapshot) {
                              if (snapshot.connectionState == ConnectionState.waiting) {
                                return const SizedBox(
                                  width: 10,
                                  height: 10,
                                  child: CircularProgressIndicator(strokeWidth: 2),
                                );
                              }
                              return Text(
                                snapshot.data ?? 'Unknown',
                                style: TextStyle(
                                  fontSize: 11,
                                  color: Theme.of(context).textTheme.bodyMedium?.color,
                                  fontWeight: FontWeight.w600,
                                ),
                              );
                            },
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 8),

                    Row(
                      children: [
                        Icon(
                          Icons.access_time,
                          size: 16,
                          color: Theme.of(context).textTheme.bodyMedium?.color,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          _getTimeAgo(),
                          style: TextStyle(
                            fontSize: 12,
                            color: Theme.of(context).textTheme.bodyMedium?.color,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              // Expanded Details Section
              if (_isExpanded) ...[
                Divider(height: 1, color: Theme.of(context).dividerColor),
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Safety Recommendations:',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color: Theme.of(context).textTheme.bodyLarge?.color,
                        ),
                      ),
                      const SizedBox(height: 8),
                      _buildRecommendation(Icons.warning_amber, 'Avoid the area if possible'),
                      _buildRecommendation(Icons.people, 'Stay in groups if you must pass through'),
                      _buildRecommendation(Icons.phone, 'Keep emergency contacts ready'),
                      if (severity == 'CRITICAL')
                        _buildRecommendation(Icons.emergency, 'Call 112 if you see anything suspicious', isUrgent: true),
                    ],
                  ),
                ),
              ],

              // Action Buttons
              Divider(height: 1, color: Theme.of(context).dividerColor),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    _buildActionButton(
                      icon: Icons.directions,
                      label: 'Navigate',
                      onTap: () {
                        // Navigate to map with location
                        Navigator.pushNamed(context, '/map');
                      },
                    ),
                    _buildActionButton(
                      icon: Icons.share,
                      label: 'Share',
                      onTap: () {
                        Share.share(
                          '🚨 Safety Alert: $category at $location\n\n$message\n\nStay safe! - Safetify',
                        );
                      },
                    ),
                    _buildActionButton(
                      icon: Icons.phone,
                      label: 'Emergency',
                      color: AppColors.alertRed,
                      onTap: () {
                        UrlLauncherService.makePhoneCall('112');
                      },
                    ),
                    _buildActionButton(
                      icon: Icons.info_outline,
                      label: 'Details',
                      onTap: () {
                        Navigator.pushNamed(
                          context,
                          '/details',
                          arguments: widget.alert['incidentId'] != null 
                              ? widget.alert 
                              : {
                                  'title': category,
                                  'description': message,
                                  'incidentId': widget.alert['incidentId'],
                                  'status': 'Active',
                                },
                        );
                      },
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildRecommendation(IconData icon, String text, {bool isUrgent = false}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            icon,
            size: 16,
            color: isUrgent ? AppColors.alertRed : Theme.of(context).textTheme.bodyMedium?.color,
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              text,
              style: TextStyle(
                fontSize: 13,
                color: isUrgent 
                    ? AppColors.alertRed 
                    : Theme.of(context).textTheme.bodyMedium?.color,
                fontWeight: isUrgent ? FontWeight.w600 : FontWeight.normal,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButton({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
    Color? color,
  }) {
    final buttonColor = color ?? AppColors.safetyBlue;
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 20, color: buttonColor),
            const SizedBox(height: 4),
            Text(
              label,
              style: TextStyle(
                fontSize: 11,
                color: buttonColor,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
