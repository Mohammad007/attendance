import 'package:flutter/foundation.dart';
import '../models/attendance.dart';
import '../services/attendance_service.dart';

class AttendanceProvider with ChangeNotifier {
  final AttendanceService _attendanceService = AttendanceService();

  List<Attendance> _attendances = [];
  bool _isLoading = false;
  String? _error;

  List<Attendance> get attendances => _attendances;
  bool get isLoading => _isLoading;
  String? get error => _error;

  // Mark attendance
  Future<bool> markAttendance(Attendance attendance) async {
    try {
      await _attendanceService.markAttendance(attendance);
      notifyListeners();
      return true;
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      return false;
    }
  }

  // Load worker attendance
  Future<void> loadWorkerAttendance(int workerId) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _attendances = await _attendanceService.getWorkerAttendance(workerId);
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
    }
  }

  // Get attendance by date
  Future<List<Attendance>> getAttendanceByDate(String date) async {
    try {
      return await _attendanceService.getAttendanceByDate(date);
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      return [];
    }
  }

  // Get attendance statistics
  Future<Map<String, int>> getAttendanceStats(
    int workerId,
    String startDate,
    String endDate,
  ) async {
    try {
      return await _attendanceService.getWorkerAttendanceStats(
        workerId,
        startDate,
        endDate,
      );
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      return {};
    }
  }

  // Bulk mark attendance
  Future<bool> bulkMarkAttendance(
    List<int> workerIds,
    String date,
    AttendanceStatus status,
  ) async {
    try {
      await _attendanceService.bulkMarkAttendance(workerIds, date, status);
      notifyListeners();
      return true;
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      return false;
    }
  }

  // Delete attendance
  Future<bool> deleteAttendance(int id) async {
    try {
      await _attendanceService.deleteAttendance(id);
      notifyListeners();
      return true;
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      return false;
    }
  }
}
