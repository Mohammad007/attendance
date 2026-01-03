import '../database/database_helper.dart';
import '../models/payment.dart';

class PaymentService {
  final DatabaseHelper _db = DatabaseHelper.instance;

  // Create payment
  Future<int> createPayment(Payment payment) async {
    return await _db.insert('payments', payment.toMap());
  }

  // Get all payments for a worker
  Future<List<Payment>> getWorkerPayments(int workerId) async {
    final List<Map<String, dynamic>> maps = await _db.query(
      'payments',
      where: 'worker_id = ?',
      whereArgs: [workerId],
      orderBy: 'payment_date DESC',
    );
    return List.generate(maps.length, (i) => Payment.fromMap(maps[i]));
  }

  // Get payments by date range
  Future<List<Payment>> getPaymentsByDateRange(
    int workerId,
    String startDate,
    String endDate,
  ) async {
    final List<Map<String, dynamic>> maps = await _db.query(
      'payments',
      where: 'worker_id = ? AND payment_date BETWEEN ? AND ?',
      whereArgs: [workerId, startDate, endDate],
      orderBy: 'payment_date DESC',
    );
    return List.generate(maps.length, (i) => Payment.fromMap(maps[i]));
  }

  // Get total payments for a worker
  Future<double> getTotalPayments(
    int workerId,
    String startDate,
    String endDate,
  ) async {
    final result = await _db.rawQuery(
      '''
      SELECT SUM(amount) as total 
      FROM payments 
      WHERE worker_id = ? 
        AND payment_date BETWEEN ? AND ?
        AND payment_type = 'cash'
      ''',
      [workerId, startDate, endDate],
    );

    return (result.first['total'] as num?)?.toDouble() ?? 0.0;
  }

  // Get total advances for a worker
  Future<double> getTotalAdvances(
    int workerId,
    String startDate,
    String endDate,
  ) async {
    final result = await _db.rawQuery(
      '''
      SELECT SUM(amount) as total 
      FROM payments 
      WHERE worker_id = ? 
        AND payment_date BETWEEN ? AND ?
        AND payment_type = 'advance'
      ''',
      [workerId, startDate, endDate],
    );

    return (result.first['total'] as num?)?.toDouble() ?? 0.0;
  }

  // Update payment
  Future<int> updatePayment(Payment payment) async {
    return await _db.update('payments', payment.toMap());
  }

  // Delete payment
  Future<int> deletePayment(int id) async {
    return await _db.delete('payments', id);
  }

  // Get all payments (for reports)
  Future<List<Payment>> getAllPayments() async {
    final List<Map<String, dynamic>> maps = await _db.query(
      'payments',
      orderBy: 'payment_date DESC',
    );
    return List.generate(maps.length, (i) => Payment.fromMap(maps[i]));
  }

  // Get payment by ID
  Future<Payment?> getPaymentById(int id) async {
    final List<Map<String, dynamic>> maps = await _db.query(
      'payments',
      where: 'id = ?',
      whereArgs: [id],
    );
    if (maps.isEmpty) return null;
    return Payment.fromMap(maps.first);
  }
}
