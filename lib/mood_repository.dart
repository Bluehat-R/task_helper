import 'app_database.dart';
import 'package:sqflite/sqflite.dart';

class MoodEntry {
  final int? id;
  final DateTime date;
  final int mood;
  final double sleepHours;
  final List<String> medicines; // ← ここ！
  final String? note;

  MoodEntry({
    this.id,
    required this.date,
    required this.mood,
    required this.sleepHours,
    required this.medicines,
    this.note,
  });

  Map<String, dynamic> toMap() => {
    'id': id,
    'date': date.toIso8601String(),
    'mood': mood,
    'sleep_hours': sleepHours,
    'medicine': medicines.isEmpty ? null : medicines.join(','), // ← CSVでもOK
    'note': note,
  };

  static MoodEntry fromMap(Map<String, dynamic> map) => MoodEntry(
    id: map['id'] as int?,
    date: DateTime.parse(map['date']),
    mood: map['mood'] as int,
    sleepHours: (map['sleep_hours'] as num?)?.toDouble() ?? 0,
    medicines: (map['medicine'] as String?)
        ?.split(',')
        .where((e) => e.isNotEmpty)
        .toList() ??
        [],
    note: map['note'] as String?,
  );
}

class MoodRepository {
  MoodRepository._();
  static final MoodRepository instance = MoodRepository._();

  Future<void> saveMood(MoodEntry entry) async {
    final db = await AppDatabase.instance.database;
    await db.insert(
      'mood',
      entry.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<MoodEntry?> getTodayMood() async {
    final db = await AppDatabase.instance.database;
    final start = DateTime(DateTime.now().year, DateTime.now().month, DateTime.now().day);
    final end = start.add(const Duration(days: 1));

    final rows = await db.query(
      'mood',
      where: 'date >= ? AND date < ?',
      whereArgs: [start.toIso8601String(), end.toIso8601String()],
      limit: 1,
    );

    if (rows.isEmpty) return null;
    return MoodEntry.fromMap(rows.first);
  }

  Future<List<MoodEntry>> getAllMoods() async {
    final db = await AppDatabase.instance.database;
    final rows = await db.query('mood', orderBy: 'date DESC');
    return rows.map((e) => MoodEntry.fromMap(e)).toList();
  }
}
