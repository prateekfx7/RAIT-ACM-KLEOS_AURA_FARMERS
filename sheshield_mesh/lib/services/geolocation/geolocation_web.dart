import 'dart:async';
import 'dart:convert';
import 'dart:html' as html;
// ignore: avoid_web_libraries_in_flutter
import 'dart:js_util' as js_util;
// ignore: avoid_web_libraries_in_flutter
import 'dart:js' as js;
import 'geolocation_types.dart';

class GeolocationService {
  static Future<LocationResult> getCurrentPosition() async {
    try {
      // Tier 1: Try high accuracy real-time browser location (GPS / High Precision)
      return await _getBrowserPosition(enableHighAccuracy: true, timeoutMs: 10000);
    } catch (e) {
      try {
        // Tier 2: Try coarse browser location (Wi-Fi / Cellular / Coarse)
        return await _getBrowserPosition(enableHighAccuracy: false, timeoutMs: 5000);
      } catch (e2) {
        // Tier 3: Fall back to IP Geolocation API
        return await _fetchIpGeolocation();
      }
    }
  }

  static Future<LocationResult> _getBrowserPosition({
    required bool enableHighAccuracy,
    required int timeoutMs,
  }) {
    final completer = Completer<LocationResult>();

    final geolocation =
        js_util.getProperty(js.context['navigator'], 'geolocation');

    if (geolocation == null) {
      completer.completeError(GeolocationError('Geolocation API not supported in this browser.'));
      return completer.future;
    }

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
          isIpFallback: false,
        );
        if (!completer.isCompleted) completer.complete(result);
      } catch (e) {
        if (!completer.isCompleted) {
          completer.completeError(GeolocationError('Failed to parse position: $e'));
        }
      }
    });

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

    final options = js_util.jsify({
      'enableHighAccuracy': enableHighAccuracy,
      'timeout': timeoutMs,
      'maximumAge': 0,
    });

    js_util.callMethod(
      geolocation,
      'getCurrentPosition',
      [successCallback, errorCallback, options],
    );

    return completer.future;
  }

  static Future<LocationResult> _fetchIpGeolocation() async {
    try {
      // Attempt 1: api.ipgeolocation.io with user's key
      final responseText = await html.HttpRequest.getString(
        'https://api.ipgeolocation.io/ipgeo?apiKey=ce9763059f914931b761e1131a776908',
      );
      final data = jsonDecode(responseText);
      final lat = double.parse(data['latitude'].toString());
      final lng = double.parse(data['longitude'].toString());
      final accuracy = 1000.0;
      
      return LocationResult(
        latitude: lat,
        longitude: lng,
        accuracy: accuracy,
        isIpFallback: true,
      );
    } catch (e) {
      try {
        // Attempt 2: ipapi.co (free fallback, no API key needed)
        final responseText = await html.HttpRequest.getString('https://ipapi.co/json/');
        final data = jsonDecode(responseText);
        final lat = double.parse(data['latitude'].toString());
        final lng = double.parse(data['longitude'].toString());
        final accuracy = 1500.0;

        return LocationResult(
          latitude: lat,
          longitude: lng,
          accuracy: accuracy,
          isIpFallback: true,
        );
      } catch (e2) {
        throw GeolocationError('IP Geolocation fallback failed (ipgeolocation: $e, ipapi: $e2)');
      }
    }
  }
}
