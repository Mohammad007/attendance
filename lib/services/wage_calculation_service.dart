import '../models/worker.dart';
import '../models/attendance.dart';
import 'attendance_service.dart';
import 'payment_service.dart';

class WageCalculationService {
  final AttendanceService _attendanceService = AttendanceService();
  final PaymentService _paymentService = PaymentService();

  // Calculate wage for a specific period
  Future<WageCalculation> calculateWage({
    required Worker worker,
    required String startDate,
    required String endDate,
    double overtimeRate = 1.5, // 1.5x for overtime
  }) async {
    // Get attendance records
    final attendances = await _attendanceService.getAttendanceByDateRange(
      worker.id!,
      startDate,
      endDate,
    );

    // Calculate days
    double totalDays = 0;
    double overtimeHours = 0; // Always 0 - overtime removed

    for (var attendance in attendances) {
      switch (attendance.status) {
        case AttendanceStatus.present:
          totalDays += 1;
          break;
        case AttendanceStatus.half:
          totalDays += 0.5;
          break;
        case AttendanceStatus.absent:
          // No addition
          break;
      }
      // overtimeHours += attendance.overtimeHours; // REMOVED - no overtime
    }

    // Calculate base wage
    final double baseWage = totalDays * worker.dailyWage;

    // Calculate overtime wage (always 0 - overtime removed)
    final double overtimeWage = 0.0;

    // Get total payments and advances
    final double totalPaid = await _paymentService.getTotalPayments(
      worker.id!,
      startDate,
      endDate,
    );

    final double totalAdvances = await _paymentService.getTotalAdvances(
      worker.id!,
      startDate,
      endDate,
    );

    // Calculate totals (no overtime)
    final double grossWage = baseWage; // No overtime added
    final double netWage = grossWage - totalAdvances;
    final double balance = netWage - totalPaid;

    return WageCalculation(
      worker: worker,
      startDate: startDate,
      endDate: endDate,
      totalDays: totalDays,
      overtimeHours: overtimeHours,
      baseWage: baseWage,
      overtimeWage: overtimeWage,
      grossWage: grossWage,
      totalAdvances: totalAdvances,
      totalPaid: totalPaid,
      netWage: netWage,
      balance: balance,
      attendances: attendances,
    );
  }

  // Calculate daily wage
  double calculateDailyWage(
    Worker worker,
    AttendanceStatus status,
    double overtimeHours,
  ) {
    double wage = 0;

    switch (status) {
      case AttendanceStatus.present:
        wage = worker.dailyWage;
        break;
      case AttendanceStatus.half:
        wage = worker.dailyWage * 0.5;
        break;
      case AttendanceStatus.absent:
        wage = 0;
        break;
    }

    // Add overtime (1.5x rate)
    if (overtimeHours > 0) {
      final overtimeWage = (overtimeHours / 8) * worker.dailyWage * 1.5;
      wage += overtimeWage;
    }

    return wage;
  }

  // Get monthly summary for all workers
  Future<List<WageCalculation>> getMonthlyWageSummary(
    List<Worker> workers,
    String startDate,
    String endDate,
  ) async {
    List<WageCalculation> summaries = [];

    for (var worker in workers) {
      if (worker.isActive) {
        final calculation = await calculateWage(
          worker: worker,
          startDate: startDate,
          endDate: endDate,
        );
        summaries.add(calculation);
      }
    }

    return summaries;
  }
}

// Wage Calculation Result Model
class WageCalculation {
  final Worker worker;
  final String startDate;
  final String endDate;
  final double totalDays;
  final double overtimeHours;
  final double baseWage;
  final double overtimeWage;
  final double grossWage;
  final double totalAdvances;
  final double totalPaid;
  final double netWage;
  final double balance;
  final List<Attendance> attendances;

  WageCalculation({
    required this.worker,
    required this.startDate,
    required this.endDate,
    required this.totalDays,
    required this.overtimeHours,
    required this.baseWage,
    required this.overtimeWage,
    required this.grossWage,
    required this.totalAdvances,
    required this.totalPaid,
    required this.netWage,
    required this.balance,
    required this.attendances,
  });

  @override
  String toString() {
    return '''
    Worker: ${worker.name}
    Period: $startDate to $endDate
    Total Days: $totalDays
    Overtime Hours: $overtimeHours
    Base Wage: ₹$baseWage
    Overtime Wage: ₹$overtimeWage
    Gross Wage: ₹$grossWage
    Advances: ₹$totalAdvances
    Paid: ₹$totalPaid
    Net Wage: ₹$netWage
    Balance: ₹$balance
    ''';
  }
}
