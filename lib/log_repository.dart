import 'package:sqflite/sqflite.dart';

import 'app_database.dart';
import 'log_model.dart';

class LogRepository {
  LogRepository._();
  static final LogRepository instance = LogRepository._();

  Future<void> addPcStartLog() async {
    final db = await AppDatabase.instance.database;
    final entry = LogEntry(
      type: 'pc_start',
      timestamp: DateTime.now(),
    );
    await db.insert(
      'log',
      entry.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<List<LogEntry>> getLogsByDate(DateTime date) async {
    final db = await AppDatabase.instance.database;
    final start = DateTime(date.year, date.month, date.day);
    final end = start.add(const Duration(days: 1));

    final rows = await db.query(
      'log',
      where: 'timestamp >= ? AND timestamp < ?',
      whereArgs: [
        start.toIso8601String(),
        end.toIso8601String(),
      ],
      orderBy: 'timestamp ASC',
    );

    return rows.map((e) => LogEntry.fromMap(e)).toList();
  }
  
  // ★ ここから追加：全ログを新しい順に取得
  Future<List<LogEntry>> getAllLogs() async {
    final db = await AppDatabase.instance.database;

    final rows = await db.query(
      'log',
      orderBy: 'timestamp DESC',
    );

    return rows.map((e) => LogEntry.fromMap(e)).toList();
  }
  // ★ ここから追加：連続 PC 起動日数
  Future<int> getPcStartStreak() async {
    final db = await AppDatabase.instance.database;

    // pc_start のある日付だけを取得（重複排除）
    final rows = await db.rawQuery(
      '''
      SELECT DISTINCT substr(timestamp, 1, 10) AS d
      FROM log
      WHERE type = ?
      ORDER BY d DESC
      ''',
      ['pc_start'],
    );

    if (rows.isEmpty) return 0;

    DateTime todayDate() {
      final now = DateTime.now();
      return DateTime(now.year, now.month, now.day);
    }

    bool sameDate(DateTime a, DateTime b) =>
        a.year == b.year && a.month == b.month && a.day == b.day;

    var expected = todayDate();
    var streak = 0;

    for (final row in rows) {
      final dStr = row['d'] as String; // 'YYYY-MM-DD'
      final logDate = DateTime.parse(dStr); // 00:00:00 の DateTime

      if (sameDate(logDate, expected)) {
        streak++;
        expected = expected.subtract(const Duration(days: 1));
      } else {
        // 「連続してない日」が来たらそこで終了
        break;
      }
    }

    return streak;
  }
}
