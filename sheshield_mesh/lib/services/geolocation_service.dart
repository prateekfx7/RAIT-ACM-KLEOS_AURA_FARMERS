import 'dart:async';
// ignore: avoid_web_libraries_in_flutter
import 'dart:js_util' as js_util;
// ignore: avoid_web_libraries_in_flutter
import 'dart:js' as js;

/// Wraps the browser's navigator.geolocation.getCurrentPosition() API.
/// Based on: https://developer.mozilla.org/en-US/docs/Web/API/Geolocation_API/Using_the_Geolocation_API
class GeolocationService {
  /// Returns a human-readable location string like:
  ///   "12.9716° N, 77.5946° E (±25 m)"
  /// Throws a [GeolocationError] if denied or unavailable.
  static Future<LocationResult> getCurrentPosition() {
    final completer = Completer<LocationResult>();

    final geolocation =
        js_util.getProperty(js.context['navigator'], 'geolocation');

    if (geolocation == null) {
      completer.completeError(
        GeolocationError('Geolocation API not supported in this browser.'),
      );
      return completer.future;
    }

    // Success callback — mirrors MDN's successCallback(position)
    final successCallback = js.allowInterop((position) {
      try {
        final coords = js_util.getProperty(position, 'coords');
        final lat =
            (js_util.getProperty(coords, 'latitude') as num).toDouble();
        final lng =
            (js_util.getProperty(coords, 'longitude') as num).toDouble();
        final accuracy =
            (js_util.getProperty(coords, 'accuracy') as num).toDouble();

        final result = LocationResult(
          latitude: lat,
          longitude: lng,
          accuracy: accuracy,
        );
        if (!completer.isCompleted) completer.complete(result);
      } catch (e) {
        if (!completer.isCompleted) {
          completer.completeError(GeolocationError('Failed to parse position: $e'));
        }
      }
    });

    // Error callback — mirrors MDN's errorCallback(error)
    final errorCallback = js.allowInterop((error) {
      final code = js_util.getProperty(error, 'code') as int;
      final message = js_util.getProperty(error, 'message') as String;
      String reason;
      switch (code) {
        case 1:
          reason = 'Location permission denied by user.';
          break;
        case 2:
          reason = 'Location unavailable.';
          break;
        case 3:
          reason = 'Location request timed out.';
          break;
        default:
          reason = 'Unknown error: $message';
      }
      if (!completer.isCompleted) {
        completer.completeError(GeolocationError(reason, code: code));
      }
    });

    // Options: high accuracy, 10s timeout — same as MDN example
    final options = js_util.jsify({
      'enableHighAccuracy': true,
      'timeout': 10000,
      'maximumAge': 0,
    });

    js_util.callMethod(
      geolocation,
      'getCurrentPosition',
      [successCallback, errorCallback, options],
    );

    return completer.future;
  }
}

class LocationResult {
  final double latitude;
  final double longitude;
  final double accuracy;

  LocationResult({
    required this.latitude,
    required this.longitude,
    required this.accuracy,
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
    return '${formatted} (±${accuracy.toStringAsFixed(0)} m)';
  }
}

class GeolocationError implements Exception {
  final String message;
  final int? code;
  GeolocationError(this.message, {this.code});

  @override
  String toString() => message;
}
