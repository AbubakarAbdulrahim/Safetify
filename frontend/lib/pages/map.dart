// import 'dart:async';
// import 'package:flutter/material.dart';
// import 'package:google_maps_flutter/google_maps_flutter.dart';
// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:location/location.dart';
// import 'package:safetify/constants.dart';
// import 'package:safetify/models/incidents.dart';

// class MapPage extends StatefulWidget {
//   const MapPage({super.key});

//   @override
//   State<MapPage> createState() => _MapPageState();
// }

// class _MapPageState extends State<MapPage> {
//   final Completer<GoogleMapController> _controller = Completer();

//   Location location = Location();
//   LatLng? currentUserPosition;

//   Set<Marker> _markers = {};

//   @override
//   void initState() {
//     super.initState();
//     _enableLocation();
//     _listenForLiveUserLocation();
//     _listenForIncidents();
//   }

//   // ================================
//   // 1. ENABLE LOCATION PERMISSIONS
//   // ================================
//   Future<void> _enableLocation() async {
//     bool serviceEnabled = await location.serviceEnabled();
//     if (!serviceEnabled) {
//       serviceEnabled = await location.requestService();
//       if (!serviceEnabled) return;
//     }

//     PermissionStatus permission = await location.hasPermission();
//     if (permission == PermissionStatus.denied) {
//       permission = await location.requestPermission();
//       if (permission != PermissionStatus.granted) return;
//     }
//   }

//   // ================================
//   // 2. LIVE USER LOCATION TRACKING
//   // ================================
//   void _listenForLiveUserLocation() {
//     location.onLocationChanged.listen((loc) async {
//       if (loc.latitude == null || loc.longitude == null) return;

//       final pos = LatLng(loc.latitude!, loc.longitude!);

//       setState(() {
//         currentUserPosition = pos;

//         // Add/update user marker
//         _markers.removeWhere((m) => m.markerId.value == "USER");
//         _markers.add(
//           Marker(
//             markerId: const MarkerId("USER"),
//             position: pos,
//             icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueBlue),
//             infoWindow: const InfoWindow(title: "You are here"),
//           ),
//         );
//       });

//       // Move camera smoothly
//       final GoogleMapController controller = await _controller.future;
//       controller.animateCamera(
//         CameraUpdate.newLatLng(pos),
//       );
//     });
//   }

//   // ================================
//   // 3. LIVE INCIDENT MARKERS
//   // ================================
//   void _listenForIncidents() {
//     FirebaseFirestore.instance
//         .collection('incidents')
//         .orderBy('createdAt', descending: true)
//         .limit(100)
//         .snapshots()
//         .listen((snapshot) {
//       Set<Marker> newMarkers = {};

//       for (var doc in snapshot.docs) {
//         final incident = Incident.fromDoc(doc);

//         newMarkers.add(
//           Marker(
//             markerId: MarkerId(doc.id),
//             position: LatLng(
//               incident.lat,
//               incident.lon,
//             ),
//             icon: BitmapDescriptor.defaultMarkerWithHue(
//               incident.verified
//                   ? BitmapDescriptor.hueGreen
//                   : BitmapDescriptor.hueRed,
//             ),
//             infoWindow: InfoWindow(
//               title: incident.category,
//               snippet:
//                   "${incident.category.toUpperCase()} • ${incident.locationName}",
//             ),
//           ),
//         );
//       }

//       // Keep user marker
//       if (currentUserPosition != null) {
//         newMarkers.add(
//           Marker(
//             markerId: const MarkerId("USER"),
//             position: currentUserPosition!,
//             icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueBlue),
//           ),
//         );
//       }

//       setState(() => _markers = newMarkers);
//     });
//   }

//   // ================================
//   // MAP UI
//   // ================================
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: const Text("Live Map"),
//         backgroundColor: AppColors.bg,
//       ),
//       body: GoogleMap(
//         initialCameraPosition: const CameraPosition(
//           target: LatLng(9.0820, 8.6753), // Nigeria center
//           zoom: 14,
//         ),
//         myLocationButtonEnabled: true,
//         zoomControlsEnabled: false,
//         markers: _markers,
//         onMapCreated: (controller) => _controller.complete(controller),
//       ),
//     );
//   }
// }


// /lib/pages/map.dart

import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import '../constants.dart';

class MapPage extends StatefulWidget {
  const MapPage({super.key});

  @override
  State<MapPage> createState() => _MapPageState();
}

class _MapPageState extends State<MapPage> {
  final MapController _mapController = MapController();
  final LatLng _initialCenter = LatLng(11.0000, 8.5167);
  final double _initialZoom = 12.0;

  // Simple marker model used only in this page
  final List<_SimpleMarker> _markers = [
    _SimpleMarker(
      id: 'fire1',
      title: 'Fire outbreak near Sabon Gari',
      subtitle: 'Unverified • 15 mins ago',
      location: LatLng(11.008, 8.510),
      color: Colors.red,
    ),
    _SimpleMarker(
      id: 'insec1',
      title: 'Insecurity report',
      subtitle: 'Unverified • 20 mins ago',
      location: LatLng(11.012, 8.520),
      color: Colors.blue,
    ),
    _SimpleMarker(
      id: 'flood1',
      title: 'Flooding reported',
      subtitle: 'Unverified • 45 mins ago',
      location: LatLng(11.015, 8.505),
      color: AppColors.alertRed,
    ),
  ];

  void _onMarkerTap(_SimpleMarker marker) {
    showModalBottomSheet(
      context: context,
      builder: (_) => Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // IncidentCard(title: marker.title, subtitle: marker.subtitle, badge: '',, badgeColor: null,, onTap: () {  },),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () => Navigator.pushNamed(context, '/details'),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.safetyBlue,
                maximumSize: const Size.fromHeight(50),
                    padding: const EdgeInsets.symmetric(vertical: 24),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
              child: const Text('View Details', style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.w600),),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Incident Map'),
        leading: const BackButton(),
      ),
      body: Stack(
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
                userAgentPackageName: 'com.example.safetify',
              ),
              MarkerLayer(
                markers: _markers.map((m) {
                  return Marker(
                    point: m.location,
                    width: 100,
                    height: 100,
                    child: GestureDetector(
                      onTap: () => _onMarkerTap(m),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.location_on_rounded, size: 36, color: m.color),
                          Container(
                            width: 8,
                            height: 8,
                            decoration: BoxDecoration(
                              color: m.color,
                              shape: BoxShape.circle,
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                }).toList(),
              ),
              // Attribution (updated style for flutter_map 7.x)
              RichAttributionWidget(
                attributions: [
                  TextSourceAttribution(
                    '© OpenStreetMap contributors',
                    onTap: null,
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
              backgroundColor: AppColors.card,
              onPressed: () => _mapController.move(_initialCenter, _initialZoom),
              child: Icon(Icons.my_location_rounded, color: AppColors.safetyBlue),
            ),
          ),
        ],
      ),
    );
  }
}

class _SimpleMarker {
  final String id;
  final String title;
  final String subtitle;
  final LatLng location;
  final Color color;

  _SimpleMarker({
    required this.id,
    required this.title,
    required this.subtitle,
    required this.location,
    required this.color,
  });
}
