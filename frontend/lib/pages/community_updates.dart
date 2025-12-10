import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:share_plus/share_plus.dart';
import 'package:timeago/timeago.dart' as timeago;
import 'package:intl/intl.dart';
import '../constants.dart';
import '../services/firestore_service.dart';

class CommunityUpdatesPage extends StatefulWidget {
  const CommunityUpdatesPage({super.key});

  @override
  State<CommunityUpdatesPage> createState() => _CommunityUpdatesPageState();
}

class _CommunityUpdatesPageState extends State<CommunityUpdatesPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        title: const Text('Community Updates'),
        backgroundColor: Theme.of(context).appBarTheme.backgroundColor,
        foregroundColor: Theme.of(context).iconTheme.color,
        elevation: 0,
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          setState(() {});
          await Future.delayed(const Duration(seconds: 1));
        },
        child: StreamBuilder<List<Map<String, dynamic>>>(
          stream: FirestoreService().getCommunityUpdates(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return _buildLoadingSkeleton();
            }

            if (!snapshot.hasData || snapshot.data!.isEmpty) {
              return _buildEmptyState();
            }

            final updates = snapshot.data!;
            final groupedUpdates = _groupUpdatesByTime(updates);

            return ListView(
              padding: const EdgeInsets.all(16),
              children: [
                // Today
                if (groupedUpdates['Today']!.isNotEmpty) ...[
                  _buildSectionHeader('Today', groupedUpdates['Today']!.length),
                  ...groupedUpdates['Today']!.map((update) => _buildUpdateCard(update)),
                ],

                // This Week
                if (groupedUpdates['This Week']!.isNotEmpty) ...[
                  _buildSectionHeader('This Week', groupedUpdates['This Week']!.length),
                  ...groupedUpdates['This Week']!.map((update) => _buildUpdateCard(update)),
                ],

                // This Month
                if (groupedUpdates['This Month']!.isNotEmpty) ...[
                  _buildSectionHeader('This Month', groupedUpdates['This Month']!.length),
                  ...groupedUpdates['This Month']!.map((update) => _buildUpdateCard(update)),
                ],

                // Older
                if (groupedUpdates['Older']!.isNotEmpty) ...[
                  _buildSectionHeader('Older', groupedUpdates['Older']!.length),
                  ...groupedUpdates['Older']!.map((update) => _buildUpdateCard(update)),
                ],
              ],
            );
          },
        ),
      ),
    );
  }

  Map<String, List<Map<String, dynamic>>> _groupUpdatesByTime(List<Map<String, dynamic>> updates) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final weekAgo = today.subtract(const Duration(days: 7));
    final monthAgo = DateTime(now.year, now.month - 1, now.day);

    return {
      'Today': updates.where((update) {
        final createdAt = (update['createdAt'] as Timestamp).toDate();
        return createdAt.isAfter(today);
      }).toList(),
      'This Week': updates.where((update) {
        final createdAt = (update['createdAt'] as Timestamp).toDate();
        return createdAt.isAfter(weekAgo) && createdAt.isBefore(today);
      }).toList(),
      'This Month': updates.where((update) {
        final createdAt = (update['createdAt'] as Timestamp).toDate();
        return createdAt.isAfter(monthAgo) && createdAt.isBefore(weekAgo);
      }).toList(),
      'Older': updates.where((update) {
        final createdAt = (update['createdAt'] as Timestamp).toDate();
        return createdAt.isBefore(monthAgo);
      }).toList(),
    };
  }

  Widget _buildSectionHeader(String title, int count) {
    return Padding(
      padding: const EdgeInsets.only(top: 16, bottom: 12),
      child: Row(
        children: [
          Text(
            title,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Theme.of(context).textTheme.bodyLarge?.color,
            ),
          ),
          const SizedBox(width: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
            decoration: BoxDecoration(
              color: AppColors.safetyBlue.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              '$count',
              style: const TextStyle(
                fontSize: 12,
                color: AppColors.safetyBlue,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildUpdateCard(Map<String, dynamic> update) {
    final title = update['title'] ?? 'Update';
    final description = update['description'] ?? '';
    final category = update['category'] ?? 'Info';
    final priority = update['priority'] ?? 'Info';
    final imageUrl = update['imageUrl'];
    final createdAt = (update['createdAt'] as Timestamp).toDate();
    final location = update['location'];
    final eventDate = update['eventDate'] != null 
        ? (update['eventDate'] as Timestamp).toDate() 
        : null;

    final categoryIcon = _getCategoryIcon(category);
    final categoryColor = _getCategoryColor(category);
    final priorityColor = _getPriorityColor(priority);

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(16),
        border: priority == 'Urgent' 
            ? Border.all(color: AppColors.alertRed, width: 2)
            : null,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Image if available
          if (imageUrl != null && imageUrl.isNotEmpty)
            ClipRRect(
              borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
              child: Image.network(
                imageUrl,
                height: 180,
                width: double.infinity,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) => Container(
                  height: 180,
                  color: Colors.grey.withOpacity(0.2),
                  child: const Center(
                    child: Icon(Icons.image_not_supported, size: 40, color: Colors.grey),
                  ),
                ),
              ),
            ),

          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header Row with Category and Priority
                Row(
                  children: [
                    // Category Badge
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: categoryColor.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(categoryIcon, size: 14, color: categoryColor),
                          const SizedBox(width: 4),
                          Text(
                            category,
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.bold,
                              color: categoryColor,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 8),

                    // Priority Badge
                    if (priority != 'Info')
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: priorityColor.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              priority == 'Urgent' ? Icons.warning : Icons.info,
                              size: 14,
                              color: priorityColor,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              priority,
                              style: TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.bold,
                                color: priorityColor,
                              ),
                            ),
                          ],
                        ),
                      ),

                    const Spacer(),

                    // Share Button
                    IconButton(
                      icon: const Icon(Icons.share, size: 20),
                      onPressed: () => _shareUpdate(title, description, location),
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints(),
                    ),
                  ],
                ),

                const SizedBox(height: 12),

                // Title
                Text(
                  title,
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 17,
                    color: Theme.of(context).textTheme.bodyLarge?.color,
                  ),
                ),

                const SizedBox(height: 8),

                // Description
                Text(
                  description,
                  style: TextStyle(
                    color: Theme.of(context).textTheme.bodyMedium?.color,
                    fontSize: 14,
                    height: 1.5,
                  ),
                ),

                const SizedBox(height: 12),

                // Location if available
                if (location != null && location.isNotEmpty)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 8),
                    child: Row(
                      children: [
                        Icon(
                          Icons.location_on,
                          size: 16,
                          color: AppColors.safetyBlue,
                        ),
                        const SizedBox(width: 4),
                        Expanded(
                          child: Text(
                            location,
                            style: TextStyle(
                              fontSize: 13,
                              color: Theme.of(context).textTheme.bodyMedium?.color,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                // Event Date if available
                if (eventDate != null)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 8),
                    child: Row(
                      children: [
                        Icon(
                          Icons.event,
                          size: 16,
                          color: AppColors.successGreen,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          'Event: ${DateFormat('MMM d, y h:mm a').format(eventDate)}',
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                            color: AppColors.successGreen,
                          ),
                        ),
                      ],
                    ),
                  ),

                // Time
                Row(
                  children: [
                    Icon(
                      Icons.access_time,
                      size: 14,
                      color: Theme.of(context).iconTheme.color?.withOpacity(0.5),
                    ),
                    const SizedBox(width: 4),
                    Text(
                      timeago.format(createdAt),
                      style: TextStyle(
                        color: Theme.of(context).textTheme.bodyMedium?.color?.withOpacity(0.7),
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  IconData _getCategoryIcon(String category) {
    switch (category.toLowerCase()) {
      case 'safety':
        return Icons.shield;
      case 'event':
        return Icons.event;
      case 'alert':
        return Icons.warning_amber_rounded;
      case 'maintenance':
        return Icons.construction;
      case 'health':
        return Icons.health_and_safety;
      default:
        return Icons.info;
    }
  }

  Color _getCategoryColor(String category) {
    switch (category.toLowerCase()) {
      case 'safety':
        return AppColors.safetyBlue;
      case 'event':
        return AppColors.successGreen;
      case 'alert':
        return AppColors.alertRed;
      case 'maintenance':
        return Colors.orange;
      case 'health':
        return Colors.purple;
      default:
        return Colors.grey;
    }
  }

  Color _getPriorityColor(String priority) {
    switch (priority.toLowerCase()) {
      case 'urgent':
        return AppColors.alertRed;
      case 'important':
        return Colors.orange;
      default:
        return AppColors.safetyBlue;
    }
  }

  void _shareUpdate(String title, String description, String? location) {
    String shareText = '📢 $title\n\n$description';
    if (location != null && location.isNotEmpty) {
      shareText += '\n\n📍 $location';
    }
    shareText += '\n\n🛡️ Shared from Safetify';
    Share.share(shareText);
  }

  Widget _buildLoadingSkeleton() {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: 5,
      itemBuilder: (context, index) {
        return Container(
          margin: const EdgeInsets.only(bottom: 16),
          height: 200,
          decoration: BoxDecoration(
            color: Colors.grey.withOpacity(0.2),
            borderRadius: BorderRadius.circular(16),
          ),
        );
      },
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.campaign_outlined,
            size: 80,
            color: Theme.of(context).iconTheme.color?.withOpacity(0.3),
          ),
          const SizedBox(height: 16),
          Text(
            'No Community Updates',
            style: TextStyle(
              color: Theme.of(context).textTheme.bodyLarge?.color,
              fontSize: 18,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Check back later for updates from your community',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: Theme.of(context).textTheme.bodyMedium?.color,
              fontSize: 14,
            ),
          ),
        ],
      ),
    );
  }
}
