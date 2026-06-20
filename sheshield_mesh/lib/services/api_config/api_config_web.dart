import 'dart:html' as html;

String getApiBaseUrl() {
  final origin = html.window.location.origin;
  if (origin.contains('localhost') || origin.contains('127.0.0.1')) {
    return 'http://localhost:5001';
  }
  return origin;
}
