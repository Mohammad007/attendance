class Attendance {
  final int? id;
  final int workerId;
  final String date;
  final AttendanceStatus status;
  final double overtimeHours;

  Attendance({
    this.id,
    required this.workerId,
    required this.date,
    required this.status,
    this.overtimeHours = 0.0,
  });

  // Convert to Map for database
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'worker_id': workerId,
      'date': date,
      'status': status.toString().split('.').last,
      'overtime_hours': overtimeHours,
    };
  }

  // Create from Map
  factory Attendance.fromMap(Map<String, dynamic> map) {
    return Attendance(
      id: map['id'] as int?,
      workerId: map['worker_id'] as int,
      date: map['date'] as String,
      status: _statusFromString(map['status'] as String),
      overtimeHours: (map['overtime_hours'] as num?)?.toDouble() ?? 0.0,
    );
  }

  static AttendanceStatus _statusFromString(String status) {
    switch (status.toLowerCase()) {
      case 'present':
        return AttendanceStatus.present;
      case 'absent':
        return AttendanceStatus.absent;
      case 'half':
        return AttendanceStatus.half;
      default:
        return AttendanceStatus.absent;
    }
  }

  Attendance copyWith({
    int? id,
    int? workerId,
    String? date,
    AttendanceStatus? status,
    double? overtimeHours,
  }) {
    return Attendance(
      id: id ?? this.id,
      workerId: workerId ?? this.workerId,
      date: date ?? this.date,
      status: status ?? this.status,
      overtimeHours: overtimeHours ?? this.overtimeHours,
    );
  }

  @override
  String toString() {
    return 'Attendance{id: $id, workerId: $workerId, date: $date, status: $status}';
  }
}

enum AttendanceStatus { present, absent, half }
