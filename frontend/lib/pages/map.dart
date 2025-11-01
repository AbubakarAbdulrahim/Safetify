// import 'package:flutter/material.dart';
// import 'package:google_maps_flutter/google_maps_flutter.dart';
// import '../constants.dart';
// import '../widgets/incident_card.dart';

// class MapPage extends StatefulWidget {
//   const MapPage({super.key});

//   @override
//   _MapPageState createState() => _MapPageState();
// }

// class _MapPageState extends State<MapPage> {
//   GoogleMapController? _controller;
//   final CameraPosition _initial = CameraPosition(target: LatLng(11.0000, 8.5167), zoom: 12); // Kano center example
//   final Set<Marker> _markers = {};

//   @override
//   void initState() {
//     super.initState();
//     // Add sample markers (in production populate from API)
//     _markers.addAll([
//       Marker(markerId: MarkerId('fire1'), position: LatLng(11.008, 8.510), icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueRed)),
//       Marker(markerId: MarkerId('insec1'), position: LatLng(11.012, 8.520), icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueBlue)),
//       Marker(markerId: MarkerId('flood1'), position: LatLng(11.015, 8.505), icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueOrange)),
//     ]);
//   }

//   void _onMarkerTap(String id) {
//     // open bottom sheet for details
//     showModalBottomSheet(context: context, builder: (_) => Container(
//       padding: EdgeInsets.all(16),
//       child: Column(mainAxisSize: MainAxisSize.min, children: [
//         IncidentCard(title: 'Fire outbreak near Sabon Gari', subtitle: 'Unverified • 15 mins ago'),
//         SizedBox(height: 10),
//         ElevatedButton(onPressed: () => Navigator.pushNamed(context, '/analytics'), child: Text('View Details'))
//       ]),
//     ));
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(title: Text('Incident Map'), leading: BackButton()),
//       body: Stack(children: [
//         GoogleMap(
//           initialCameraPosition: _initial,
//           markers: _markers.map((m) {
//             return m.copyWith(onTapParam: () => _onMarkerTap(m.markerId.value));
//           }).toSet(),
//           onMapCreated: (c) => _controller = c,
//           myLocationEnabled: true,
//         ),
//         Positioned(
//           right: 16, top: 16,
//           child: FloatingActionButton(
//             mini: true,
//             backgroundColor: AppColors.card,
//             onPressed: () => _controller?.animateCamera(CameraUpdate.newCameraPosition(_initial)),
//             child: Icon(Icons.my_location_rounded, color: AppColors.safetyBlue),
//           ),
//         ),
//       ]),
//     );
//   }
// }



// /lib/pages/map.dart

import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import '../constants.dart';
import '../widgets/incident_card.dart';

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
      color: Colors.orange,
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
            IncidentCard(title: marker.title, subtitle: marker.subtitle),
            const SizedBox(height: 10),
            ElevatedButton(
              onPressed: () => Navigator.pushNamed(context, '/analytics'),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.card,
                foregroundColor: AppColors.safetyBlue,
              ),
              child: const Text('View Details'),
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
                    width: 40,
                    height: 40,
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
