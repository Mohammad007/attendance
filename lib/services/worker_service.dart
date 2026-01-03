import '../database/database_helper.dart';
import '../models/worker.dart';

class WorkerService {
  final DatabaseHelper _db = DatabaseHelper.instance;

  // Create worker
  Future<int> createWorker(Worker worker) async {
    return await _db.insert('workers', worker.toMap());
  }

  // Get all workers
  Future<List<Worker>> getAllWorkers() async {
    final List<Map<String, dynamic>> maps = await _db.queryAll('workers');
    return List.generate(maps.length, (i) => Worker.fromMap(maps[i]));
  }

  // Get active workers only
  Future<List<Worker>> getActiveWorkers() async {
    final List<Map<String, dynamic>> maps = await _db.query(
      'workers',
      where: 'is_active = ?',
      whereArgs: [1],
      orderBy: 'name ASC',
    );
    return List.generate(maps.length, (i) => Worker.fromMap(maps[i]));
  }

  // Get worker by ID
  Future<Worker?> getWorkerById(int id) async {
    final List<Map<String, dynamic>> maps = await _db.query(
      'workers',
      where: 'id = ?',
      whereArgs: [id],
    );
    if (maps.isEmpty) return null;
    return Worker.fromMap(maps.first);
  }

  // Update worker
  Future<int> updateWorker(Worker worker) async {
    return await _db.update('workers', worker.toMap());
  }

  // Delete worker
  Future<int> deleteWorker(int id) async {
    return await _db.delete('workers', id);
  }

  // Toggle worker active status
  Future<int> toggleWorkerStatus(int id, bool isActive) async {
    return await _db.rawUpdate(
      'UPDATE workers SET is_active = ? WHERE id = ?',
      [isActive ? 1 : 0, id],
    );
  }

  // Search workers by name
  Future<List<Worker>> searchWorkers(String query) async {
    final List<Map<String, dynamic>> maps = await _db.rawQuery(
      'SELECT * FROM workers WHERE name LIKE ? ORDER BY name ASC',
      ['%$query%'],
    );
    return List.generate(maps.length, (i) => Worker.fromMap(maps[i]));
  }

  // Get workers count
  Future<int> getWorkersCount() async {
    final result = await _db.rawQuery('SELECT COUNT(*) as count FROM workers');
    return result.first['count'] as int;
  }

  // Get active workers count
  Future<int> getActiveWorkersCount() async {
    final result = await _db.rawQuery(
      'SELECT COUNT(*) as count FROM workers WHERE is_active = 1',
    );
    return result.first['count'] as int;
  }
}
