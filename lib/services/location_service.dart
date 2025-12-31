import 'package:geolocator/geolocator.dart';

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

      String address = 'Unknown location';
      try {
        address = await _getAddressFromLatLng(position.latitude, position.longitude);
      } catch (e) {
        address = "Lat: ${position.latitude.toStringAsFixed(4)}, Lng: ${position.longitude.toStringAsFixed(4)}";
      }

      return {
        'latitude': position.latitude,
        'longitude': position.longitude,
        'address': address,
      };
    } catch (e) {
      throw Exception("Failed to get location: $e");
    }
  }

  Future<String> _getAddressFromLatLng(double lat, double lng) async {
    try {
      final url = 'https://nominatim.openstreetmap.org/reverse?'
          'lat=$lat&lon=$lng&format=json';
      return "Location: ${lat.toStringAsFixed(4)}, ${lng.toStringAsFixed(4)}";
    } catch (e) {
      return "Location: ${lat.toStringAsFixed(4)}, ${lng.toStringAsFixed(4)}";
    }
  }
}