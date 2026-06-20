// lib/models/mesh_message.dart

class MeshMessage {
  final String type; // e.g., 'location'
  final double lat;
  final double lng;
  final int timestamp; // epoch ms

  MeshMessage({required this.type, required this.lat, required this.lng, required this.timestamp});

  factory MeshMessage.fromJson(Map<String, dynamic> json) {
    return MeshMessage(
      type: json['type'] as String,
      lat: (json['lat'] as num).toDouble(),
      lng: (json['lng'] as num).toDouble(),
      timestamp: json['timestamp'] as int,
    );
  }

  Map<String, dynamic> toJson() => {
        'type': type,
        'lat': lat,
        'lng': lng,
        'timestamp': timestamp,
      };
}
