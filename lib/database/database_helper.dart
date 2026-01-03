import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import 'dart:io';

class DatabaseHelper {
  static final DatabaseHelper instance = DatabaseHelper._init();
  static Database? _database;

  DatabaseHelper._init();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB('laborbook.db');
    return _database!;
  }

  Future<Database> _initDB(String filePath) async {
    final Directory dbPath = await getApplicationDocumentsDirectory();
    final String path = join(dbPath.path, filePath);

    return await openDatabase(path, version: 1, onCreate: _createDB);
  }

  Future<void> _createDB(Database db, int version) async {
    const idType = 'INTEGER PRIMARY KEY AUTOINCREMENT';
    const textType = 'TEXT NOT NULL';
    const integerType = 'INTEGER NOT NULL';
    const realType = 'REAL NOT NULL';

    // Workers Table
    await db.execute('''
      CREATE TABLE workers (
        id $idType,
        name $textType,
        phone TEXT,
        job_type $textType,
        daily_wage $realType,
        join_date $textType,
        photo_path TEXT,
        is_active $integerType DEFAULT 1
      )
    ''');

    // Attendance Table
    await db.execute('''
      CREATE TABLE attendance (
        id $idType,
        worker_id $integerType,
        date $textType,
        status $textType,
        overtime_hours REAL DEFAULT 0,
        FOREIGN KEY (worker_id) REFERENCES workers (id) ON DELETE CASCADE
      )
    ''');

    // Payments Table
    await db.execute('''
      CREATE TABLE payments (
        id $idType,
        worker_id $integerType,
        amount $realType,
        payment_date $textType,
        payment_type $textType,
        note TEXT,
        FOREIGN KEY (worker_id) REFERENCES workers (id) ON DELETE CASCADE
      )
    ''');

    // Settings Table
    await db.execute('''
      CREATE TABLE settings (
        id $idType,
        language TEXT DEFAULT 'English',
        currency TEXT DEFAULT '₹',
        app_pin TEXT,
        theme_mode TEXT DEFAULT 'light'
      )
    ''');

    // Insert default settings
    await db.insert('settings', {
      'language': 'English',
      'currency': '₹',
      'app_pin': null,
      'theme_mode': 'light',
    });

    // Create indexes for better performance
    await db.execute('CREATE INDEX idx_worker_id ON attendance(worker_id)');
    await db.execute('CREATE INDEX idx_date ON attendance(date)');
    await db.execute('CREATE INDEX idx_payment_worker ON payments(worker_id)');
  }

  Future<void> close() async {
    final db = await instance.database;
    db.close();
  }

  // Generic CRUD operations
  Future<int> insert(String table, Map<String, dynamic> row) async {
    final db = await instance.database;
    return await db.insert(table, row);
  }

  Future<List<Map<String, dynamic>>> queryAll(String table) async {
    final db = await instance.database;
    return await db.query(table);
  }

  Future<List<Map<String, dynamic>>> query(
    String table, {
    String? where,
    List<dynamic>? whereArgs,
    String? orderBy,
  }) async {
    final db = await instance.database;
    return await db.query(
      table,
      where: where,
      whereArgs: whereArgs,
      orderBy: orderBy,
    );
  }

  Future<int> update(String table, Map<String, dynamic> row) async {
    final db = await instance.database;
    final id = row['id'];
    return await db.update(table, row, where: 'id = ?', whereArgs: [id]);
  }

  Future<int> delete(String table, int id) async {
    final db = await instance.database;
    return await db.delete(table, where: 'id = ?', whereArgs: [id]);
  }

  // Custom query execution
  Future<List<Map<String, dynamic>>> rawQuery(
    String sql, [
    List<dynamic>? arguments,
  ]) async {
    final db = await instance.database;
    return await db.rawQuery(sql, arguments);
  }

  Future<int> rawInsert(String sql, [List<dynamic>? arguments]) async {
    final db = await instance.database;
    return await db.rawInsert(sql, arguments);
  }

  Future<int> rawUpdate(String sql, [List<dynamic>? arguments]) async {
    final db = await instance.database;
    return await db.rawUpdate(sql, arguments);
  }

  Future<int> rawDelete(String sql, [List<dynamic>? arguments]) async {
    final db = await instance.database;
    return await db.rawDelete(sql, arguments);
  }
}
