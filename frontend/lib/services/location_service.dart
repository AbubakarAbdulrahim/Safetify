import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart';

class LocationService {
  static final LocationService _instance = LocationService._internal();
  factory LocationService() => _instance;
  LocationService._internal();

  Future<Position?> getCurrentLocation() async {
    bool serviceEnabled;
    LocationPermission permission;

    // Test if location services are enabled.
    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      return null;
    }

    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        return null;
      }
    }

    if (permission == LocationPermission.deniedForever) {
      return null;
    }

    return await Geolocator.getCurrentPosition();
  }

  double calculateDistance(double startLat, double startLng, double endLat, double endLng) {
    return Geolocator.distanceBetween(startLat, startLng, endLat, endLng) / 1000; // Returns in km
  }

  Future<String> getAddressFromCoordinates(double lat, double lng) async {
    try {
      List<Placemark> placemarks = await placemarkFromCoordinates(lat, lng);
      if (placemarks.isNotEmpty) {
        Placemark place = placemarks.first;
        
        // street name and neighborhood
        String name = place.name ?? '';
        String street = place.thoroughfare ?? '';
        String subLocality = place.subLocality ?? '';
        String locality = place.locality ?? '';
        String administrativeArea = place.administrativeArea ?? '';

        // Filter out Plus Codes
        if (name.contains('+')) name = '';
        if (street.contains('+')) street = '';

        List<String> parts = [];

        // Construct address parts
        if (street.isNotEmpty && street != name) {
          parts.add(street);
        } else if (name.isNotEmpty) {
          parts.add(name);
        }

        if (subLocality.isNotEmpty && subLocality != street && subLocality != name) {
          parts.add(subLocality);
        }

        if (locality.isNotEmpty && locality != subLocality) {
          parts.add(locality);
        }
        
        if (administrativeArea.isNotEmpty && administrativeArea != locality) {
          parts.add(administrativeArea);
        }

        // Join parts with comma
        String address = parts.join(', ');
        
        // Fallback if empty
        if (address.isEmpty) {
          return 'Unknown Location';
        }

        return address;
      }
    } catch (e) {
      print('Error fetching address: $e');
    }
    return 'Unknown Location';
  }
  String getGoogleMapsLink(double lat, double lng) {
    return 'https://www.google.com/maps/search/?api=1&query=$lat,$lng';
  }
}
