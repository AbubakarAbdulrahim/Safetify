import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import '../constants.dart';
import '../widgets/incident_card.dart';

class MapPage extends StatefulWidget {
  const MapPage({super.key});

  @override
  _MapPageState createState() => _MapPageState();
}

class _MapPageState extends State<MapPage> {
  GoogleMapController? _controller;
  final CameraPosition _initial = CameraPosition(target: LatLng(11.0000, 8.5167), zoom: 12); // Kano center example
  final Set<Marker> _markers = {};

  @override
  void initState() {
    super.initState();
    // Add sample markers (in production populate from API)
    _markers.addAll([
      Marker(markerId: MarkerId('fire1'), position: LatLng(11.008, 8.510), icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueRed)),
      Marker(markerId: MarkerId('insec1'), position: LatLng(11.012, 8.520), icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueBlue)),
      Marker(markerId: MarkerId('flood1'), position: LatLng(11.015, 8.505), icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueOrange)),
    ]);
  }

  void _onMarkerTap(String id) {
    // open bottom sheet for details
    showModalBottomSheet(context: context, builder: (_) => Container(
      padding: EdgeInsets.all(16),
      child: Column(mainAxisSize: MainAxisSize.min, children: [
        IncidentCard(title: 'Fire outbreak near Sabon Gari', subtitle: 'Unverified • 15 mins ago'),
        SizedBox(height: 10),
        ElevatedButton(onPressed: () => Navigator.pushNamed(context, '/analytics'), child: Text('View Details'))
      ]),
    ));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Incident Map'), leading: BackButton()),
      body: Stack(children: [
        GoogleMap(
          initialCameraPosition: _initial,
          markers: _markers.map((m) {
            return m.copyWith(onTapParam: () => _onMarkerTap(m.markerId.value));
          }).toSet(),
          onMapCreated: (c) => _controller = c,
          myLocationEnabled: true,
        ),
        Positioned(
          right: 16, top: 16,
          child: FloatingActionButton(
            mini: true,
            backgroundColor: AppColors.card,
            onPressed: () => _controller?.animateCamera(CameraUpdate.newCameraPosition(_initial)),
            child: Icon(Icons.my_location_rounded, color: AppColors.safetyBlue),
          ),
        ),
      ]),
    );
  }
}