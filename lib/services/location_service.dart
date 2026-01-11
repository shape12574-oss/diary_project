import 'package:geolocator/geolocator.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:async';

class LocationService {
  Future<bool> _checkPermission() async {
    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        return false;
      }
    }
    if (permission == LocationPermission.deniedForever) {
      return false;
    }
    return true;
  }

  Future<Map<String, dynamic>> getCurrentLocation() async {
    final hasPermission = await _checkPermission();
    if (!hasPermission) {
      throw Exception("Location permission not granted.");
    }

    try {
      Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );

      String address = await _getDisplayNameOnly(
        position.latitude,
        position.longitude,
      );

      return {
        'latitude': position.latitude,
        'longitude': position.longitude,
        'address': address,
      };
    } catch (e) {
      throw Exception("Failed to get location: $e");
    }
  }

  // Only fetch display_name
  Future<String> _getDisplayNameOnly(double lat, double lng) async {
    try {
      final url = 'https://nominatim.openstreetmap.org/reverse?'
          'lat=$lat&lon=$lng&format=json&zoom=18';

      final response = await http.get(
        Uri.parse(url),
        headers: {'User-Agent': 'TravelSnap/1.0'},
      ).timeout(const Duration(seconds: 5));

      if (response.statusCode == 200) {
        final data = json.decode(response.body);

        final displayName = data['display_name'];
        if (displayName is String && displayName.isNotEmpty) {
          return displayName;
        }
      }
    } catch (e) {
      print('Geocoding error: $e');
    }

    // Return lat and lng if api request failed
    return '${lat.toStringAsFixed(4)}°, ${lng.toStringAsFixed(4)}°';
  }
}