import 'package:get/get.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'db_outfitcam_entity.dart';

class OutfitCamDatabase extends GetxService {
  static Database? _database;
  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    final databasesPath = await getDatabasesPath();
    final path = join(databasesPath, 'outfit_cam.db');
    return await openDatabase(path, version: 1, onCreate: _onCreate);
  }

  Future<void> _onCreate(Database db, int version) async {
    await db.execute('''
      CREATE TABLE history_records (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        image_path TEXT NOT NULL,
        feature_type TEXT NOT NULL,
        created_at TEXT NOT NULL
      )
    ''');
  }

  Future<List<HistoryRecord>> getHistoryRecords() async {
    try {
      final db = await database;
      final List<Map<String, dynamic>> maps = await db.query(
        'history_records',
        orderBy: 'created_at DESC, id DESC',
      );
      return List.generate(maps.length, (i) {
        return HistoryRecord.fromMap(maps[i]);
      });
    } catch (e) {
      print('Error getting history records: $e');
      return [];
    }
  }

  Future<int> insertHistoryRecord(HistoryRecord record) async {
    try {
      final db = await database;
      return await db.insert(
        'history_records',
        record.toMap(),
        conflictAlgorithm: ConflictAlgorithm.replace,
      );
    } catch (e) {
      print('Error inserting history record: $e');
      return -1;
    }
  }

  Future<int> deleteHistoryRecord(int id) async {
    try {
      final db = await database;
      return await db.delete(
        'history_records',
        where: 'id = ?',
        whereArgs: [id],
      );
    } catch (e) {
      print('Error deleting history record: $e');
      return 0;
    }
  }

  Future<int> clearHistoryRecords() async {
    try {
      final db = await database;
      return await db.delete('history_records');
    } catch (e) {
      print('Error clearing history records: $e');
      return 0;
    }
  }
}
