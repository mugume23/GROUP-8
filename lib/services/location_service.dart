import 'package:geolocator/geolocator.dart';
import 'package:permission_handler/permission_handler.dart';

class LocationService {
  /// Request permission and return current GPS position.
  /// Returns null if permission denied or error.
  static Future<Position?> getCurrentPosition() async {
    final status = await Permission.location.request();
    if (!status.isGranted) return null;

    final serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) return null;

    try {
      return await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.high,
          timeLimit: Duration(seconds: 15),
        ),
      );
    } catch (_) {
      return null;
    }
  }

  /// Check if location permission is already granted.
  static Future<bool> hasPermission() async {
    final status = await Permission.location.status;
    return status.isGranted;
  }
}
