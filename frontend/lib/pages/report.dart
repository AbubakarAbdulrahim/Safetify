import 'dart:io';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:geocoding/geocoding.dart' hide Location;
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import 'package:location/location.dart';
import '../constants.dart';
import '../models/incidents.dart';
import '../services/firestore_service.dart';
import '../services/cloudinary_service.dart';


class ReportPage extends StatefulWidget {
  const ReportPage({super.key});

  @override
  _ReportPageState createState() => _ReportPageState();
}

class _ReportPageState extends State<ReportPage> {
  final TextEditingController _descController = TextEditingController();
  final FirestoreService _firestore = FirestoreService();
  final ImagePicker _picker = ImagePicker();

  String _category = 'Insecurity';
  File? _photo;
  double? _lat, _lon;
  String _locationName = "Current Location";
  bool _loading = false;

  final List<Map<String, dynamic>> _categories = [
    {'label': 'Insecurity', 'icon': Icons.health_and_safety},
    {'label': 'Fire', 'icon': Icons.local_fire_department_rounded},
    {'label': 'Traffic', 'icon': Icons.directions_car_rounded},
    {'label': 'Waste', 'icon': Icons.delete_rounded},
    {'label': 'Flood', 'icon': Icons.water_rounded},
    {'label': 'Blockage', 'icon': Icons.block_rounded},
    {'label': 'Other', 'icon': Icons.report_problem_rounded},
  ];
  
  bool _isLocating = false;

  //pick photo

  Future<void> _takePhoto() async {
    try {
      final picked = await _picker.pickImage(
        source: ImageSource.camera,
        imageQuality: 70,
        maxWidth: 1024,
      );
      if (picked != null) setState(() => _photo = File(picked.path));
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Failed to open camera")),
      );
    }
  }

  //detect location

  Future<void> _getLocationName() async {
    setState(() {
      _isLocating = true;
    });

    try {
      Location location = Location();

      bool enabled = await location.serviceEnabled();
      if (!enabled) enabled = await location.requestService();

      PermissionStatus permission = await location.hasPermission();
      if (permission == PermissionStatus.denied) {
        permission = await location.requestPermission();
      }

      if (permission == PermissionStatus.granted) {
        final loc = await location.getLocation();
        final locName = await _getLocationNameFromCoordinates(loc.latitude!, loc.longitude!);
        setState(() {
          _lat = loc.latitude;
          _lon = loc.longitude;
          _locationName = locName;
        });
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Location permission denied")),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Unable to get location")),
      );
    }
  }

  Future<String> _getLocationNameFromCoordinates(double lat, double lon) async {
    try {
      final placemarks = await placemarkFromCoordinates(lat, lon);
      if (placemarks.isNotEmpty) {
        final place = placemarks.first;
        return '${place.street ?? ''}, ${place.locality ?? ''}, ${place.administrativeArea ?? ''}'
            .replaceAll(RegExp(r',\s*(?=,)'), '')
            .trim();
      }
    } catch (e) {
      print('Error fetching location name: $e');
    }
    return 'Unknown location';
  }

  //submit report handler

  Future<void> _submit() async {
    if (_loading) return;

    if (_lat == null || _lon == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please detect your current location")),
      );
      return;
    }

    setState(() => _loading = true);

    try {
      // Upload photo if exists
      String? photoUrl = '';
      if (_photo != null) {
        photoUrl = await CloudinaryService.uploadIncidentImage(_photo!);
      }


      // String photoUrl = await _storage.uploadIncidentImage(
      //   "incidents/${DateTime.now().millisecondsSinceEpoch}.jpg",
      //   _photo!,
      // );

      

      // Get geo-location name
      String locationName = await _getLocationNameFromCoordinates(_lat!, _lon!);

      // Create incident
      final incident = Incident(
        id: '',
        category: _category,
        description: _descController.text.trim(),
        lat: _lat!,
        lon: _lon!,
        locationName: locationName,
        photoUrl: photoUrl ?? '',
        userId: FirebaseAuth.instance.currentUser!.uid,
        createdAt: DateTime.now(),
      );

      // save incident
      await _firestore.createIncident(incident);

      setState(() => _loading = false);

      await showDialog(
        context: context,
        builder: (_) => AlertDialog(
          title: Row(
            children: const [
              Icon(Icons.check_circle, color: AppColors.successGreen),
              SizedBox(width: 8),
              Text("Reported Successfully"),
            ],
          ),
          content: const Text(
            "Your report has been sent to nearby users and authorities.",
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text("Done"),
            ),
          ],
        ),
      );

      Navigator.pop(context);

    } catch (e) {
      setState(() => _loading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Failed to submit report: $e")),
      );
    }
  }

  @override
  void dispose() {
    _descController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bg,
      appBar: AppBar(
        title: const Text("Report Incident"),
        leading: const BackButton(),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [

              // category selecttor

              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: _categories.map((c) {
                    final label = c['label'] as String;
                    final icon = c['icon'] as IconData;
                    final selected = label == _category;

                    return GestureDetector(
                      onTap: () => setState(() => _category = label),
                      child: Container(
                        margin: const EdgeInsets.only(right: 12),
                        padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 14),
                        decoration: BoxDecoration(
                          color: selected
                              ? AppColors.safetyBlue.withOpacity(0.1)
                              : AppColors.card,
                          borderRadius: BorderRadius.circular(12),
                          border: selected
                              ? Border.all(color: AppColors.safetyBlue.withOpacity(0.18))
                              : null,
                        ),
                        child: Column(
                          children: [
                            Icon(icon, color: selected ? AppColors.safetyBlue : Colors.grey[700]),
                            const SizedBox(height: 6),
                            Text(label, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600)),
                          ],
                        ),
                      ),
                    );
                  }).toList(),
                ),
              ),

              const SizedBox(height: 18),

              // photo picker
              GestureDetector(
                onTap: _takePhoto,
                child: _photo == null
                    ? const DottedAddPhoto()
                    : ClipRRect(
                        borderRadius: BorderRadius.circular(12),
                        child: Image.file(
                          _photo!,
                          height: 190,
                          width: double.infinity,
                          fit: BoxFit.cover,
                        ),
                      ),
              ),

              const SizedBox(height: 12),

              // location detector
              // ListTile(
              //   contentPadding: EdgeInsets.zero,
              //   leading: Icon(Icons.location_on_rounded, color: AppColors.safetyBlue),
              //   title: Text(
              //     _locationName,
              //     style: GoogleFonts.inter(fontSize: 16, fontWeight: FontWeight.w500),
              //   ),
              //   subtitle: Text(
              //     _lat == null ? "Tap the icon to get your location" : "Auto-detected",
              //     style: GoogleFonts.inter(fontSize: 14),
              //   ),
              //   trailing: ElevatedButton(
              //     onPressed: _getLocationName,
              //     style: ElevatedButton.styleFrom(
              //       backgroundColor: AppColors.safetyBlue,
              //       padding: const EdgeInsets.all(10),
              //       shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              //     ),
              //     child: const Icon(Icons.my_location_rounded, size: 22, color: Colors.white),
              //   ),
              // ),
              ListTile(
  contentPadding: EdgeInsets.zero,
  leading: Icon(Icons.location_on_sharp, color: AppColors.safetyBlue),
  title: Text(
    _locationName,
    style: GoogleFonts.inter(fontSize: 16, fontWeight: FontWeight.w500),
  ),
  subtitle: Text(
    _lat == null ? "Tap to get your current location" : "Auto-detected",
    style: GoogleFonts.inter(fontSize: 14),
  ),
  trailing: ElevatedButton(
    // 1. If locating, disable the button (null) so they can't spam click
    onPressed: _isLocating 
        ? null 
        : () async {
            // Start Loader
            setState(() {
              _isLocating = true;
            });

            // Wait for your existing function to finish
            await _getLocationName();

            // Stop Loader
            setState(() {
              _isLocating = false;
            });
          },
    style: ElevatedButton.styleFrom(
      backgroundColor: AppColors.safetyBlue,
      // Ensure button looks active even when disabled (optional preference)
      disabledBackgroundColor: AppColors.safetyBlue.withOpacity(0.8),
      padding: const EdgeInsets.all(10),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
    ),
    // 2. Swap the Icon with a Spinner based on state
    child: _isLocating
        ? const SizedBox(
            height: 22,
            width: 22,
            child: CircularProgressIndicator(
              color: Colors.white,
              strokeWidth: 2.5, // Keep it thin to look elegant
            ),
          )
        : const Icon(Icons.my_location_rounded, size: 22, color: Colors.white),
  ),
),

              const SizedBox(height: 12),

              TextField(
                controller: _descController,
                minLines: 3,
                maxLines: 6,
                decoration: const InputDecoration(
                  hintText: "Describe the incident (optional)",
                ),
                style: GoogleFonts.inter(fontSize: 16),
              ),

              const SizedBox(height: 20),

              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  onPressed: _loading ? null : _submit,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.safetyBlue,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    disabledBackgroundColor: AppColors.safetyBlue.withOpacity(0.8),
                  ),
                  child: _loading
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                        )
                      : const Text(
                          "Submit Report",
                          style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.w600),
                        ),
                ),
              ),

              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }
}

// add photo widget

class DottedAddPhoto extends StatelessWidget {
  const DottedAddPhoto({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 170,
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey[300]!),
      ),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.camera_alt_rounded, size: 36, color: Colors.grey[500]),
            const SizedBox(height: 8),
            Text(
              "Add Photo\n(optional)",
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.grey[700], fontWeight: FontWeight.w600),
            ),
          ],
        ),
      ),
    );
  }
}
