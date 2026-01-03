import 'package:flutter/foundation.dart';
import '../models/payment.dart';
import '../services/payment_service.dart';

class PaymentProvider with ChangeNotifier {
  final PaymentService _paymentService = PaymentService();

  List<Payment> _payments = [];
  bool _isLoading = false;
  String? _error;

  List<Payment> get payments => _payments;
  bool get isLoading => _isLoading;
  String? get error => _error;

  // Add payment
  Future<bool> addPayment(Payment payment) async {
    try {
      await _paymentService.createPayment(payment);
      notifyListeners();
      return true;
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      return false;
    }
  }

  // Load worker payments
  Future<void> loadWorkerPayments(int workerId) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _payments = await _paymentService.getWorkerPayments(workerId);
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
    }
  }

  // Get total payments
  Future<double> getTotalPayments(
    int workerId,
    String startDate,
    String endDate,
  ) async {
    try {
      return await _paymentService.getTotalPayments(
        workerId,
        startDate,
        endDate,
      );
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      return 0.0;
    }
  }

  // Get total advances
  Future<double> getTotalAdvances(
    int workerId,
    String startDate,
    String endDate,
  ) async {
    try {
      return await _paymentService.getTotalAdvances(
        workerId,
        startDate,
        endDate,
      );
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      return 0.0;
    }
  }

  // Delete payment
  Future<bool> deletePayment(int id) async {
    try {
      await _paymentService.deletePayment(id);
      notifyListeners();
      return true;
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      return false;
    }
  }
}
