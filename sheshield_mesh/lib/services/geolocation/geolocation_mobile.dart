import 'geolocation_types.dart';

class GeolocationService {
  static Future<LocationResult> getCurrentPosition() async {
    // Return mock location on native platform for this hackathon prototype
    return LocationResult(
      latitude: 12.9716,
      longitude: 77.5946,
      accuracy: 25.0,
    );
  }
}
