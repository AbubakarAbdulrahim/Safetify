import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:safetify/models/incidents.dart';
import 'package:safetify/models/users.dart' as model;
import 'package:safetify/services/firestore_service.dart';
import 'package:share_plus/share_plus.dart';
import 'package:timeago/timeago.dart' as timeago;
import 'package:intl/intl.dart';
import '../constants.dart';

class DetailsPage extends StatefulWidget {
  const DetailsPage({super.key});

  @override
  State<DetailsPage> createState() => _DetailsPageState();
}

class _DetailsPageState extends State<DetailsPage> {

  List<Map<String, String>> _getSafetyTips(String category) {
    const dot = '•';
    switch (category.toLowerCase()) {
      case 'fire':
        return [
          {'tip': 'Stay low to avoid smoke inhalation', 'icon': dot},
          {'tip': 'Evacuate immediately and don\'t return', 'icon': dot},
          {'tip': 'Call emergency services (112)', 'icon': dot},
          {'tip': 'Never use elevators during a fire', 'icon': dot},
        ];
      case 'theft':
      case 'insecurity':
        return [
          {'tip': 'Stay in well-lit, populated areas', 'icon': dot},
          {'tip': 'Keep emergency contacts ready', 'icon': dot},
          {'tip': 'Be aware of your surroundings', 'icon': dot},
          {'tip': 'Secure your belongings', 'icon': dot},
        ];
      case 'accident':
        return [
          {'tip': 'Call emergency services immediately', 'icon': dot},
          {'tip': 'Don\'t move injured persons unless necessary', 'icon': dot},
          {'tip': 'Document the scene if safe', 'icon': dot},
          {'tip': 'Set up warning signs if possible', 'icon': dot},
        ];
      case 'flood':
        return [
          {'tip': 'Move to higher ground immediately', 'icon': dot},
          {'tip': 'Avoid walking/driving through flood water', 'icon': dot},
          {'tip': 'Turn off electricity if safe to do so', 'icon': dot},
          {'tip': 'Monitor weather updates', 'icon': dot},
        ];
      default:
        return [
          {'tip': 'Contact emergency services if needed', 'icon': dot},
          {'tip': 'Evacuate if the area is unsafe', 'icon': dot},
          {'tip': 'Stay with others when possible', 'icon': dot},
          {'tip': 'Keep your phone charged', 'icon': dot},
        ];
    }
  }

  @override
  Widget build(BuildContext context) {
    final args = ModalRoute.of(context)?.settings.arguments;
    String? incidentId;
    Incident? initialIncident;

    if (args is Incident) {
      initialIncident = args;
      incidentId = args.id;
    } else if (args is Map && args['incidentId'] != null) {
      incidentId = args['incidentId'];
    }

    if (incidentId == null) {
      return const Scaffold(body: Center(child: Text("Error: Invalid Incident ID")));
    }

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: StreamBuilder<Incident>(
        stream: FirestoreService().getIncidentStream(incidentId),
        initialData: initialIncident,
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }

          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }

          final liveIncident = snapshot.data!;

          void shareIncident() {
            final String message = '''
        🚨 Incident Alert

        ${liveIncident.category} at ${liveIncident.locationName}
        Time: ${timeago.format(liveIncident.createdAt)}
        Description: ${liveIncident.description}

        Stay safe and report updates on Safetify!
        ''';
            Share.share(message, subject: 'Incident Alert: ${liveIncident.category}');
          }
          final currentUser = FirebaseAuth.instance.currentUser;
          final currentUserId = currentUser?.uid;
          
          final upvotes = liveIncident.upvotes;
          final downvotes = liveIncident.downvotes;
          final userVote = currentUserId != null ? liveIncident.userVotes[currentUserId] : null;
          final hasUpvoted = userVote == 'up';
          final hasDownvoted = userVote == 'down';

          void handleVote(String type) {
            if (currentUserId == null) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Please login to vote')),
              );
              return;
            }
            FirestoreService().voteIncident(liveIncident.id, currentUserId, type);
          }

          return CustomScrollView(
            slivers: [
              // App Bar with Image
              SliverAppBar(
                expandedHeight: 300,
                pinned: true,
                backgroundColor: Theme.of(context).appBarTheme.backgroundColor,
                foregroundColor: Theme.of(context).iconTheme.color,
                flexibleSpace: FlexibleSpaceBar(
                  background: Stack(
                    fit: StackFit.expand,
                    children: [
                      // Hero Image
                      Hero(
                        tag: 'incident_${liveIncident.id}',
                        child: liveIncident.photoUrl.isNotEmpty
                            ? Image.network(
                                liveIncident.photoUrl,
                                fit: BoxFit.cover,
                                errorBuilder: (context, error, stackTrace) => Container(
                                  color: Colors.grey.withOpacity(0.3),
                                  child: const Icon(Icons.image_not_supported, size: 60),
                                ),
                              )
                            : Container(
                                color: Colors.grey.withOpacity(0.3),
                                child: const Icon(Icons.image, size: 60, color: Colors.grey),
                              ),
                      ),
                      
                      // Gradient Overlay
                      Container(
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                            colors: [
                              Colors.transparent,
                              Colors.black.withOpacity(0.7),
                            ],
                          ),
                        ),
                      ),

                      // Category Badge
                      Positioned(
                        top: 100,
                        right: 16,
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                          decoration: BoxDecoration(
                            color: _getCategoryColor(liveIncident.category),
                            borderRadius: BorderRadius.circular(20),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.3),
                                blurRadius: 8,
                              ),
                            ],
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(_getCategoryIcon(liveIncident.category), color: Colors.white, size: 16),
                              const SizedBox(width: 4),
                              Text(
                                liveIncident.category,
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 12,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                actions: [
                  IconButton(
                    icon: const Icon(Icons.share),
                    onPressed: shareIncident,
                  ),
                ],
              ),

              // Content
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Title and Status
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              '${liveIncident.category} Incident',
                              style: TextStyle(
                                fontSize: 24,
                                fontWeight: FontWeight.bold,
                                color: Theme.of(context).textTheme.bodyLarge?.color,
                              ),
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                            decoration: BoxDecoration(
                              color: liveIncident.resolved
                                  ? AppColors.safetyBlue.withOpacity(0.1)
                                  : (liveIncident.verified
                                      ? AppColors.successGreen.withOpacity(0.1)
                                      : AppColors.alertRed.withOpacity(0.1)),
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(
                                  liveIncident.resolved
                                      ? Icons.check_circle
                                      : (liveIncident.verified ? Icons.verified : Icons.warning),
                                  size: 16,
                                  color: liveIncident.resolved
                                      ? AppColors.safetyBlue
                                      : (liveIncident.verified ? AppColors.successGreen : AppColors.alertRed),
                                ),
                                const SizedBox(width: 4),
                                Text(
                                  liveIncident.resolved
                                      ? 'Resolved'
                                      : (liveIncident.verified ? 'Verified' : 'Unverified'),
                                  style: TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.bold,
                                    color: liveIncident.resolved
                                        ? AppColors.safetyBlue
                                        : (liveIncident.verified ? AppColors.successGreen : AppColors.alertRed),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 16),

                      // Reporter Information
                      FutureBuilder<model.User>(
                        future: FirestoreService().getUser(liveIncident.userId),
                        builder: (context, snapshot) {
                          if (!snapshot.hasData) {
                            return const SizedBox.shrink();
                          }

                          final reporter = snapshot.data!;
                          return Container(
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: Theme.of(context).cardColor,
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(color: Theme.of(context).dividerColor),
                            ),
                            child: Row(
                              children: [
                                CircleAvatar(
                                  radius: 24,
                                  backgroundColor: AppColors.safetyBlue,
                                  backgroundImage: reporter.profileImage.isNotEmpty
                                      ? NetworkImage(reporter.profileImage!)
                                      : null,
                                  child: reporter.profileImage.isEmpty
                                      ? Text(
                                          reporter.name?.substring(0, 1).toUpperCase() ?? 'U',
                                          style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                                        )
                                      : null,
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        'Reported by',
                                        style: TextStyle(
                                          fontSize: 11,
                                          color: Theme.of(context).textTheme.bodyMedium?.color,
                                        ),
                                      ),
                                      Text(
                                        reporter.name ?? 'Unknown User',
                                        style: TextStyle(
                                          fontSize: 15,
                                          fontWeight: FontWeight.bold,
                                          color: Theme.of(context).textTheme.bodyLarge?.color,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                  decoration: BoxDecoration(
                                    color: AppColors.successGreen.withOpacity(0.1),
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: Row(
                                    children: [
                                      Icon(Icons.star, size: 14, color: AppColors.successGreen),
                                      const SizedBox(width: 4),
                                      Text(
                                        '4.8',
                                        style: TextStyle(
                                          fontSize: 12,
                                          fontWeight: FontWeight.bold,
                                          color: AppColors.successGreen,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          );
                        },
                      ),

                      const SizedBox(height: 20),

                      // Location and Time
                      _buildInfoRow(Icons.location_on, liveIncident.locationName, AppColors.safetyBlue),
                      const SizedBox(height: 8),
                      _buildInfoRow(
                        Icons.access_time,
                        '${timeago.format(liveIncident.createdAt)} • ${DateFormat('MMM d, y h:mm a').format(liveIncident.createdAt)}',
                        Colors.grey,
                      ),

                      const SizedBox(height: 24),

                      // Description
                      Text(
                        'Description',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Theme.of(context).textTheme.bodyLarge?.color,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        liveIncident.description,
                        style: TextStyle(
                          fontSize: 15,
                          height: 1.6,
                          color: Theme.of(context).textTheme.bodyMedium?.color,
                        ),
                      ),

                      const SizedBox(height: 24),

                      // Reactions
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Theme.of(context).cardColor,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: Theme.of(context).dividerColor),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Community Feedback',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: Theme.of(context).textTheme.bodyLarge?.color,
                              ),
                            ),
                            const SizedBox(height: 12),
                            Row(
                              children: [
                                Expanded(
                                  child: _buildReactionButton(
                                    icon: Icons.thumb_up,
                                    label: 'Accurate',
                                    count: upvotes,
                                    isActive: hasUpvoted,
                                    color: AppColors.successGreen,
                                    onTap: () => handleVote('up'),
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: _buildReactionButton(
                                    icon: Icons.thumb_down,
                                    label: 'Inaccurate',
                                    count: downvotes,
                                    isActive: hasDownvoted,
                                    color: AppColors.alertRed,
                                    onTap: () => handleVote('down'),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(height: 24),

                      // Safety Tips
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [
                              AppColors.amber.withOpacity(0.1),
                              AppColors.amber.withOpacity(0.05),
                            ],
                          ),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: AppColors.amber.withOpacity(0.3)),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Icon(Icons.lightbulb, color: AppColors.amber, size: 24),
                                const SizedBox(width: 8),
                                Text(
                                  'Safety Tips',
                                  style: TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                    color: Theme.of(context).textTheme.bodyLarge?.color,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 12),
                            ..._getSafetyTips(liveIncident.category).map((tip) {
                              return Padding(
                                padding: const EdgeInsets.only(bottom: 12),
                                child: Row(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      tip['icon']!,
                                      style: const TextStyle(fontSize: 20),
                                    ),
                                    const SizedBox(width: 12),
                                    Expanded(
                                      child: Text(
                                        tip['tip']!,
                                        style: TextStyle(
                                          fontSize: 14,
                                          height: 1.4,
                                          color: Theme.of(context).textTheme.bodyMedium?.color,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              );
                            }).toList(),
                          ],
                        ),
                      ),
                      const SizedBox(height: 40),
                    ],
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, String text, Color color) {
    return Row(
      children: [
        Icon(icon, size: 20, color: color),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            text,
            style: TextStyle(
              fontSize: 14,
              color: Theme.of(context).textTheme.bodyMedium?.color,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildReactionButton({
    required IconData icon,
    required String label,
    required int count,
    required bool isActive,
    required Color color,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          color: isActive ? color.withOpacity(0.1) : Colors.transparent,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isActive ? color : Theme.of(context).dividerColor,
            width: isActive ? 2 : 1,
          ),
        ),
        child: Column(
          children: [
            Icon(
              icon,
              color: isActive ? color : Theme.of(context).iconTheme.color,
              size: 24,
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: TextStyle(
                fontSize: 12,
                fontWeight: isActive ? FontWeight.bold : FontWeight.normal,
                color: isActive ? color : Theme.of(context).textTheme.bodyMedium?.color,
              ),
            ),
            if (count > 0)
              Text(
                '$count',
                style: TextStyle(
                  fontSize: 11,
                  color: isActive ? color : Theme.of(context).textTheme.bodyMedium?.color,
                ),
              ),
          ],
        ),
      ),
    );
  }

  IconData _getCategoryIcon(String category) {
    switch (category.toLowerCase()) {
      case 'fire':
        return Icons.local_fire_department;
      case 'theft':
      case 'insecurity':
        return Icons.security;
      case 'accident':
        return Icons.car_crash;
      case 'flood':
        return Icons.water_damage;
      case 'traffic':
        return Icons.traffic;
      case 'medical':
        return Icons.medical_services;
      case 'blockage':
        return Icons.block;
      case 'waste':
        return Icons.delete_outline;
      case 'other':
        return Icons.info_outline;
      default:
        return Icons.warning_amber_rounded;
    }
  }

  Color _getCategoryColor(String category) {
    switch (category.toLowerCase()) {
      case 'fire':
        return AppColors.alertRed;
      case 'theft':
      case 'insecurity':
        return Colors.deepOrange;
      case 'accident':
        return Colors.orange;
      case 'flood':
        return Colors.blue;
      case 'traffic':
        return AppColors.safetyBlue;
      case 'blockage':
        return Colors.purple;
      case 'medical':
        return Colors.teal;
      case 'waste':
        return Colors.brown;
      case 'other':
        return Colors.grey;
      default:
        return Colors.red;
    }
  }
}
