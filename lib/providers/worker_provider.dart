import 'package:flutter/foundation.dart';
import '../models/worker.dart';
import '../services/worker_service.dart';

class WorkerProvider with ChangeNotifier {
  final WorkerService _workerService = WorkerService();

  List<Worker> _workers = [];
  List<Worker> _activeWorkers = [];
  bool _isLoading = false;
  String? _error;

  List<Worker> get workers => _workers;
  List<Worker> get activeWorkers => _activeWorkers;
  bool get isLoading => _isLoading;
  String? get error => _error;

  // Load all workers
  Future<void> loadWorkers() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _workers = await _workerService.getAllWorkers();
      _activeWorkers = await _workerService.getActiveWorkers();
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
    }
  }

  // Add worker
  Future<bool> addWorker(Worker worker) async {
    try {
      await _workerService.createWorker(worker);
      await loadWorkers();
      return true;
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      return false;
    }
  }

  // Update worker
  Future<bool> updateWorker(Worker worker) async {
    try {
      await _workerService.updateWorker(worker);
      await loadWorkers();
      return true;
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      return false;
    }
  }

  // Delete worker
  Future<bool> deleteWorker(int id) async {
    try {
      await _workerService.deleteWorker(id);
      await loadWorkers();
      return true;
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      return false;
    }
  }

  // Toggle worker status
  Future<bool> toggleWorkerStatus(int id, bool isActive) async {
    try {
      await _workerService.toggleWorkerStatus(id, isActive);
      await loadWorkers();
      return true;
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      return false;
    }
  }

  // Search workers
  Future<List<Worker>> searchWorkers(String query) async {
    try {
      return await _workerService.searchWorkers(query);
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      return [];
    }
  }

  // Get worker by ID
  Future<Worker?> getWorkerById(int id) async {
    try {
      return await _workerService.getWorkerById(id);
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      return null;
    }
  }
}
