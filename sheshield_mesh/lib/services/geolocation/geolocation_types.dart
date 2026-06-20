class LocationResult {
  final double latitude;
  final double longitude;
  final double accuracy;
  final bool isIpFallback;

  LocationResult({
    required this.latitude,
    required this.longitude,
    required this.accuracy,
    this.isIpFallback = false,
  });

  /// Formats as "12.9716° N, 77.5946° E" with hemisphere labels
  String get formatted {
    final latDir = latitude >= 0 ? 'N' : 'S';
    final lngDir = longitude >= 0 ? 'E' : 'W';
    final lat = latitude.abs().toStringAsFixed(4);
    final lng = longitude.abs().toStringAsFixed(4);
    return '$lat° $latDir, $lng° $lngDir';
  }

  /// Short version with accuracy
  String get formattedWithAccuracy {
    return '$formatted (±${accuracy.toStringAsFixed(0)} m)';
  }
}

class GeolocationError implements Exception {
  final String message;
  final int? code;
  GeolocationError(this.message, {this.code});

  @override
  String toString() => message;
}
