import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart' as path; // 使用別名

class ExposureRecord {
  final int? id;
  final String category;
  final String activity;
  final int exposure;
  final String date;

  ExposureRecord({
    this.id,
    required this.category,
    required this.activity,
    required this.exposure,
    required this.date,
  });

  factory ExposureRecord.fromMap(Map<String, dynamic> map) {
    return ExposureRecord(
      id: map['id'],
      category: map['category'],
      activity: map['activity'],
      exposure: map['exposure'],
      date: map['date'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'category': category,
      'activity': activity,
      'exposure': exposure,
      'date': date,
    };
  }
}

class ExposureDatabase {
  static final ExposureDatabase instance = ExposureDatabase._init();
  static Database? _database;

  ExposureDatabase._init();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB('exposure.db');
    return _database!;
  }

  Future<Database> _initDB(String filePath) async {
    final dbPath = await getDatabasesPath();
    final databasePath = path.join(dbPath, filePath); // 使用 path 別名，變更變量名避免衝突
    return await openDatabase(databasePath, version: 1, onCreate: _createDB);
  }

  Future _createDB(Database db, int version) async {
    await db.execute('''
      CREATE TABLE records (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        category TEXT NOT NULL,
        activity TEXT NOT NULL,
        exposure INTEGER NOT NULL,
        date TEXT NOT NULL
      )
    ''');
  }

  Future<ExposureRecord> addRecord(ExposureRecord record) async {
    final db = await instance.database;
    final id = await db.insert('records', record.toMap());
    return ExposureRecord(
      id: id,
      category: record.category,
      activity: record.activity,
      exposure: record.exposure,
      date: record.date,
    );
  }

  Future<List<ExposureRecord>> getTodaysRecords() async {
    final db = await instance.database;
    final today = DateTime.now().toIso8601String().substring(0, 10); // 2025-06-07
    final result = await db.query(
      'records',
      where: 'date = ?',
      whereArgs: [today],
      orderBy: 'id DESC',
    );
    return result.map((json) => ExposureRecord.fromMap(json)).toList();
  }

  Future<int> deleteRecord(int id) async {
    final db = await instance.database;
    return await db.delete(
      'records',
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  Future<void> clearOldRecords() async {
    final db = await instance.database;
    final today = DateTime.now().toIso8601String().substring(0, 10);
    final count = await db.delete(
      'records',
      where: 'date != ?',
      whereArgs: [today],
    );
    print('已清除 $count 筆舊紀錄。');
  }

  Future close() async {
    final db = await instance.database;
    db.close();
  }
}