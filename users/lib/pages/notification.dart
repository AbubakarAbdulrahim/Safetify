import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:safetify/models/incidents.dart';
import 'package:timeago/timeago.dart' as timeago;
import 'package:flutter_slidable/flutter_slidable.dart';
import '../services/firestore_service.dart';
import 'package:geolocator/geolocator.dart';
import '../services/location_service.dart';
import '../constants.dart';

class NotificationPage extends StatefulWidget {
  const NotificationPage({super.key});

  @override
  State<NotificationPage> createState() => _NotificationPageState();
}

class _NotificationPageState extends State<NotificationPage> {
  final FirestoreService _firestore = FirestoreService();
  String _selectedFilter = 'All';
  final Set<String> _readNotifications = {};
  Position? _currentPosition;

  @override
  void initState() {
    super.initState();
    _loadReadStatus();
    _fetchLocation();
  }

  Future<void> _loadReadStatus() async {
    final prefs = await SharedPreferences.getInstance();
    final readIds = prefs.getStringList('read_notifications') ?? [];
    if (mounted) {
      setState(() {
        _readNotifications.addAll(readIds);
      });
    }
  }

  Future<void> _markAsRead(String id) async {
    if (_readNotifications.contains(id)) return;
    
    setState(() {
      _readNotifications.add(id);
    });
    
    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList('read_notifications', _readNotifications.toList());
  }

  Future<void> _markAllAsRead(List<Incident> incidents) async {
    final ids = incidents.map((i) => i.id).toList();
    setState(() {
      _readNotifications.addAll(ids);
    });
    
    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList('read_notifications', _readNotifications.toList());
  }

  Future<void> _fetchLocation() async {
    final position = await LocationService().getCurrentLocation();
    if (mounted) {
      setState(() {
        _currentPosition = position;
      });
    }
  }

  List<Incident> _filterIncidents(List<Incident> incidents) {
    switch (_selectedFilter) {
      case 'Nearby':
        if (_currentPosition == null) return [];
        return incidents.where((i) {
          final distance = LocationService().calculateDistance(
            _currentPosition!.latitude,
            _currentPosition!.longitude,
            i.lat,
            i.lon,
          );
          return distance <= 5.0; // 5km radius
        }).toList();
      case 'Emergency':
        return incidents.where((i) => 
          i.category.toLowerCase().contains('emergency') ||
          i.category.toLowerCase().contains('fire') ||
          i.category.toLowerCase().contains('accident')
        ).toList();
      case 'Verified':
        return incidents.where((i) => i.verified).toList();
      default:
        return incidents;
    }
  }

  Map<String, List<Incident>> _categorizeByTime(List<Incident> incidents) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final yesterday = today.subtract(const Duration(days: 1));
    final weekAgo = today.subtract(const Duration(days: 7));

    return {
      'today': incidents.where((i) => i.createdAt.isAfter(today)).toList(),
      'yesterday': incidents.where((i) => 
        i.createdAt.isAfter(yesterday) && i.createdAt.isBefore(today)
      ).toList(),
      'thisWeek': incidents.where((i) => 
        i.createdAt.isAfter(weekAgo) && i.createdAt.isBefore(yesterday)
      ).toList(),
      'older': incidents.where((i) => i.createdAt.isBefore(weekAgo)).toList(),
    };
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        title: const Text("Notifications"),
        backgroundColor: Theme.of(context).appBarTheme.backgroundColor,
        elevation: 0,
        foregroundColor: Theme.of(context).iconTheme.color,
        actions: [
          // Mark all as read
          IconButton(
            icon: const Icon(Icons.done_all),
            tooltip: 'Mark all as read',
            onPressed: () async {
              // Fetch latest incidents to mark them as read
              final incidents = await _firestore.getAllIncidents(limit: 50).first;
              if (context.mounted) {
                 await _markAllAsRead(incidents);
                 ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Marked recent notifications as read'),
                    duration: Duration(seconds: 2),
                  ),
                );
              }
            },
          ),
          // Filter menu
          PopupMenuButton<String>(
            icon: const Icon(Icons.filter_list),
            onSelected: (value) {
              setState(() {
                _selectedFilter = value;
              });
            },
            itemBuilder: (context) => [
              const PopupMenuItem(value: 'All', child: Text('All Notifications')),
              const PopupMenuItem(value: 'Nearby', child: Text('Nearby Only')),
              const PopupMenuItem(value: 'Emergency', child: Text('Emergency')),
              const PopupMenuItem(value: 'Verified', child: Text('Verified Only')),
            ],
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          setState(() {});
          await Future.delayed(const Duration(seconds: 1));
        },
        child: StreamBuilder<List<Incident>>(
          stream: _firestore.getAllIncidents(limit: 50),
          builder: (context, snapshot) {
            // Loading State
            if (snapshot.connectionState == ConnectionState.waiting) {
              return _buildLoadingSkeleton();
            }

            // Empty State
            if (!snapshot.hasData || snapshot.data!.isEmpty) {
              return _buildEmptyState();
            }

            final allIncidents = snapshot.data!;
            final filteredIncidents = _filterIncidents(allIncidents);

            if (filteredIncidents.isEmpty) {
              return _buildNoResultsState();
            }

            // Categorize by time
            final categorized = _categorizeByTime(filteredIncidents);

            return ListView(
              padding: const EdgeInsets.all(12),
              children: [
                // Filter chips
                _buildFilterChips(),
                const SizedBox(height: 12),

                // Categorized notifications
                if (categorized['today']!.isNotEmpty) ...[
                  _buildSectionHeader('Today', categorized['today']!.length),
                  ...categorized['today']!.map((incident) => _buildNotificationCard(incident)),
                ],
                if (categorized['yesterday']!.isNotEmpty) ...[
                  _buildSectionHeader('Yesterday', categorized['yesterday']!.length),
                  ...categorized['yesterday']!.map((incident) => _buildNotificationCard(incident)),
                ],
                if (categorized['thisWeek']!.isNotEmpty) ...[
                  _buildSectionHeader('This Week', categorized['thisWeek']!.length),
                  ...categorized['thisWeek']!.map((incident) => _buildNotificationCard(incident)),
                ],
                if (categorized['older']!.isNotEmpty) ...[
                  _buildSectionHeader('Older', categorized['older']!.length),
                  ...categorized['older']!.map((incident) => _buildNotificationCard(incident)),
                ],
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _buildFilterChips() {
    final filters = ['All', 'Nearby', 'Emergency', 'Verified'];
    return SizedBox(
      height: 40,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: filters.length,
        itemBuilder: (context, index) {
          final filter = filters[index];
          final isSelected = _selectedFilter == filter;
          return Padding(
            padding: const EdgeInsets.only(right: 8),
            child: FilterChip(
              label: Text(filter),
              selected: isSelected,
              onSelected: (selected) {
                setState(() {
                  _selectedFilter = filter;
                });
              },
              backgroundColor: Theme.of(context).cardColor,
              selectedColor: AppColors.safetyBlue.withOpacity(0.2),
              labelStyle: TextStyle(
                color: isSelected ? AppColors.safetyBlue : Theme.of(context).textTheme.bodyMedium?.color,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
              ),
              checkmarkColor: AppColors.safetyBlue,
            ),
          );
        },
      ),
    );
  }

  Widget _buildSectionHeader(String title, int count) {
    return Padding(
      padding: const EdgeInsets.only(top: 16, bottom: 8, left: 4),
      child: Row(
        children: [
          Text(
            title,
            style: TextStyle(
              fontSize: 16,
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

  Widget _buildLoadingSkeleton() {
    return ListView.builder(
      padding: const EdgeInsets.all(12),
      itemCount: 10,
      itemBuilder: (context, index) {
        return Card(
          margin: const EdgeInsets.only(bottom: 12),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Row(
              children: [
                Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    color: Colors.grey.withOpacity(0.3),
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        width: double.infinity,
                        height: 16,
                        decoration: BoxDecoration(
                          color: Colors.grey.withOpacity(0.3),
                          borderRadius: BorderRadius.circular(4),
                        ),
                      ),
                      const SizedBox(height: 8),
                      Container(
                        width: 150,
                        height: 12,
                        decoration: BoxDecoration(
                          color: Colors.grey.withOpacity(0.3),
                          borderRadius: BorderRadius.circular(4),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
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
            Icons.notifications_off_outlined,
            size: 80,
            color: Theme.of(context).iconTheme.color?.withOpacity(0.3),
          ),
          const SizedBox(height: 16),
          Text(
            "No notifications yet",
            style: TextStyle(
              color: Theme.of(context).textTheme.bodyLarge?.color,
              fontSize: 18,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            "You'll be notified about incidents near you",
            style: TextStyle(
              color: Theme.of(context).textTheme.bodyMedium?.color,
              fontSize: 14,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNoResultsState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.filter_list_off,
            size: 60,
            color: Theme.of(context).iconTheme.color?.withOpacity(0.3),
          ),
          const SizedBox(height: 16),
          Text(
            "No $_selectedFilter notifications",
            style: TextStyle(
              color: Theme.of(context).textTheme.bodyLarge?.color,
              fontSize: 16,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            "Try changing the filter",
            style: TextStyle(
              color: Theme.of(context).textTheme.bodyMedium?.color,
              fontSize: 14,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNotificationCard(Incident incident) {
    final isRead = _readNotifications.contains(incident.id);
    
    return Slidable(
      key: ValueKey(incident.id),
      endActionPane: ActionPane(
        motion: const ScrollMotion(),
        children: [
          SlidableAction(
            onPressed: (context) => _markAsRead(incident.id),
            backgroundColor: AppColors.safetyBlue,
            foregroundColor: Colors.white,
            icon: Icons.done,
            label: 'Mark Read',
          ),
        ],
      ),
      child: Card(
        margin: const EdgeInsets.only(bottom: 8),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        child: InkWell(
          onTap: () {
            _markAsRead(incident.id);
            Navigator.pushNamed(context, '/details', arguments: incident);
          },
          borderRadius: BorderRadius.circular(12),
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Row(
              children: [
                // Category Icon
                Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    color: _getCategoryColor(incident.category).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(
                    _getCategoryIcon(incident.category),
                    color: _getCategoryColor(incident.category),
                    size: 24,
                  ),
                ),
                const SizedBox(width: 12),
                
                // Content
                Expanded(
                  child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              incident.category,
                              style: TextStyle(
                                fontSize: 15,
                                fontWeight: isRead ? FontWeight.normal : FontWeight.bold,
                                color: Theme.of(context).textTheme.bodyLarge?.color,
                              ),
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                            decoration: BoxDecoration(
                              color: incident.resolved
                                  ? AppColors.safetyBlue.withOpacity(0.1)
                                  : (incident.verified
                                      ? AppColors.successGreen.withOpacity(0.1)
                                      : AppColors.alertRed.withOpacity(0.1)),
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: Text(
                              incident.resolved
                                  ? 'Resolved'
                                  : (incident.verified ? 'Verified' : 'Unverified'),
                              style: TextStyle(
                                fontSize: 10,
                                color: incident.resolved
                                    ? AppColors.safetyBlue
                                    : (incident.verified ? AppColors.successGreen : AppColors.alertRed),
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Text(
                        incident.locationName,
                        style: TextStyle(
                          fontSize: 13,
                          color: Theme.of(context).textTheme.bodyMedium?.color,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        timeago.format(incident.createdAt),
                        style: TextStyle(
                          fontSize: 12,
                          color: Theme.of(context).textTheme.bodySmall?.color,
                        ),
                      ),
                    ],
                  ),
                ),
                
                // Unread indicator
                if (!isRead)
                  Container(
                    width: 8,
                    height: 8,
                    decoration: const BoxDecoration(
                      color: AppColors.alertRed,
                      shape: BoxShape.circle,
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  IconData _getCategoryIcon(String category) {
    final cat = category.toLowerCase();
    if (cat.contains('insecurity')) return Icons.health_and_safety;
    if (cat.contains('fire')) return Icons.local_fire_department_rounded;
    if (cat.contains('traffic')) return Icons.directions_car_rounded;
    if (cat.contains('waste')) return Icons.delete_rounded;
    if (cat.contains('flood')) return Icons.water_rounded;
    if (cat.contains('blockage')) return Icons.warning;
    if (cat.contains('accident')) return Icons.car_crash;
    if (cat.contains('ambulance') || cat.contains('medical')) return Icons.medical_services_rounded;
    if (cat.contains('other')) return Icons.report_problem_rounded;
    
    // Fallback
    if (cat.contains('theft') || cat.contains('robbery')) return Icons.health_and_safety;
    if (cat.contains('assault')) return Icons.health_and_safety;
    if (cat.contains('emergency')) return Icons.health_and_safety;
    if (cat.contains('suspicious')) return Icons.visibility;
    
    return Icons.report_problem_rounded;
  }

  Color _getCategoryColor(String category) {
    final cat = category.toLowerCase();
    if (cat.contains('insecurity')) return Colors.red;
    if (cat.contains('fire')) return Colors.deepOrange;
    if (cat.contains('traffic')) return Colors.blue;
    if (cat.contains('waste')) return Colors.brown;
    if (cat.contains('flood')) return Colors.lightBlue;
    if (cat.contains('blockage')) return Colors.green;
    if (cat.contains('accident')) return Colors.orange;
    if (cat.contains('ambulance') || cat.contains('medical')) return Colors.purple;
    if (cat.contains('other')) return Colors.purple;
    
    // Fallback
    if (cat.contains('theft') || cat.contains('robbery')) return Colors.red;
    if (cat.contains('assault')) return Colors.red;
    if (cat.contains('emergency')) return Colors.red;
    
    return Colors.purple;
  }
}