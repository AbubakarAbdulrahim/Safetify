import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:safetify/models/incidents.dart';
import 'package:safetify/services/firestore_service.dart';
import 'package:share_plus/share_plus.dart';
import 'package:intl/intl.dart';
import '../constants.dart';

class AnalyticsPage extends StatefulWidget {
  const AnalyticsPage({super.key});

  @override
  State<AnalyticsPage> createState() => _AnalyticsPageState();
}

class _AnalyticsPageState extends State<AnalyticsPage> {
  String _filter = 'Monthly';
  int _touchedIndex = -1;
  DateTime? _startDate;
  DateTime? _endDate;
  List<Incident> _previousPeriodIncidents = [];

  @override
  void initState() {
    super.initState();
    _setDefaultDateRange();
  }

  void _setDefaultDateRange() {
    final now = DateTime.now();
    switch (_filter) {
      case 'Daily':
        _startDate = DateTime(now.year, now.month, now.day);
        _endDate = now;
        break;
      case 'Monthly':
        _startDate = DateTime(now.year, now.month, 1);
        _endDate = now;
        break;
      case 'Yearly':
        _startDate = DateTime(now.year, 1, 1);
        _endDate = now;
        break;
    }
  }

  Future<void> _selectDateRange() async {
    final DateTimeRange? picked = await showDateRangePicker(
      context: context,
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
      initialDateRange: DateTimeRange(
        start: _startDate ?? DateTime.now().subtract(const Duration(days: 30)),
        end: _endDate ?? DateTime.now(),
      ),
    );
    if (picked != null) {
      setState(() {
        _startDate = picked.start;
        _endDate = picked.end;
        _filter = 'Custom';
      });
    }
  }

  void _shareAnalytics(List<Incident> incidents) {
    final total = incidents.length;
    final verified = incidents.where((i) => i.verified).length;
    final resolved = incidents.where((i) => i.resolved).length;
    final categories = _getCategoryCounts(incidents);
    
    String report = '📊 Safetify Analytics Report\n\n';
    report += '📅 Period: ${DateFormat('MMM d, y').format(_startDate!)} - ${DateFormat('MMM d, y').format(_endDate!)}\n\n';
    report += '📈 Summary:\n';
    report += '• Total Incidents: $total\n';
    report += '• Verified: $verified\n';
    report += '• Resolved: $resolved\n';
    report += '• Unverified: ${total - verified}\n\n';
    report += '📊 By Category:\n';
    categories.forEach((cat, count) {
      report += '• $cat: $count\n';
    });
    report += '\n🛡️ Stay safe with Safetify!';
    
    Share.share(report);
  }

  Map<String, int> _getCategoryCounts(List<Incident> incidents) {
    final Map<String, int> counts = {};
    for (var incident in incidents) {
      counts[incident.category] = (counts[incident.category] ?? 0) + 1;
    }
    return counts;
  }

  double _calculateGrowthRate(List<Incident> current, List<Incident> previous) {
    if (previous.isEmpty) return 0;
    return ((current.length - previous.length) / previous.length) * 100;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        title: const Text('Analytics'),
        backgroundColor: Theme.of(context).appBarTheme.backgroundColor,
        foregroundColor: Theme.of(context).iconTheme.color,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.date_range),
            onPressed: _selectDateRange,
            tooltip: 'Select Date Range',
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          setState(() {});
          await Future.delayed(const Duration(seconds: 1));
        },
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          physics: const AlwaysScrollableScrollPhysics(),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildFilterTabs(),
              const SizedBox(height: 20),

              StreamBuilder<List<Incident>>(
                stream: FirestoreService().getAnalyticsIncidents(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return _buildLoadingSkeleton();
                  }
                  if (!snapshot.hasData || snapshot.data!.isEmpty) {
                    return _buildEmptyState("No incident data available.");
                  }

                  final allIncidents = snapshot.data!;
                  final filteredIncidents = _filterIncidents(allIncidents);

                  if (filteredIncidents.isEmpty) {
                    return _buildEmptyState("No incidents found for this period.");
                  }

                  // Calculate previous period for comparison
                  _calculatePreviousPeriod(allIncidents);
                  final growthRate = _calculateGrowthRate(filteredIncidents, _previousPeriodIncidents);

                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Date Range Display
                      _buildDateRangeCard(),
                      const SizedBox(height: 16),

                      // Summary Cards with Growth
                      _buildEnhancedSummaryCards(filteredIncidents, growthRate),
                      const SizedBox(height: 24),

                      // Insights Card
                      _buildInsightsCard(filteredIncidents, growthRate),
                      const SizedBox(height: 24),

                      // Trend Line Chart
                      _buildSectionTitle("Incident Trends"),
                      const SizedBox(height: 16),
                      _buildTrendChart(filteredIncidents),
                      const SizedBox(height: 24),

                      // Category Pie Chart
                      _buildSectionTitle("Incidents by Category"),
                      const SizedBox(height: 16),
                      _buildCategoryChart(filteredIncidents),
                      const SizedBox(height: 24),

                      // Location Bar Chart
                      _buildSectionTitle("Top Locations"),
                      const SizedBox(height: 16),
                      _buildLocationBarChart(filteredIncidents),
                      const SizedBox(height: 24),

                      // Peak Hours Heatmap
                      _buildSectionTitle("Peak Hours"),
                      const SizedBox(height: 16),
                      _buildPeakHoursChart(filteredIncidents),
                      const SizedBox(height: 24),

                      // Share Button
                      _buildShareButton(filteredIncidents),
                      const SizedBox(height: 40),
                    ],
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _calculatePreviousPeriod(List<Incident> allIncidents) {
    if (_startDate == null || _endDate == null) return;
    
    final duration = _endDate!.difference(_startDate!);
    final previousStart = _startDate!.subtract(duration);
    final previousEnd = _startDate!;

    _previousPeriodIncidents = allIncidents.where((incident) {
      return incident.createdAt.isAfter(previousStart) &&
             incident.createdAt.isBefore(previousEnd);
    }).toList();
  }

  Widget _buildDateRangeCard() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.safetyBlue.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.safetyBlue.withOpacity(0.3)),
      ),
      child: Row(
        children: [
          Icon(Icons.calendar_today, color: AppColors.safetyBlue, size: 20),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              _startDate != null && _endDate != null
                  ? '${DateFormat('MMM d, y').format(_startDate!)} - ${DateFormat('MMM d, y').format(_endDate!)}'
                  : 'Select date range',
              style: TextStyle(
                color: AppColors.safetyBlue,
                fontWeight: FontWeight.w600,
                fontSize: 14,
              ),
            ),
          ),
          TextButton(
            onPressed: _selectDateRange,
            child: const Text('Change'),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterTabs() {
    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: ['Daily', 'Monthly', 'Yearly', 'Custom'].map((filter) {
          final isSelected = _filter == filter;
          return Expanded(
            child: GestureDetector(
              onTap: () {
                setState(() {
                  _filter = filter;
                  if (filter != 'Custom') {
                    _setDefaultDateRange();
                  } else {
                    _selectDateRange();
                  }
                });
              },
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 12),
                decoration: BoxDecoration(
                  color: isSelected ? AppColors.safetyBlue : Colors.transparent,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  filter,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: isSelected ? Colors.white : Theme.of(context).textTheme.bodyMedium?.color,
                    fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                    fontSize: 13,
                  ),
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildEnhancedSummaryCards(List<Incident> incidents, double growthRate) {
    final total = incidents.length;
    final verified = incidents.where((i) => i.verified).length;
    final resolved = incidents.where((i) => i.resolved).length;
    // final avgResponseTime = "2.5h"; // Placeholder removed
    final resolutionRate = total > 0 ? ((resolved / total) * 100).toStringAsFixed(1) : "0";

    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: _buildMetricCard(
                'Total Incidents',
                '$total',
                Icons.warning_amber_rounded,
                AppColors.safetyBlue,
                growthRate,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildMetricCard(
                'Verified',
                '$verified',
                Icons.verified,
                AppColors.successGreen,
                null,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: _buildMetricCard(
                'Resolved',
                '$resolved',
                Icons.check_circle_outline,
                AppColors.safetyBlue,
                null,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildMetricCard(
                'Resolution Rate',
                '$resolutionRate%',
                Icons.check_circle,
                AppColors.successGreen,
                null,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildMetricCard(String title, String value, IconData icon, Color color, double? growth) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(12),
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
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Icon(icon, color: color, size: 24),
              if (growth != null)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                  decoration: BoxDecoration(
                    color: growth >= 0 ? Colors.red.withOpacity(0.1) : Colors.green.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        growth >= 0 ? Icons.arrow_upward : Icons.arrow_downward,
                        size: 12,
                        color: growth >= 0 ? Colors.red : Colors.green,
                      ),
                      const SizedBox(width: 2),
                      Text(
                        '${growth.abs().toStringAsFixed(1)}%',
                        style: TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                          color: growth >= 0 ? Colors.red : Colors.green,
                        ),
                      ),
                    ],
                  ),
                ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            value,
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Theme.of(context).textTheme.bodyLarge?.color,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            title,
            style: TextStyle(
              fontSize: 12,
              color: Theme.of(context).textTheme.bodyMedium?.color,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInsightsCard(List<Incident> incidents, double growthRate) {
    final mostCommonCategory = _getMostCommonCategory(incidents);
    final peakHour = _getPeakHour(incidents);
    
    String insight = "";
    IconData insightIcon = Icons.lightbulb;
    Color insightColor = AppColors.amber;

    if (growthRate > 20) {
      insight = "⚠️ Incidents increased by ${growthRate.toStringAsFixed(1)}% compared to the previous period. Stay vigilant!";
      insightColor = AppColors.alertRed;
      insightIcon = Icons.trending_up;
    } else if (growthRate < -20) {
      insight = "✅ Great news! Incidents decreased by ${growthRate.abs().toStringAsFixed(1)}%. Your area is getting safer!";
      insightColor = AppColors.successGreen;
      insightIcon = Icons.trending_down;
    } else {
      insight = "📊 Most incidents are reported as '$mostCommonCategory'. Peak reporting time is around $peakHour.";
    }

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [insightColor.withOpacity(0.1), insightColor.withOpacity(0.05)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: insightColor.withOpacity(0.3)),
      ),
      child: Row(
        children: [
          Icon(insightIcon, color: insightColor, size: 28),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'AI Insight',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: insightColor,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  insight,
                  style: TextStyle(
                    fontSize: 13,
                    color: Theme.of(context).textTheme.bodyMedium?.color,
                    height: 1.4,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  String _getMostCommonCategory(List<Incident> incidents) {
    if (incidents.isEmpty) return "None";
    final counts = _getCategoryCounts(incidents);
    return counts.entries.reduce((a, b) => a.value > b.value ? a : b).key;
  }

  String _getPeakHour(List<Incident> incidents) {
    if (incidents.isEmpty) return "N/A";
    final hourCounts = <int, int>{};
    for (var incident in incidents) {
      final hour = incident.createdAt.hour;
      hourCounts[hour] = (hourCounts[hour] ?? 0) + 1;
    }
    final peakHour = hourCounts.entries.reduce((a, b) => a.value > b.value ? a : b).key;
    return '${peakHour}:00';
  }

  Widget _buildTrendChart(List<Incident> incidents) {
    final groupedByDate = <DateTime, int>{};
    for (var incident in incidents) {
      final date = DateTime(incident.createdAt.year, incident.createdAt.month, incident.createdAt.day);
      groupedByDate[date] = (groupedByDate[date] ?? 0) + 1;
    }

    final sortedDates = groupedByDate.keys.toList()..sort();
    final spots = sortedDates.asMap().entries.map((entry) {
      return FlSpot(entry.key.toDouble(), groupedByDate[entry.value]!.toDouble());
    }).toList();

    if (spots.isEmpty) {
      return const SizedBox(height: 200, child: Center(child: Text('No data')));
    }

    return Container(
      height: 200,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: LineChart(
        LineChartData(
          gridData: FlGridData(show: true, drawVerticalLine: false),
          titlesData: FlTitlesData(
            leftTitles: AxisTitles(sideTitles: SideTitles(showTitles: true, reservedSize: 30)),
            bottomTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
            topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
            rightTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
          ),
          borderData: FlBorderData(show: false),
          lineBarsData: [
            LineChartBarData(
              spots: spots,
              isCurved: true,
              color: AppColors.safetyBlue,
              barWidth: 3,
              dotData: FlDotData(show: true),
              belowBarData: BarAreaData(
                show: true,
                color: AppColors.safetyBlue.withOpacity(0.1),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCategoryChart(List<Incident> incidents) {
    final categoryCounts = _getCategoryCounts(incidents);
    final colors = [
      AppColors.alertRed,
      Colors.orange,
      AppColors.safetyBlue,
      AppColors.successGreen,
      Colors.purple,
      AppColors.amber,
      Colors.pink,
      Colors.teal,
    ];

    final sections = categoryCounts.entries.toList().asMap().entries.map((entry) {
      final index = entry.key;
      final category = entry.value;
      final isTouched = index == _touchedIndex;
      final radius = isTouched ? 110.0 : 100.0;

      return PieChartSectionData(
        color: colors[index % colors.length],
        value: category.value.toDouble(),
        title: '${category.value}',
        radius: radius,
        titleStyle: const TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.bold,
          color: Colors.white,
        ),
      );
    }).toList();

    return Container(
      height: 250,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(12),
        border: Theme.of(context).brightness == Brightness.dark
            ? Border.all(color: Colors.white.withOpacity(0.1))
            : null,
        boxShadow: Theme.of(context).brightness == Brightness.dark
            ? [
                BoxShadow(
                  color: Colors.white.withOpacity(0.05),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ]
            : [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
      ),
      child: Row(
        children: [
          Expanded(
            flex: 2,
            child: PieChart(
              PieChartData(
                sections: sections,
                sectionsSpace: 2,
                centerSpaceRadius: 40,
                pieTouchData: PieTouchData(
                  touchCallback: (FlTouchEvent event, pieTouchResponse) {
                    setState(() {
                      if (!event.isInterestedForInteractions ||
                          pieTouchResponse == null ||
                          pieTouchResponse.touchedSection == null) {
                        _touchedIndex = -1;
                        return;
                      }
                      _touchedIndex = pieTouchResponse.touchedSection!.touchedSectionIndex;
                    });
                  },
                ),
              ),
            ),
          ),
          Expanded(
            child: SingleChildScrollView(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: categoryCounts.entries.toList().asMap().entries.map((entry) {
                  final index = entry.key;
                  final category = entry.value;
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 8),
                    child: Row(
                      children: [
                        Container(
                          width: 12,
                          height: 12,
                          decoration: BoxDecoration(
                            color: colors[index % colors.length],
                            shape: BoxShape.circle,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            category.key,
                            style: TextStyle(
                              fontSize: 11,
                              color: Theme.of(context).textTheme.bodyMedium?.color,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                  );
                }).toList(),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLocationBarChart(List<Incident> incidents) {
    final locationCounts = <String, int>{};
    for (var incident in incidents) {
      final location = incident.locationName.split(',').first.trim();
      locationCounts[location] = (locationCounts[location] ?? 0) + 1;
    }

    final sortedLocations = locationCounts.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));
    final topLocations = sortedLocations.take(5).toList();

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: topLocations.map((location) {
          final percentage = (location.value / incidents.length) * 100;
          return Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Text(
                        location.key,
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: Theme.of(context).textTheme.bodyLarge?.color,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    Text(
                      '${location.value} (${percentage.toStringAsFixed(1)}%)',
                      style: TextStyle(
                        fontSize: 12,
                        color: Theme.of(context).textTheme.bodyMedium?.color,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                ClipRRect(
                  borderRadius: BorderRadius.circular(4),
                  child: LinearProgressIndicator(
                    value: percentage / 100,
                    backgroundColor: Theme.of(context).dividerColor,
                    valueColor: AlwaysStoppedAnimation<Color>(AppColors.safetyBlue),
                    minHeight: 8,
                  ),
                ),
              ],
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildPeakHoursChart(List<Incident> incidents) {
    final hourCounts = List.generate(24, (index) => 0);
    for (var incident in incidents) {
      hourCounts[incident.createdAt.hour]++;
    }

    final maxCount = hourCounts.reduce((a, b) => a > b ? a : b);

    return Container(
      height: 120,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: List.generate(24, (hour) {
          final count = hourCounts[hour];
          final height = maxCount > 0 ? (count / maxCount) * 80 : 0.0;
          final intensity = maxCount > 0 ? count / maxCount : 0.0;
          
          return Tooltip(
            message: '$hour:00 - $count incidents',
            child: Container(
              width: 8,
              height: height,
              decoration: BoxDecoration(
                color: AppColors.safetyBlue.withOpacity(0.3 + (intensity * 0.7)),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          );
        }),
      ),
    );
  }

  Widget _buildShareButton(List<Incident> incidents) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton.icon(
        onPressed: () => _shareAnalytics(incidents),
        icon: const Icon(Icons.share, color: Colors.white),
        label: const Text(
          'Share Analytics Report',
          style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold),
        ),
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.safetyBlue,
          padding: const EdgeInsets.symmetric(vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: TextStyle(
        fontSize: 18,
        fontWeight: FontWeight.bold,
        color: Theme.of(context).textTheme.bodyLarge?.color,
      ),
    );
  }

  Widget _buildEmptyState(String message) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.analytics_outlined,
            size: 80,
            color: Theme.of(context).iconTheme.color?.withOpacity(0.3),
          ),
          const SizedBox(height: 16),
          Text(
            message,
            style: TextStyle(
              color: Theme.of(context).textTheme.bodyMedium?.color,
              fontSize: 16,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLoadingSkeleton() {
    return Column(
      children: List.generate(3, (index) {
        return Container(
          margin: const EdgeInsets.only(bottom: 16),
          height: 100,
          decoration: BoxDecoration(
            color: Colors.grey.withOpacity(0.2),
            borderRadius: BorderRadius.circular(12),
          ),
        );
      }),
    );
  }

  List<Incident> _filterIncidents(List<Incident> incidents) {
    if (_startDate == null || _endDate == null) return incidents;
    
    return incidents.where((incident) {
      return incident.createdAt.isAfter(_startDate!) &&
             incident.createdAt.isBefore(_endDate!.add(const Duration(days: 1)));
    }).toList();
  }
}
