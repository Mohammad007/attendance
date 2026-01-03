import '../database/database_helper.dart';
import '../models/attendance.dart';

class AttendanceService {
  final DatabaseHelper _db = DatabaseHelper.instance;

  // Mark attendance
  Future<int> markAttendance(Attendance attendance) async {
    // Check if attendance already exists for this date
    final existing = await getAttendanceByWorkerAndDate(
      attendance.workerId,
      attendance.date,
    );

    if (existing != null) {
      // Update existing attendance
      return await _db.update('attendance', attendance.toMap());
    } else {
      // Create new attendance
      return await _db.insert('attendance', attendance.toMap());
    }
  }

  // Get attendance by worker and date
  Future<Attendance?> getAttendanceByWorkerAndDate(
    int workerId,
    String date,
  ) async {
    final List<Map<String, dynamic>> maps = await _db.query(
      'attendance',
      where: 'worker_id = ? AND date = ?',
      whereArgs: [workerId, date],
    );
    if (maps.isEmpty) return null;
    return Attendance.fromMap(maps.first);
  }

  // Get all attendance for a worker
  Future<List<Attendance>> getWorkerAttendance(int workerId) async {
    final List<Map<String, dynamic>> maps = await _db.query(
      'attendance',
      where: 'worker_id = ?',
      whereArgs: [workerId],
      orderBy: 'date DESC',
    );
    return List.generate(maps.length, (i) => Attendance.fromMap(maps[i]));
  }

  // Get attendance for a specific date
  Future<List<Attendance>> getAttendanceByDate(String date) async {
    final List<Map<String, dynamic>> maps = await _db.query(
      'attendance',
      where: 'date = ?',
      whereArgs: [date],
    );
    return List.generate(maps.length, (i) => Attendance.fromMap(maps[i]));
  }

  // Get attendance for date range
  Future<List<Attendance>> getAttendanceByDateRange(
    int workerId,
    String startDate,
    String endDate,
  ) async {
    final List<Map<String, dynamic>> maps = await _db.query(
      'attendance',
      where: 'worker_id = ? AND date BETWEEN ? AND ?',
      whereArgs: [workerId, startDate, endDate],
      orderBy: 'date ASC',
    );
    return List.generate(maps.length, (i) => Attendance.fromMap(maps[i]));
  }

  // Get attendance statistics for a worker
  Future<Map<String, int>> getWorkerAttendanceStats(
    int workerId,
    String startDate,
    String endDate,
  ) async {
    final attendances = await getAttendanceByDateRange(
      workerId,
      startDate,
      endDate,
    );

    int present = 0;
    int absent = 0;
    int halfDays = 0;

    for (var attendance in attendances) {
      switch (attendance.status) {
        case AttendanceStatus.present:
          present++;
          break;
        case AttendanceStatus.absent:
          absent++;
          break;
        case AttendanceStatus.half:
          halfDays++;
          break;
      }
    }

    return {
      'present': present,
      'absent': absent,
      'half': halfDays,
      'total': attendances.length,
    };
  }

  // Get total overtime hours for a worker
  Future<double> getTotalOvertimeHours(
    int workerId,
    String startDate,
    String endDate,
  ) async {
    final result = await _db.rawQuery(
      '''
      SELECT SUM(overtime_hours) as total 
      FROM attendance 
      WHERE worker_id = ? AND date BETWEEN ? AND ?
      ''',
      [workerId, startDate, endDate],
    );

    return (result.first['total'] as num?)?.toDouble() ?? 0.0;
  }

  // Delete attendance
  Future<int> deleteAttendance(int id) async {
    return await _db.delete('attendance', id);
  }

  // Update attendance
  Future<int> updateAttendance(Attendance attendance) async {
    return await _db.update('attendance', attendance.toMap());
  }

  // Bulk mark attendance for multiple workers
  Future<void> bulkMarkAttendance(
    List<int> workerIds,
    String date,
    AttendanceStatus status,
  ) async {
    for (var workerId in workerIds) {
      await markAttendance(
        Attendance(workerId: workerId, date: date, status: status),
      );
    }
  }
}
