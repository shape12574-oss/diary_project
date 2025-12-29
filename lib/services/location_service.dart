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

  Future<Map<String, double>> getCurrentLocation() async {
    final hasPermission = await _checkPermission();
    if (!hasPermission) {
      throw Exception("Location permission not granted");
    }

    try {
      Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );
      return {
        'latitude': position.latitude,
        'longitude': position.longitude,
      };
    } catch (e) {
      throw Exception("Failed to get location: $e");
    }
  }
}