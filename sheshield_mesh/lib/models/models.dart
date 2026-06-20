import 'package:uuid/uuid.dart';

class AlertModel {
  final String id;
  final DateTime timestamp;
  final String location;
  final String status;
  final int relayCount;
  final String? nearbyDeviceId;
  DateTime? deliveredAt;

  AlertModel({
    required this.id,
    required this.timestamp,
    required this.location,
    required this.status,
    this.relayCount = 0,
    this.nearbyDeviceId,
    this.deliveredAt,
  });

  AlertModel copyWith({
    String? id,
    DateTime? timestamp,
    String? location,
    String? status,
    int? relayCount,
    String? nearbyDeviceId,
    DateTime? deliveredAt,
  }) {
    return AlertModel(
      id: id ?? this.id,
      timestamp: timestamp ?? this.timestamp,
      location: location ?? this.location,
      status: status ?? this.status,
      relayCount: relayCount ?? this.relayCount,
      nearbyDeviceId: nearbyDeviceId ?? this.nearbyDeviceId,
      deliveredAt: deliveredAt ?? this.deliveredAt,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'timestamp': timestamp.toIso8601String(),
      'location': location,
      'status': status,
      'relayCount': relayCount,
      'nearbyDeviceId': nearbyDeviceId,
      'deliveredAt': deliveredAt?.toIso8601String(),
    };
  }

  factory AlertModel.fromJson(Map<String, dynamic> json) {
    return AlertModel(
      id: json['id'] as String,
      timestamp: DateTime.parse(json['timestamp'] as String),
      location: json['location'] as String,
      status: json['status'] as String,
      relayCount: json['relayCount'] as int? ?? 0,
      nearbyDeviceId: json['nearbyDeviceId'] as String?,
      deliveredAt: json['deliveredAt'] != null
          ? DateTime.parse(json['deliveredAt'] as String)
          : null,
    );
  }

  static AlertModel generate({String? location}) {
    const uuid = Uuid();
    final id = 'SOS-${uuid.v4().substring(0, 8).toUpperCase()}';
    return AlertModel(
      id: id,
      timestamp: DateTime.now(),
      location: location ?? '28.6139° N, 77.2090° E (New Delhi)',
      status: 'Stored Offline',
      relayCount: 0,
      nearbyDeviceId: 'DEV-${uuid.v4().substring(0, 6).toUpperCase()}',
    );
  }
}

class ContactModel {
  final String id;
  final String name;
  final String phone;
  final String relation;
  final String initials;
  final int colorIndex;

  ContactModel({
    required this.id,
    required this.name,
    required this.phone,
    required this.relation,
    required this.initials,
    required this.colorIndex,
  });

  ContactModel copyWith({
    String? id,
    String? name,
    String? phone,
    String? relation,
    String? initials,
    int? colorIndex,
  }) {
    return ContactModel(
      id: id ?? this.id,
      name: name ?? this.name,
      phone: phone ?? this.phone,
      relation: relation ?? this.relation,
      initials: initials ?? this.initials,
      colorIndex: colorIndex ?? this.colorIndex,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'phone': phone,
      'relation': relation,
      'initials': initials,
      'colorIndex': colorIndex,
    };
  }

  factory ContactModel.fromJson(Map<String, dynamic> json) {
    return ContactModel(
      id: json['id'] as String,
      name: json['name'] as String,
      phone: json['phone'] as String,
      relation: json['relation'] as String,
      initials: json['initials'] as String,
      colorIndex: json['colorIndex'] as int,
    );
  }
}

List<ContactModel> get sampleContacts => [
      ContactModel(
        id: '1',
        name: 'Priya Sharma',
        phone: '+91 98765 43210',
        relation: 'Sister',
        initials: 'PS',
        colorIndex: 0,
      ),
      ContactModel(
        id: '2',
        name: 'Anjali Mehta',
        phone: '+91 87654 32109',
        relation: 'Friend',
        initials: 'AM',
        colorIndex: 1,
      ),
      ContactModel(
        id: '3',
        name: 'Rohan Kumar',
        phone: '+91 76543 21098',
        relation: 'Brother',
        initials: 'RK',
        colorIndex: 2,
      ),
    ];

List<AlertModel> get sampleHistory => [
      AlertModel(
        id: 'SOS-A1B2C3D4',
        timestamp: DateTime.now().subtract(const Duration(hours: 2)),
        location: '28.6139° N, 77.2090° E',
        status: 'Delivered',
        relayCount: 3,
        deliveredAt: DateTime.now().subtract(const Duration(hours: 1, minutes: 50)),
      ),
      AlertModel(
        id: 'SOS-E5F6G7H8',
        timestamp: DateTime.now().subtract(const Duration(days: 1, hours: 4)),
        location: '19.0760° N, 72.8777° E',
        status: 'Delivered',
        relayCount: 2,
        deliveredAt: DateTime.now().subtract(const Duration(days: 1, hours: 3, minutes: 55)),
      ),
      AlertModel(
        id: 'SOS-I9J0K1L2',
        timestamp: DateTime.now().subtract(const Duration(days: 3, hours: 10)),
        location: '12.9716° N, 77.5946° E',
        status: 'Delivered',
        relayCount: 1,
        deliveredAt: DateTime.now().subtract(const Duration(days: 3, hours: 9, minutes: 48)),
      ),
    ];
