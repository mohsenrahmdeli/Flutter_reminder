import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class DbHelper {
  static late Database _db;
  static const String tableName = 'reminders';

  static Future<void> initDb() async {
  final dbPath = await getDatabasesPath();
  _db = await openDatabase(
    join(dbPath, 'reminder.db'),
    onCreate: (db, version) async {
      await db.execute('''
        CREATE TABLE $tableName (
          id INTEGER PRIMARY KEY AUTOINCREMENT,
          title TEXT,
          description TEXT,
          isActive INTEGER,
          reminderTime TEXT,
          category TEXT
        )
      ''');
    },
    version: 1,
    onOpen: (db) {
      print("Database opened successfully in read-write mode");
    },
  );
}


  static Future<List<Map<String, dynamic>>> getReminders() async {
    return await _db.query(tableName);
  }

  static Future<Map<String, dynamic>?> getReminderById(int id) async {
    final List<Map<String, dynamic>> results =
        await _db.query(tableName, where: 'id = ?', whereArgs: [id]);
    if (results.isNotEmpty) {
      return results.first;
    }
    return null;
  }

  static Future<int> addReminder(Map<String, dynamic> reminder) async {
    return await _db.insert(tableName, reminder);
  }

  static Future<void> updateReminder(
      int id, Map<String, dynamic> reminder) async {
    await _db.update(tableName, reminder, where: 'id = ?', whereArgs: [id]);
  }

  static Future<void> deleteReminder(int id) async {
    await _db.delete(tableName, where: 'id = ?', whereArgs: [id]);
  }

  static Future<Map<String, dynamic>?> toggleReminder(
      int id, bool isActive) async {
    final rowsAffected = await _db.update(
      tableName,
      {'isActive': isActive ? 1 : 0},
      where: 'id = ?',
      whereArgs: [id],
    );

    if (rowsAffected > 0) {
      final updatedReminder = await _db.query(
        tableName,
        where: 'id = ?',
        whereArgs: [id],
      );
      return updatedReminder.isNotEmpty ? updatedReminder.first : null;
    } else {
      return null;
    }
  }
}
