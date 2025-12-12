import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:safetify/models/incidents.dart';
import 'package:safetify/services/firestore_service.dart';
import 'package:timeago/timeago.dart' as timeago;
import 'package:geolocator/geolocator.dart';
import '../constants.dart';

class MapPage extends StatefulWidget {
  const MapPage({super.key});

  @override
  State<MapPage> createState() => _MapPageState();
}

class _MapPageState extends State<MapPage> {
  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final args = ModalRoute.of(context)?.settings.arguments;
    if (args is Incident) {
      // If an incident is passed, move camera to it
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _mapController.move(LatLng(args.lat, args.lon), 15.0);
        // Optionally open the modal immediately
        _onMarkerTap(args);
      });
    }
  }
  final MapController _mapController = MapController();
  final LatLng _initialCenter = LatLng(12.0022, 8.5920); // Kano center
  final double _initialZoom = 13.0;
  bool _isLoadingLocation = false;

  Future<void> _getCurrentLocation() async {
    setState(() => _isLoadingLocation = true);
    try {
      bool serviceEnabled;
      LocationPermission permission;

      // Test if location services are enabled.
      serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        throw 'Location services are disabled.';
      }

      permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          throw 'Location permissions are denied';
        }
      }

      if (permission == LocationPermission.deniedForever) {
        throw 'Location permissions are permanently denied';
      }

      // position of the device.
      final position = await Geolocator.getCurrentPosition(
        timeLimit: const Duration(seconds: 10),
      );
      
      _mapController.move(LatLng(position.latitude, position.longitude), 15.0);
    } catch (e) {
      debugPrint(e.toString());
    } finally {
      if (mounted) {
        setState(() => _isLoadingLocation = false);
      }
    }
  }

  void _onMarkerTap(Incident incident) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Theme.of(context).cardColor,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) => Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  _getCategoryIcon(incident.category),
                  color: _getCategoryColor(incident.category),
                  size: 28,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        incident.category,
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Theme.of(context).textTheme.bodyLarge?.color,
                        ),
                      ),
                      Text(
                        timeago.format(incident.createdAt),
                        style: TextStyle(
                          fontSize: 12,
                          color: Theme.of(context).textTheme.bodyMedium?.color,
                        ),
                      ),
                    ],
                  ),
                ),
                if (incident.resolved)
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: AppColors.safetyBlue.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Text(
                      "Resolved",
                      style: TextStyle(
                        color: AppColors.safetyBlue,
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  )
                else if (incident.verified)
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: AppColors.successGreen.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Text(
                      "Verified",
                      style: TextStyle(
                        color: AppColors.successGreen,
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 16),
            Text(
              incident.description,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                color: Theme.of(context).textTheme.bodyMedium?.color,
              ),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Icon(Icons.location_on, size: 16, color: Theme.of(context).iconTheme.color?.withOpacity(0.7)),
                const SizedBox(width: 4),
                Expanded(
                  child: Text(
                    incident.locationName,
                    style: TextStyle(
                      fontSize: 12,
                      color: Theme.of(context).textTheme.bodyMedium?.color,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                onPressed: () {
                  Navigator.pop(context); // Close modal
                  Navigator.pushNamed(
                    context,
                    '/details',
                    arguments: incident, // Pass the incident object
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.safetyBlue,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                child: const Text(
                  'View Details',
                  style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w600),
                ),
              ),
            ),
            const SizedBox(height: 10),
          ],
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
    return Icons.report_problem_rounded;
  }

  Color _getCategoryColor(String category) {
    final cat = category.toLowerCase();
    if (cat.contains('insecurity')) return Colors.red;
    if (cat.contains('fire')) return Colors.deepOrange;
    if (cat.contains('traffic')) return Colors.blue;
    if (cat.contains('waste')) return Colors.brown;
    if (cat.contains('flood')) return Colors.lightBlue;
    if (cat.contains('blockage')) return Colors.purple;
    if (cat.contains('accident')) return Colors.orange;
    if (cat.contains('ambulance') || cat.contains('medical')) return Colors.green;
    if (cat.contains('other')) return Colors.redAccent;
    return Colors.redAccent;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Live Incident Map'),
        backgroundColor: Theme.of(context).appBarTheme.backgroundColor,
        foregroundColor: Theme.of(context).iconTheme.color,
      ),
      body: StreamBuilder<List<Incident>>(
        stream: FirestoreService().getAllIncidents(limit: 50),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return Center(child: Text('Error loading map data: ${snapshot.error}'));
          }

          final incidents = snapshot.data ?? [];

          return Stack(
            children: [
              FlutterMap(
                mapController: _mapController,
                options: MapOptions(
                  initialCenter: _initialCenter,
                  initialZoom: _initialZoom,
                  interactionOptions: const InteractionOptions(
                    flags: InteractiveFlag.all,
                  ),
                ),
                children: [
                  TileLayer(
                    urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                    userAgentPackageName: 'com.safetify.app',
                  ),
                  MarkerLayer(
                    markers: incidents.map((incident) {
                      return Marker(
                        point: LatLng(incident.lat, incident.lon),
                        width: 40,
                        height: 40,
                        child: GestureDetector(
                          onTap: () => _onMarkerTap(incident),
                          child: Container(
                            decoration: BoxDecoration(
                              color: Colors.white,
                              shape: BoxShape.circle,
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.2),
                                  blurRadius: 6,
                                  offset: const Offset(0, 3),
                                ),
                              ],
                              border: Border.all(
                                color: _getCategoryColor(incident.category),
                                width: 2,
                              ),
                            ),
                            child: Icon(
                              _getCategoryIcon(incident.category),
                              color: _getCategoryColor(incident.category),
                              size: 24,
                            ),
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                  RichAttributionWidget(
                    attributions: [
                      TextSourceAttribution(
                        'OpenStreetMap contributors',
                        onTap: () {},
                      ),
                    ],
                  ),
                ],
              ),
              Positioned(
                right: 16,
                top: 16,
                child: FloatingActionButton(
                  mini: true,
                  backgroundColor: Theme.of(context).cardColor,
                  onPressed: _getCurrentLocation,
                  child: Icon(Icons.my_location_rounded, color: AppColors.safetyBlue),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
