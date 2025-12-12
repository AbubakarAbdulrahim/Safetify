import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:safetify/models/incidents.dart';
import 'package:safetify/models/users.dart' as model;
import 'package:safetify/services/firestore_service.dart';
import 'package:timeago/timeago.dart' as timeago;
import '../constants.dart';
import 'package:safetify/widgets/incident_card.dart';

class IncidentsHistoryPage extends StatefulWidget {
  const IncidentsHistoryPage({super.key});

  @override
  State<IncidentsHistoryPage> createState() => _IncidentsHistoryPageState();
}

class _IncidentsHistoryPageState extends State<IncidentsHistoryPage> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  String _selectedCategory = 'All';
  String _selectedStatus = 'All';
  String _selectedSort = 'Recent';

  final List<String> _categories = [
    'All',
    'Insecurity',
    'Fire',
    'Traffic',
    'Waste',
    'Flood',
    'Blockage',
    'Accident',
    'Other',
  ];

  final List<String> _statuses = ['All', 'Resolved', 'Verified', 'Unverified'];
  final List<String> _sortOptions = ['Recent', 'Oldest', 'Nearby'];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  List<Incident> _filterAndSortIncidents(List<Incident> incidents, {bool myReportsOnly = false}) {
    var filtered = incidents;

    // Filter by user's own reports if on "My Reports" tab
    if (myReportsOnly) {
      final currentUserId = FirebaseAuth.instance.currentUser?.uid;
      filtered = filtered.where((inc) => inc.userId == currentUserId).toList();
    }

    // Filter by category
    if (_selectedCategory != 'All') {
      filtered = filtered.where((inc) => inc.category == _selectedCategory).toList();
    }

    // Filter by status
    if (_selectedStatus == 'Resolved') {
      filtered = filtered.where((inc) => inc.resolved).toList();
    } else if (_selectedStatus == 'Verified') {
      filtered = filtered.where((inc) => inc.verified && !inc.resolved).toList();
    } else if (_selectedStatus == 'Unverified') {
      filtered = filtered.where((inc) => !inc.verified && !inc.resolved).toList();
    }

    // Sort
    if (_selectedSort == 'Recent') {
      filtered.sort((a, b) => b.createdAt.compareTo(a.createdAt));
    } else if (_selectedSort == 'Oldest') {
      filtered.sort((a, b) => a.createdAt.compareTo(b.createdAt));
    }
    // 'Nearby' 
    // implement later

    return filtered;
  }

  Map<String, List<Incident>> _groupByTime(List<Incident> incidents) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final yesterday = today.subtract(const Duration(days: 1));
    final weekAgo = today.subtract(const Duration(days: 7));

    return {
      'Today': incidents.where((inc) => inc.createdAt.isAfter(today)).toList(),
      'Yesterday': incidents.where((inc) => 
        inc.createdAt.isAfter(yesterday) && inc.createdAt.isBefore(today)
      ).toList(),
      'This Week': incidents.where((inc) => 
        inc.createdAt.isAfter(weekAgo) && inc.createdAt.isBefore(yesterday)
      ).toList(),
      'Older': incidents.where((inc) => inc.createdAt.isBefore(weekAgo)).toList(),
    };
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        title: const Text('Incident History'),
        backgroundColor: Theme.of(context).appBarTheme.backgroundColor,
        foregroundColor: Theme.of(context).iconTheme.color,
        elevation: 0,
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: AppColors.safetyBlue,
          labelColor: AppColors.safetyBlue,
          unselectedLabelColor: Theme.of(context).textTheme.bodyMedium?.color,
          tabs: const [
            Tab(text: 'All Incidents'),
            Tab(text: 'My Reports'),
          ],
        ),
      ),
      body: Column(
        children: [

          // Filter Section
          _buildFilterSection(),
          
          // Tab Content
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                _buildIncidentsList(myReportsOnly: false),
                _buildIncidentsList(myReportsOnly: true),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterSection() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [

          // Category Filter
          Row(
            children: [
              Icon(Icons.category, size: 16, color: Theme.of(context).textTheme.bodyMedium?.color),
              const SizedBox(width: 8),
              Text(
                'Category:',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: Theme.of(context).textTheme.bodyMedium?.color,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          SizedBox(
            height: 36,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: _categories.length,
              itemBuilder: (context, index) {
                final category = _categories[index];
                final isSelected = _selectedCategory == category;
                return Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: FilterChip(
                    label: Text(category),
                    selected: isSelected,
                    onSelected: (selected) {
                      setState(() {
                        _selectedCategory = category;
                      });
                    },
                    backgroundColor: Theme.of(context).cardColor,
                    selectedColor: AppColors.safetyBlue.withOpacity(0.2),
                    labelStyle: TextStyle(
                      color: isSelected ? AppColors.safetyBlue : Theme.of(context).textTheme.bodyMedium?.color,
                      fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                      fontSize: 12,
                    ),
                    checkmarkColor: AppColors.safetyBlue,
                  ),
                );
              },
            ),
          ),
          const SizedBox(height: 12),
          
          // Status and Sort Row
          Row(
            children: [
              
              // Status Filter
              Expanded(
                child: Row(
                  children: [
                    Icon(Icons.verified, size: 16, color: Theme.of(context).textTheme.bodyMedium?.color),
                    const SizedBox(width: 8),
                    Expanded(
                      child: DropdownButton<String>(
                        value: _selectedStatus,
                        isExpanded: true,
                        underline: Container(),
                        items: _statuses.map((status) {
                          return DropdownMenuItem(
                            value: status,
                            child: Text(
                              status,
                              style: const TextStyle(fontSize: 13),
                            ),
                          );
                        }).toList(),
                        onChanged: (value) {
                          setState(() {
                            _selectedStatus = value!;
                          });
                        },
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 16),
              
              // Sort Dropdown
              Expanded(
                child: Row(
                  children: [
                    Icon(Icons.sort, size: 16, color: Theme.of(context).textTheme.bodyMedium?.color),
                    const SizedBox(width: 8),
                    Expanded(
                      child: DropdownButton<String>(
                        value: _selectedSort,
                        isExpanded: true,
                        underline: Container(),
                        items: _sortOptions.map((sort) {
                          return DropdownMenuItem(
                            value: sort,
                            child: Text(
                              sort,
                              style: const TextStyle(fontSize: 13),
                            ),
                          );
                        }).toList(),
                        onChanged: (value) {
                          setState(() {
                            _selectedSort = value!;
                          });
                        },
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildIncidentsList({required bool myReportsOnly}) {
    return RefreshIndicator(
      onRefresh: () async {
        setState(() {});
        await Future.delayed(const Duration(seconds: 1));
      },
      child: StreamBuilder<List<Incident>>(
        stream: FirestoreService().getAllIncidents(limit: 100),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return _buildEmptyState(myReportsOnly);
          }

          final filteredIncidents = _filterAndSortIncidents(
            snapshot.data!,
            myReportsOnly: myReportsOnly,
          );

          if (filteredIncidents.isEmpty) {
            return _buildNoResultsState();
          }

          final groupedIncidents = _groupByTime(filteredIncidents);

          return ListView(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            children: [
              // Today
              if (groupedIncidents['Today']!.isNotEmpty) ...[
                _buildSectionHeader('Today', groupedIncidents['Today']!.length),
                ...groupedIncidents['Today']!.map((inc) => _buildIncidentCard(inc)),
              ],
              
              // Yesterday
              if (groupedIncidents['Yesterday']!.isNotEmpty) ...[
                _buildSectionHeader('Yesterday', groupedIncidents['Yesterday']!.length),
                ...groupedIncidents['Yesterday']!.map((inc) => _buildIncidentCard(inc)),
              ],
              
              // This Week
              if (groupedIncidents['This Week']!.isNotEmpty) ...[
                _buildSectionHeader('This Week', groupedIncidents['This Week']!.length),
                ...groupedIncidents['This Week']!.map((inc) => _buildIncidentCard(inc)),
              ],
              
              // Older
              if (groupedIncidents['Older']!.isNotEmpty) ...[
                _buildSectionHeader('Older', groupedIncidents['Older']!.length),
                ...groupedIncidents['Older']!.map((inc) => _buildIncidentCard(inc)),
              ],
            ],
          );
        },
      ),
    );
  }

  Widget _buildSectionHeader(String title, int count) {
    return Padding(
      padding: const EdgeInsets.only(top: 16, bottom: 8),
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

  Widget _buildIncidentCard(Incident inc) {
    return FutureBuilder<model.User>(
      future: FirestoreService().getUser(inc.userId),
      builder: (context, userSnapshot) {
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
            badge: inc.resolved ? "Resolved" : (inc.verified ? "Verified" : "Unverified"),
            badgeColor: inc.resolved ? AppColors.safetyBlue : (inc.verified ? AppColors.successGreen : AppColors.alertRed),
            onTap: () => Navigator.pushNamed(
              context,
              '/details',
              arguments: inc,
            ),
          ),
        );
      },
    );
  }

  Widget _buildEmptyState(bool myReportsOnly) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            myReportsOnly ? Icons.report_off : Icons.history,
            size: 80,
            color: Theme.of(context).iconTheme.color?.withOpacity(0.3),
          ),
          const SizedBox(height: 16),
          Text(
            myReportsOnly ? 'No reports yet' : 'No incidents reported',
            style: TextStyle(
              color: Theme.of(context).textTheme.bodyLarge?.color,
              fontSize: 18,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            myReportsOnly
                ? 'You haven\'t reported any incidents yet'
                : 'No incidents have been reported in your area',
            style: TextStyle(
              color: Theme.of(context).textTheme.bodyMedium?.color,
              fontSize: 14,
            ),
          ),
          if (myReportsOnly) ...[
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: () {
                Navigator.pushNamed(context, '/report');
              },
              icon: const Icon(Icons.add, color: Colors.white),
              label: const Text(
                'Report Incident',
                style: TextStyle(color: Colors.white),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.safetyBlue,
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ],
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
            Icons.search_off,
            size: 60,
            color: Theme.of(context).iconTheme.color?.withOpacity(0.3),
          ),
          const SizedBox(height: 16),
          Text(
            'No matching incidents',
            style: TextStyle(
              color: Theme.of(context).textTheme.bodyLarge?.color,
              fontSize: 16,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Try adjusting your filters',
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