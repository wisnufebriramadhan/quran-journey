class AttendanceModel {
  final int? id;
  final String? time;
  final double? latitude;
  final double? longitude;
  final String? date;
  final String? dateFormatted;
  final double? distance;
  final String? createdAt;

  AttendanceModel({
    this.id,
    this.time,
    this.latitude,
    this.longitude,
    this.date,
    this.dateFormatted,
    this.distance,
    this.createdAt,
  });

  factory AttendanceModel.fromJson(Map<String, dynamic> json) {
    return AttendanceModel(
      id: json['id'],
      time: json['time'],
      latitude: json['latitude']?.toDouble(),
      longitude: json['longitude']?.toDouble(),
      date: json['date'],
      dateFormatted: json['date_formatted'],
      distance: json['distance']?.toDouble(),
      createdAt: json['created_at'],
    );
  }
}

class OfficeLocation {
  final double latitude;
  final double longitude;
  final int radius;

  OfficeLocation({
    required this.latitude,
    required this.longitude,
    required this.radius,
  });

  factory OfficeLocation.fromJson(Map<String, dynamic> json) {
    return OfficeLocation(
      latitude: json['latitude'].toDouble(),
      longitude: json['longitude'].toDouble(),
      radius: json['radius'],
    );
  }
}
