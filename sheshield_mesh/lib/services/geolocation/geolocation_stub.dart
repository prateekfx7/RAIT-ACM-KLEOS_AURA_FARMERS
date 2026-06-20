import 'geolocation_types.dart';

class GeolocationService {
  static Future<LocationResult> getCurrentPosition() async {
    // Return a default mock location
    return LocationResult(
      latitude: 12.9716,
      longitude: 77.5946,
      accuracy: 25.0,
    );
  }
}
