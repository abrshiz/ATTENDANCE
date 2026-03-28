import 'package:intl/intl.dart';

enum AttendanceStatus { present, absent }

class Student {
  final String id;
  final String name;
  final DateTime timestamp;
  final AttendanceStatus status;

  Student({
    required this.id,
    required this.name,
    required this.timestamp,
    required this.status,
  });

  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'timestamp': timestamp.toIso8601String(),
    'status': status.index,
  };

  factory Student.fromJson(Map<String, dynamic> json) => Student(
    id: json['id'],
    name: json['name'],
    timestamp: DateTime.parse(json['timestamp']),
    status: AttendanceStatus.values[json['status']],
  );

  String get formattedTime => DateFormat('hh:mm a').format(timestamp);
  String get formattedDate => DateFormat('yyyy-MM-dd').format(timestamp);

  bool get isPresent => status == AttendanceStatus.present;
  bool get isAbsent => status == AttendanceStatus.absent;
}
