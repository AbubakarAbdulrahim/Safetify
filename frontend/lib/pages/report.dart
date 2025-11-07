// ignore_for_file: sort_child_properties_last

import 'dart:io';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter/material.dart';
import 'package:location/location.dart';
import '../constants.dart';
import 'package:image_picker/image_picker.dart';

class ReportPage extends StatefulWidget {
  const ReportPage({super.key});

  @override
  _ReportPageState createState() => _ReportPageState();
}

class _ReportPageState extends State<ReportPage> {
  final _descController = TextEditingController();
  String _category = 'Insecurity';
  File? _photo;
  double? _lat, _lon;
  bool _loading = false;

  final _categories = [
    {'label': 'Insecurity', 'icon': Icons.security_rounded},
    {'label': 'Fire', 'icon': Icons.local_fire_department_rounded},
    {'label': 'Traffic', 'icon': Icons.directions_car_rounded},
    {'label': 'Waste', 'icon': Icons.delete_rounded},
    {'label': 'Flood', 'icon': Icons.water_rounded},
    {'label': 'Blockage', 'icon': Icons.block_rounded},
    {'label': 'Other', 'icon': Icons.report_problem_rounded},
  ];

  Future _takePhoto() async {
    final picker = ImagePicker();
    final XFile? picked = await picker.pickImage(source: ImageSource.camera, imageQuality: 70);
    if (picked != null) setState(() => _photo = File(picked.path));
  }

  Future _getLocation() async {
    Location location = Location();
    bool serviceEnabled = await location.serviceEnabled();
    if (!serviceEnabled) serviceEnabled = await location.requestService();
    PermissionStatus permissionGranted = await location.hasPermission();
    if (permissionGranted == PermissionStatus.denied) permissionGranted = await location.requestPermission();
    if (permissionGranted == PermissionStatus.granted) {
      final loc = await location.getLocation();
      setState(() {
        _lat = loc.latitude;
        _lon = loc.longitude;
      });
    } else {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Location permission required')));
    }
  }

  Future _submit() async {
    setState(() => _loading = true);
    await Future.delayed(Duration(seconds: 1)); // TODO: replace with real API call
    setState(() => _loading = false);
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: Row(children: [Icon(Icons.check_circle, color: AppColors.successGreen,), SizedBox(width: 8), Text('Reported Successfully')]),
        content: Text('Your report has been sent to nearby users and authorities.'),
        actions: [TextButton(onPressed: () { Navigator.pop(context); Navigator.pop(context); }, child: Text('Done'))],
      ),
    );
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
      appBar: AppBar(title: Text('Report Incident'), leading: BackButton()),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              SizedBox(height: 6),
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
                        margin: EdgeInsets.only(right: 12),
                        padding: EdgeInsets.symmetric(vertical: 10, horizontal: 14),
                        decoration: BoxDecoration(
                          color: selected ? AppColors.safetyBlue.withOpacity(0.1) : AppColors.card,
                          borderRadius: BorderRadius.circular(12),
                          border: selected ? Border.all(color: AppColors.safetyBlue.withOpacity(0.18)) : null,
                        ),
                        child: Column(mainAxisSize: MainAxisSize.min, children: [
                          Icon(icon, color: selected ? AppColors.safetyBlue : Colors.grey[700]),
                          SizedBox(height: 6),
                          Text(label, style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600)),
                        ]),
                      ),
                    );
                  }).toList(),
                ),
              ),
              SizedBox(height: 18),
              GestureDetector(
                onTap: _takePhoto,
                child: _photo == null
                    ? DottedAddPhoto()
                    : ClipRRect(borderRadius: BorderRadius.circular(12), child: Image.file(_photo!, height: 190, fit: BoxFit.cover)),
              ),
              SizedBox(height: 12),
              ListTile(
                contentPadding: EdgeInsets.zero,
                leading: Icon(Icons.location_on_rounded, color: AppColors.safetyBlue),
                title: Text(_lat == null ? 'Current Location' : '$_lat, $_lon', style: GoogleFonts.inter(fontSize: 16, fontWeight: FontWeight.w500,),),
                subtitle: Text(_lat == null ? 'Tap to detect your current location' : 'Auto-detected', style: GoogleFonts.inter(fontSize: 14,),),
                trailing: ElevatedButton(onPressed: _getLocation,
                child: Icon(Icons.my_location_rounded, color: Colors.white, size: 22,),),
              ),
              SizedBox(height: 12),
              TextField(controller: _descController, minLines: 3, maxLines: 6, decoration: InputDecoration(hintText: 'Describe the incident (optional)',), style: GoogleFonts.inter(fontSize: 16, ),),
              SizedBox(height: 20),
              _loading
                  ? Center(child: CircularProgressIndicator())
                  : ElevatedButton(
                      onPressed: _submit,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.safetyBlue,
                        padding: EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                      child: Text(
                        "Submit Report",
                        style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.w600),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class DottedAddPhoto extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      height: 170,
      decoration: BoxDecoration(color: AppColors.card, borderRadius: BorderRadius.circular(12), border: Border.all(color: Colors.grey[200]!)),
      child: Center(
        child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
          Icon(Icons.camera_alt_rounded, size: 36, color: Colors.grey[500]),
          SizedBox(height: 8),
          Text('Add Photo', style: TextStyle(color: Colors.grey[700], fontWeight: FontWeight.w600))
        ]),
      ),
    );
  }
}
